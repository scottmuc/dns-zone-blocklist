#!/usr/bin/env bash

set -e

docker build --tag dns-zone-test .
docker run --rm dns-zone-test \
    -v $PWD:/dns-zone-blocklist \
    -w /dns-zone-blocklist \
    ./check-config-tests.sh
