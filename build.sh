#!/bin/sh
# Builds Mirror.app next to this script.
set -e
cd "$(dirname "$0")"
swift build -c release
rm -rf Mirror.app
mkdir -p Mirror.app/Contents/MacOS
cp .build/release/Mirror Mirror.app/Contents/MacOS/
cp Info.plist Mirror.app/Contents/
codesign --force --sign - Mirror.app
