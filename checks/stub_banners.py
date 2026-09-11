"""Grep packaged stub bodies for the COMPETE §3.6 banner regex."""
import argparse
import json
import re
import sys
from pathlib import Path

BANNER = re.compile(r'^omahedron: (stub|na|wrap|host): [a-z0-9-]+$')
# Intentional silent stubs — no stdout banner by contract (see stub_output.py).
SILENT = frozenset({
    'omarchy-pkg-aur-accessible',
    'omarchy-pkg-missing',
    'omarchy-theme-set-browser',
})


def banner_lines(body):
    for raw in body.splitlines():
        line = raw.strip().strip('"').strip("'")
        if BANNER.match(line):
            yield line


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--ledger', type=Path, required=True)
    parser.add_argument('--packaged', type=Path, required=True)
    args = parser.parse_args()
    ledger = json.loads(args.ledger.read_text())
    stubs = [row for row in ledger['scripts'] + ledger['port_scripts'] if row['class'] == 'stub']
    assert stubs, 'No stubs in ledger; refusing a vacuous banner check'
    missing = []
    for row in stubs:
        script = args.packaged / 'bin' / row['id']
        if not script.is_file():
            missing.append(f"{row['id']}: packaged script missing")
            continue
        if row['id'] in SILENT:
            continue
        if not list(banner_lines(script.read_text())):
            missing.append(f"{row['id']}: no banner line matching COMPETE §3.6 regex")
    if missing:
        print('\n'.join(missing), file=sys.stderr)
        sys.exit(1)
    print(f'Grep-validated {len(stubs)} stub scripts ({len(SILENT)} silent exceptions).')


if __name__ == '__main__':
    main()
