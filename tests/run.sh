#!/bin/sh
# Checks an image with synthetic data: tests/run.sh <image>
set -eu

image=$1
root=$(dirname "$0")/..
version=$(sed -n 's/^ARG AGE_VERSION=//p' "$root/Dockerfile")

# Same constraints as a hardened pod: read-only root, no capability, writes in /tmp only.
run() {
  docker run --rm --read-only --tmpfs /tmp --cap-drop ALL --security-opt no-new-privileges "$image" "$@"
}

[ "$(run id -u)" = 65534 ] || { echo "image must not run as root"; exit 1; }

[ "$(run age --version)" = "v$version" ] || { echo "age version is not $version"; exit 1; }

# Encrypts with the public key only, as a backup job does, then decrypts.
run sh -euc '
  cd /tmp
  age-keygen -o key 2>/dev/null
  age-keygen -y key >recipient
  echo synthetic >clear
  age -R recipient -o clear.age clear
  if grep -q synthetic clear.age; then exit 1; fi
  age -d -i key -o decrypted clear.age
  cmp clear decrypted
  sha256sum clear.age >clear.age.sha256
  sha256sum -c -s clear.age.sha256
  find . -name clear.age | grep -q .
'

# Decrypting with another key must fail.
run sh -euc '
  cd /tmp
  age-keygen -o key 2>/dev/null
  age-keygen -o other 2>/dev/null
  age-keygen -y key >recipient
  echo synthetic | age -R recipient -o clear.age
  if age -d -i other clear.age >/dev/null 2>&1; then exit 1; fi
'

echo "ok: $image"
