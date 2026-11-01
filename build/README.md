# CI/CD tool

This project uses [osixia/dagger-build](https://github.com/osixia/dagger-build) to build, test, and deploy images.

## Get Help
```
go run main.go --help
```

## Run Tests
```
go mod vendor
go run main.go job test ../Dockerfile --arches amd64
```

`main.go` replaces `job.Test`, because the shared check expects an entrypoint that reports the image tag. The checks are in `tests/`: release tag matching the age version, non-root user, age version, encryption and decryption with synthetic data, and the shell tools a backup job needs.
