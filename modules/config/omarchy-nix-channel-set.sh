#!/bin/bash
# omarchy:summary=Pin the omahedron flake input to a release tag
# omarchy:args=<omahedron-X.Y.Z|main>
# omarchy:examples=omarchy channel set omahedron-4.0.2
# omarchy:requires-sudo=true
set -euo pipefail
exec "$(dirname "${BASH_SOURCE[0]}")/omarchy-pin" "$@"
