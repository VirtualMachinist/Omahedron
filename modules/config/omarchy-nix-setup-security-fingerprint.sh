#!/bin/bash
# omarchy:summary=Enable fingerprint unlock (declarative omarchy.fingerprint.enable)
# omarchy:args=[on|off]
# omarchy:examples=omarchy setup security fingerprint
# omarchy:requires-sudo=true
set -euo pipefail
exec "$(dirname "${BASH_SOURCE[0]}")/omarchy-setup-fingerprint" "${1:-on}"
