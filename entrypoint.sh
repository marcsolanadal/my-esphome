#!/bin/sh
set -e

# Decrypt secrets.yaml if age key is mounted
if [ -f /run/secrets/age.key ] && [ -f /workspace/secrets.yaml.age ]; then
    echo "Decrypting secrets.yaml..."
    age --decrypt --identity /run/secrets/age.key \
        --output /workspace/secrets.yaml \
        /workspace/secrets.yaml.age
fi

exec "$@"
