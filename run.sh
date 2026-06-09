#!/bin/bash
APP_NAME=$(basename "$(cd "$(dirname "$0")" && pwd)")
APP_NAME="MacWidgetNet"
pkill -x "$APP_NAME" 2>/dev/null && sleep 0.5
swift build -c release 2>&1 | grep -v "^$"
.build/arm64-apple-macosx/release/"$APP_NAME" &
disown
