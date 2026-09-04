#!/usr/bin/env bash
# templates/stub-script.sh — copy when wrapping a reached distro command.
# First line of stdout is parseable. Do not look like success.
set -euo pipefail
reason="${OMAHEDRON_STUB_REASON:-unspecified}"
class="${OMAHEDRON_STUB_CLASS:-stub}"
printf 'omahedron: %s: %s\n' "$class" "$reason"
echo "This command exists so an Omarchy menu does not 404. Omahedron does not implement the Arch-side behavior." >&2
echo "See docs/COMPAT.md and schema/scripts.lock.json." >&2
exit 2
