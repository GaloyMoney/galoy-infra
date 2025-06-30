#!/bin/bash
set -eu

TEMP_DIR=$(mktemp -d)
trap "echo '    --> removing $TEMP_DIR' && rm -rf $TEMP_DIR" EXIT

echo "    --> Cloning blink-infra-bootstrap-tfstate into $TEMP_DIR"
git clone --depth 3 --single-branch --branch main --no-tags git@github.com:blinkbitcoin/blink-infra-bootstrap-tfstate.git "$TEMP_DIR/blink-infra-bootstrap-tfstate"

cd "$TEMP_DIR/blink-infra-bootstrap-tfstate"
echo "    --> deleting bootstrap.tfstate"
git rm bootstrap.tfstate  && git commit -m "manually removing bootstrap.tfstate" && git push

