#!/bin/sh

# Local dir
CWD=$(pwd)
DIR=$(cd "$(dirname "$0")" || exit; pwd)
ROOT_DIR=$(dirname "$DIR")

cd "$ROOT_DIR/lib/Luau" || exit

# Get latest tags
git fetch --tags
LATEST_TAG=$(git describe --tags `git rev-list --tags --max-count=1`)
echo "Updating Luau to latest tag: $LATEST_TAG"
git checkout "$LATEST_TAG"

cd "$CWD" || exit

exit 0
