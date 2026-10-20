#!/bin/bash
# Builds, installs to /Applications as a real .app bundle, and launches it.
# (A bare SwiftPM binary cannot be registered as a login item.)
exec "$(dirname "$0")/build_app.sh"
