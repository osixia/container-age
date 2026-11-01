#!/bin/sh
# Image checks, with synthetic data only.
set -eu

[ "$(id -u)" = 65534 ] || { echo "image must not run as root"; exit 1; }

[ "$(age --version)" = "v$AGE_VERSION" ] || { echo "age version is not $AGE_VERSION"; exit 1; }

workdir=$(mktemp -d)
cd "$workdir"

# Encrypts with the public key only, as a backup job does, then decrypts.
age-keygen -o key 2>/dev/null
age-keygen -o other 2>/dev/null
age-keygen -y key >recipient
echo synthetic >clear
age -R recipient -o clear.age clear
if grep -q synthetic clear.age; then echo "clear text in encrypted file"; exit 1; fi
age -d -i key -o decrypted clear.age
cmp clear decrypted

# Decrypting with another key must fail.
if age -d -i other clear.age >/dev/null 2>&1; then echo "decrypted with another key"; exit 1; fi

# Tools a backup job needs next to age.
sha256sum clear.age >clear.age.sha256
sha256sum -c -s clear.age.sha256
find . -name clear.age | grep -q .
