package main

import (
	"context"
	"os"

	"dagger.io/dagger"

	"github.com/osixia/container-age/build/tests"
	"github.com/osixia/dagger-build/cmd"
	"github.com/osixia/dagger-build/config"
	"github.com/osixia/dagger-build/job"
)

func main() {

	// image

	var AgeImage = &config.Image{
		BaseImage:    "alpine:3.24@sha256:be2656061b536c1883c4034790e21d0a09c5aaaf51968b89368a3c0371ea2c9a",
		Distribution: config.Alpine,

		Name:        "osixia/age",
		Description: "age file encryption container image 🐳🔐🌴",

		Url:           "https://github.com/osixia/container-age",
		Documentation: "https://github.com/osixia/container-age",
		Source:        "https://github.com/osixia/container-age",

		Authors: "The osixia/container-age maintainers",
		Vendor:  "Osixia",

		Licences: "MIT",
	}

	config.Images = []*config.Image{
		AgeImage,
	}

	config.DefaultImage = AgeImage

	// github

	config.ProjectGithubRepo = &config.GithubRepo{
		Organization: "osixia",
		Project:      "container-age",
	}

	// custom function

	// job.DefaultTest expects an entrypoint reporting the image tag: this image only has age.
	job.Test = func(ctx context.Context, client *dagger.Client, options any) ([]*job.BuildResult, error) {
		o := options.(*job.TestOptions)

		builds, err := job.Export(ctx, client, &o.ExportOptions)
		if err != nil {
			return nil, err
		}
		if err := tests.Run(ctx, builds, o.Version); err != nil {
			return nil, err
		}
		return builds, nil
	}

	// execute cmd

	mainCtx := context.Background()
	if err := cmd.Run(mainCtx); err != nil {
		os.Exit(1)
	}

}
