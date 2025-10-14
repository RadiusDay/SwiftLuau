#!/bin/sh

# Local dir
CWD=$(pwd)
DIR=$(cd "$(dirname "$0")" || exit; pwd)
ROOT_DIR=$(dirname "$DIR")

cd "$ROOT_DIR/Sources/CLuaCommon/include/Luau" || exit
rm -f *.h
find ../../../../lib/Luau/Common/include/Luau -type f -print0 | while IFS= read -r -d '' file; do
    ln -s "$file" "$(basename "$file")"
done

cd "$CWD" || exit

exit 0
