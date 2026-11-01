# osixia/age 🐳🔐🌴

[age](https://github.com/FiloSottile/age) file encryption tool in a small container image, built from the Alpine package. It includes `age`, `age-keygen` and the Alpine shell tools, and runs as a non-root user.

## ⚡ Quickstart

``` bash
docker run --rm -v "$PWD:/data" -w /data -u "$(id -u):$(id -g)" osixia/age \
  age -r age1... -o backup.tar.age backup.tar
```

The image works with a read-only root filesystem and no capabilities, and only needs write access to the files it produces.

## 🏷️ Tags

Tags follow the age version: `x.y.z`, `x.y`, `x` and `latest`. `x.y.z-n` is a rebuild of the same version, for example after a base image update. In production, pin the image by digest.

## 🔏 Verify the image

Images are signed with [cosign](https://github.com/sigstore/cosign) keyless, and carry an SPDX SBOM attestation:

``` bash
cosign verify osixia/age:1.3.2 \
  --certificate-oidc-issuer https://token.actions.githubusercontent.com \
  --certificate-identity-regexp '^https://github\.com/osixia/container-age/\.github/workflows/'

cosign verify-attestation --type spdxjson osixia/age:1.3.2 \
  --certificate-oidc-issuer https://token.actions.githubusercontent.com \
  --certificate-identity-regexp '^https://github\.com/osixia/container-age/\.github/workflows/'
```

## 🧪 Build and test

``` bash
docker build -t osixia/age:test .
tests/run.sh osixia/age:test
```

## 🔓 License

This project is licensed under the terms of the [MIT license](LICENSE.md). age is licensed under its own [BSD 3-Clause license](https://github.com/FiloSottile/age/blob/main/LICENSE).
