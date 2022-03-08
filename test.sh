#!/usr/bin/env bash

set -e

docker build --tag dns-zone-test .

docker run --rm \
    -v $PWD:/dns-zone-blocklist \
    -w /dns-zone-blocklist \
    dns-zone-test \
    ./check-config-tests.sh
