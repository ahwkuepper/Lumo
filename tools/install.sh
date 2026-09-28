#!/bin/bash
# Update the one everyday installation; staging and backups remain unindexed.
set -euo pipefail
cd "$(dirname "$0")/.."
ROOT="$PWD"
DEST="/Applications/Vesta.app"
IDENTIFIER="io.github.ahwkuepper.Vesta"

if [ -e "$DEST" ]; then
    CURRENT=$(/usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' "$DEST/Contents/Info.plist")
    [ "$CURRENT" = "$IDENTIFIER" ] || { echo "Refusing to replace a different app at $DEST" >&2; exit 1; }
    if [ -z "${VESTA_SIGNING_IDENTITY:-}" ]; then
        CURRENT_IDENTITY=$(codesign -dvv "$DEST" 2>&1 | sed -n 's/^Authority=//p' | head -1)
        if [ -n "$CURRENT_IDENTITY" ]; then
            if ! security find-identity -v -p codesigning | grep -Fq "\"$CURRENT_IDENTITY\""; then
                echo "The installed app's signing identity is unavailable: $CURRENT_IDENTITY" >&2
                echo "Build locally with ./build.sh; installation was left unchanged." >&2
                exit 1
            fi
            export VESTA_SIGNING_IDENTITY="$CURRENT_IDENTITY"
        fi
    fi
fi

./build.sh
SOURCE="$ROOT/.build/app/Vesta.app"
codesign --verify --deep --strict "$SOURCE"

# Stage completely before stopping the current app or replacing its bundle.
STAGING=$(mktemp -d /Applications/.vesta-install.XXXXXX)
trap 'rm -rf "$STAGING"' EXIT
ditto "$SOURCE" "$STAGING/Vesta.app"
codesign --verify --deep --strict "$STAGING/Vesta.app"

if [ -d "$DEST" ]; then
    BACKUP=$(mktemp -d "$ROOT/.build/previous-apps.XXXXXX")
    ditto "$DEST" "$BACKUP/Vesta.app"
    echo "Previous installation saved in $BACKUP/Vesta.app"
fi

# Vesta is a menu-bar controller with no unsaved documents. Stop its processes so
# a still-running old executable cannot continue to create a second status item.
pkill -x Vesta || true
for attempt in {1..30}; do
    if ! pgrep -x Vesta >/dev/null; then break; fi
    sleep 0.1
done
if pgrep -x Vesta >/dev/null; then
    echo "Vesta is still running; installation left unchanged." >&2
    exit 1
fi

if [ -d "$DEST" ]; then mv "$DEST" "$STAGING/previous.app"; fi
if ! mv "$STAGING/Vesta.app" "$DEST"; then
    if [ -d "$STAGING/previous.app" ]; then mv "$STAGING/previous.app" "$DEST"; fi
    exit 1
fi

LSREGISTER=/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister
"$LSREGISTER" -u "$SOURCE" || true
"$LSREGISTER" -f "$DEST"
open "$DEST"
echo "Installed and opened $DEST"
