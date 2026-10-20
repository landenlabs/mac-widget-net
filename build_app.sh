#!/bin/bash
# Copyright (c) 2026 LanDen Labs - Dennis Lang
#
# Builds a release binary and packages it as a proper .app bundle, then
# installs it to /Applications. A bare SwiftPM executable cannot be
# registered as a login item (SMAppService and macOS Login Items both
# require a real .app bundle) — this script produces one.
set -euo pipefail
cd "$(dirname "$0")"

APP_NAME="MacWidgetNet"
VERSION=$(cat VERSION 2>/dev/null || echo "1.0.0")
INSTALL_DIR="${INSTALL_DIR:-/Applications}"
APP_BUNDLE="$INSTALL_DIR/$APP_NAME.app"

echo "Building $APP_NAME release binary..."
swift build -c release
BIN_DIR=$(swift build -c release --show-bin-path)

pkill -x "$APP_NAME" 2>/dev/null && sleep 0.5 || true

rm -rf "$APP_BUNDLE"
mkdir -p "$APP_BUNDLE/Contents/MacOS" "$APP_BUNDLE/Contents/Resources"

cp "$BIN_DIR/$APP_NAME" "$APP_BUNDLE/Contents/MacOS/$APP_NAME"

RESOURCE_BUNDLE="$BIN_DIR/${APP_NAME}_${APP_NAME}.bundle"
if [ -d "$RESOURCE_BUNDLE" ]; then
    cp -R "$RESOURCE_BUNDLE" "$APP_BUNDLE/Contents/Resources/"
fi


sed "s/__VERSION__/$VERSION/g" Packaging/Info.plist > "$APP_BUNDLE/Contents/Info.plist"

codesign --force --deep --sign - "$APP_BUNDLE"

echo "Installed $APP_BUNDLE"
open "$APP_BUNDLE"
