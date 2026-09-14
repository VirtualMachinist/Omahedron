#!/bin/bash
# omarchy:summary=Disable fingerprint unlock (declarative omarchy.fingerprint.enable)
# omarchy:requires-sudo=true
set -euo pipefail
exec "$(dirname "${BASH_SOURCE[0]}")/omarchy-setup-fingerprint" off
