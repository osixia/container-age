FROM alpine:3.24@sha256:be2656061b536c1883c4034790e21d0a09c5aaaf51968b89368a3c0371ea2c9a

# The image tag follows this version: x.y.z, or x.y.z-n to rebuild the same version.
ARG AGE_VERSION=1.3.2

RUN apk add --no-cache "age~=${AGE_VERSION}"

LABEL org.opencontainers.image.title="osixia/age" \
      org.opencontainers.image.description="age file encryption container image 🐳🔐🌴" \
      org.opencontainers.image.source="https://github.com/osixia/container-age" \
      org.opencontainers.image.url="https://github.com/osixia/container-age" \
      org.opencontainers.image.vendor="Osixia" \
      org.opencontainers.image.licenses="MIT"

USER 65534:65534

CMD ["age", "--help"]
