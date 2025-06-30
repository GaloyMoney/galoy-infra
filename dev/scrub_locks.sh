#!/bin/bash


TEMP_DIR=$(mktemp -d)
trap "echo '    --> removing $TEMP_DIR' && rm -rf $TEMP_DIR" EXIT

echo "    --> Cloning concourse-locks into $TEMP_DIR"
git clone --depth 3 --single-branch --branch main --no-tags git@github.com:blinkbitcoin/concourse-locks.git "$TEMP_DIR/concourse-locks"

cd "$TEMP_DIR/concourse-locks/gcp-infra-testflight"
echo "    --> Unclaiming gcp-testflight"
git mv claimed/gcp-testflight unclaimed  && git commit -m "manually unclaiming gcp-testflight" && git push

