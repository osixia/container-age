package tests

import (
	"context"
	_ "embed"
	"fmt"
	"regexp"
	"strings"
	"time"

	"dagger.io/dagger"

	"github.com/osixia/dagger-build/config"
	"github.com/osixia/dagger-build/job"
)

// Run checks every built image. CI builds each arch on a native runner: run locally
// with --arches matching the host to avoid emulation.
func Run(ctx context.Context, builds []*job.BuildResult, version string) error {

	for _, build := range builds {
		for _, image := range build.Containers {

			if err := tagFollowsAge(ctx, image, version); err != nil {
				return err
			}
			if err := Image(ctx, image); err != nil {
				return err
			}
		}
	}

	return nil
}

// tagFollowsAge refuses a release tag that does not match the age version in the image.
func tagFollowsAge(ctx context.Context, image *dagger.Container, version string) error {

	if !regexp.MustCompile(config.TagRegex).MatchString(version) {
		return nil
	}

	age, err := image.EnvVariable(ctx, "AGE_VERSION")
	if err != nil {
		return err
	}

	if tag, _, _ := strings.Cut(version, "-"); tag != age {
		return fmt.Errorf("tag %v must be %v or %v-<suffix>", version, age, age)
	}

	return nil
}

// Image runs the image checks with synthetic data, as the image user.
func Image(ctx context.Context, image *dagger.Container) error {

	ctx, cancel := context.WithTimeout(ctx, 60*time.Second)
	defer cancel()

	exec := image.
		WithNewFile("/tmp/age-image-check.sh", imageCheck, dagger.ContainerWithNewFileOpts{Permissions: 0755}).
		WithExec([]string{"sh", "/tmp/age-image-check.sh"}, dagger.ContainerWithExecOpts{Expect: dagger.ReturnTypeAny})

	code, err := exec.ExitCode(ctx)
	if err != nil {
		return err
	}
	if code == 0 {
		return nil
	}

	// Dagger does not show the output of a failed check.
	stdout, _ := exec.Stdout(ctx)
	stderr, _ := exec.Stderr(ctx)
	return fmt.Errorf("image checks: exit code %d:\n%s%s", code, stdout, stderr)
}

//go:embed testdata/image.sh
var imageCheck string
