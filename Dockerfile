# Keep in sync with BaseImage in build/main.go.
ARG BASE_IMAGE="alpine:3.24@sha256:be2656061b536c1883c4034790e21d0a09c5aaaf51968b89368a3c0371ea2c9a"
FROM ${BASE_IMAGE}

ARG IMAGE="osixia/age:develop"
ENV CONTAINER_IMAGE=${IMAGE}

# The image tag follows this version: x.y.z, or x.y.z-n to rebuild the same version.
ARG AGE_VERSION=1.3.2
ENV AGE_VERSION=${AGE_VERSION}

RUN apk add --no-cache "age~=${AGE_VERSION}"

USER 65534:65534

CMD ["age", "--help"]
