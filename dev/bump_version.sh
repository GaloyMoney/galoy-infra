#!/bin/bash


TEMP_DIR=$(mktemp -d)
trap "echo '    --> removing $TEMP_DIR' && rm -rf $TEMP_DIR" EXIT

echo "    --> Cloning blink-infra version branch into $TEMP_DIR"
git clone --depth 3 --single-branch --branch testflight-name-prefix-uid-branch --no-tags git@github.com:blinkbitcoin/blink-infra.git "$TEMP_DIR/blink-infra-special-branch"

cd "$TEMP_DIR/blink-infra-special-branch"

echo "    --> Bumping versiont"
# Read current version
CURRENT_VERSION=$(< version)

# Extract major, minor, patch using parameter expansion
IFS='.' read -r MAJOR MINOR PATCH <<< "$CURRENT_VERSION"

# Bump the patch version
NEW_PATCH=$((PATCH + 1))

# Create new version string
NEW_VERSION="$MAJOR.$MINOR.$NEW_PATCH"

# Write new version back to file
echo "$NEW_VERSION" > version

echo "    --> Committing and pushing new version $NEW_VERSION"
git commit -am "chore: bump version to $NEW_VERSION by dev/bump_version.sh" && git push
