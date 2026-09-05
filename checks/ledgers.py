"""Offline checks for the hand-maintained ledgers against independent inputs."""
import argparse
import json
from pathlib import Path
import re
import sys

from jsonschema import Draft202012Validator
from referencing import Registry, Resource


# Existing package writers leave these markers. A changed writer must be
# reviewed alongside its ledger; do not execute desktop commands in this check.
STUB_MARKERS = (
    'NixOS: packages are declarative\n',
    'handled declaratively (via',
    'packages are declarative — add packages',
    'neutralized; nothing was changed',
    'NixOS: lock-screen PAM is declarative.',
    '# omarchy-nix: no AUR on NixOS.',
    '# omarchy-nix: always report "missing"',
    '# omarchy-nix: no pacman update probe.',
    '# omarchy-nix: snapper/limine snapshots are Arch-only.',
    '# follow the theme. Silent no-op:',
)


def read_json(file):
    def unique_keys(pairs):
        result = {}
        for key, value in pairs:
            if key in result:
                raise ValueError(f'{file}: duplicate JSON key {key}')
            result[key] = value
        return result
    return json.loads(Path(file).read_text(), object_pairs_hook=unique_keys)


def normalized_script(text):
    # Only mechanical interpreter/store/sudo paths are ignored. Changes to
    # copying modes, runtime probes or flow require a wrap classification.
    text = re.sub(r'^#![^\n]*\n', '', text)
    text = re.sub(
        r'/nix/store/[a-z0-9]{32}-[^/\s"\x27]+/share/omarchy',
        '/usr/share/omarchy', text,
    )
    return text.replace('/run/wrappers/bin/sudo', 'sudo')


def package_inventory(upstream):
    inventory = {}
    files = sorted((upstream / 'install').glob('*.packages'))
    if not files:
        raise ValueError('upstream install/*.packages inventory is empty')
    for file in files:
        names = set()
        for number, line in enumerate(file.read_text().splitlines(), 1):
            name = line.split('#', 1)[0].strip()
            if not name:
                continue
            if not re.fullmatch(r'[a-zA-Z0-9@+_.-]+', name):
                raise ValueError(f'{file.name}:{number}: malformed package name {name!r}')
            if name in names:
                raise ValueError(f'{file.name}: duplicate upstream package {name}')
            names.add(name)
            inventory.setdefault(name, []).append(str(file.relative_to(upstream)))
    if not inventory:
        raise ValueError('upstream package inventory has no package names')
    return inventory


def validate(repo, upstream, packaged, evidence):
    errors = []
    def require(condition, message):
        if not condition:
            errors.append(message)

    schemas = [read_json(repo / 'schema' / name) for name in (
        'compat.schema.json', 'scripts.schema.json', 'packages.schema.json',
    )]
    registry = Registry().with_resources(
        (schema['$id'], Resource.from_contents(schema)) for schema in schemas
    )
    scripts = read_json(repo / 'schema/scripts.lock.json')
    packages = read_json(repo / 'schema/packages.map.json')
    for document, schema in zip((scripts, packages), schemas[1:]):
        Draft202012Validator.check_schema(schema)
        for error in Draft202012Validator(schema, registry=registry).iter_errors(document):
            errors.append(f"{schema['title']}:{error.json_path}: {error.message}")
    if errors:
        return errors  # Do not traverse malformed rows.

    lock = read_json(repo / 'flake.lock')
    upstream_node = lock['nodes'][lock['nodes']['root']['inputs']['omarchy-src']]
    for name, ledger in [('scripts', scripts), ('packages', packages)]:
        require(ledger['pin'] == upstream_node['original'].get('ref'), f'{name}: pin differs from flake.lock')
        require(ledger['upstream_rev'] == upstream_node['locked']['rev'], f'{name}: revision differs from flake.lock')
    require(evidence['pin'] == scripts['pin'] and evidence['upstream_rev'] == scripts['upstream_rev'],
            'evaluated input pin/revision differs from ledger')

    def indexed(rows, key, label):
        result = {}
        for row in rows:
            value = row[key]
            require(value not in result, f'{label}: duplicate {value}')
            result[value] = row
        return result

    def exact(actual, expected, label):
        for name in sorted(set(expected) - set(actual)):
            errors.append(f'{label}: unclassified/missing {name}')
        for name in sorted(set(actual) - set(expected)):
            errors.append(f'{label}: stale/unexpected {name}')

    locked = indexed(scripts['scripts'], 'id', 'scripts')
    ports = indexed(scripts['port_scripts'], 'id', 'port scripts')
    bins = {file.name for file in (upstream / 'bin').iterdir() if file.is_file()}
    require(bool(bins), 'upstream bin inventory is empty')
    exact(locked, bins | {'pacman'}, 'upstream scripts')
    require(not set(locked) & set(ports), 'port scripts overlap upstream/policy rows')
    require(locked.get('pacman', {}).get('class') == 'na', 'pacman must remain na')
    require(locked.get('pacman', {}).get('upstream') == 'pacman', 'pacman policy source must remain pacman')
    shipped = {file.name for file in (packaged / 'bin').iterdir()
               if file.is_file() and not file.name.startswith('.')}
    expected_shipped = set()
    for name, row in {**locked, **ports}.items():
        cls = row['class']
        require(re.fullmatch(r'v[0-9]+\.[0-9]+\.[0-9]+(?:-.*)?', row['since_pin']) is not None,
                f'{name}: invalid since_pin')
        require(cls not in ('na', 'drop') or not row['user_visible'], f'{name}: absent command marked user-visible')
        if name in bins:
            require(row['upstream'] == f'bin/{name}', f'{name}: wrong upstream path')
        if name in ports:
            require(row['upstream'] == 'pkgs/omarchy.nix', f'{name}: port helper source must be pkgs/omarchy.nix')
            require(cls in ('wrap', 'stub'), f'{name}: port helper must be wrap/stub')
        if cls in ('vendor', 'wrap', 'stub') or (cls == 'host' and name in shipped):
            expected_shipped.add(name)
            if name not in shipped:
                continue  # exact() below reports the missing file.
            require(bool((packaged / 'bin' / name).stat().st_mode & 0o111) == row.get('executable', True),
                    f'{name}: packaged executable mode disagrees with ledger')
            require(row.get('executable', True) or bool(row.get('notes')),
                    f'{name}: non-executable file needs notes')
            body = (packaged / 'bin' / name).read_text()
            stubbed = any(marker in body for marker in STUB_MARKERS)
            require(stubbed == (cls == 'stub'), f'{name}: packaged stub body disagrees with class {cls}')
            if cls in ('wrap', 'stub', 'host'):
                require(bool(row.get('stand_in')) and bool(row.get('notes')), f'{name}: adapted command needs stand_in and notes')
            if cls == 'stub':
                require(bool(row.get('reason')), f'{name}: stub needs reason')
            if cls == 'vendor' and name in bins:
                require(normalized_script(body) == normalized_script((upstream / 'bin' / name).read_text()),
                        f'{name}: vendor body changed beyond interpreter/store/sudo paths; classify adaptation')
    exact(shipped, expected_shipped, 'packaged scripts')
    for name, row in evidence['runtime']['scripts'].items():
        require(name in locked, f'{name}: runtime manifest entry missing from script ledger')
        cls = locked.get(name, {}).get('class')
        if row['class'] == 'declarative-note':
            require(cls == 'stub', f'{name}: declarative-note requires stub classification')
        elif row['class'] == 'nixos-adapted':
            require(cls in ('wrap', 'stub'), f'{name}: nixos-adapted requires wrap/stub classification')

    inventory = package_inventory(upstream)
    mapped = indexed(packages['packages'], 'upstream', 'packages')
    extras = indexed(packages['extra_packages'], 'upstream', 'extra packages')
    exact(mapped, inventory, 'upstream packages')
    require(not set(mapped) & set(extras), 'extra packages overlap upstream install inventory')
    local_attrs = set()
    for name, row in {**mapped, **extras}.items():
        if name in mapped:
            require(sorted(row['sources']) == inventory.get(name), f'{name}: package source lists differ from upstream')
        else:
            for source in row['evidence']:
                candidate = Path(source)
                require(not candidate.is_absolute() and '..' not in candidate.parts and (repo / source).is_file(),
                        f'{name}: missing/unsafe repository evidence {source}')
        status = row['status']
        if status in ('nixpkgs', 'pkgs'):
            probe = evidence['packages'].get(name, {})
            require(probe.get('attr') == row['attr'] and probe.get('status') == status,
                    f'{name}: package probe does not match ledger attribute/status')
            require(probe.get('valid') is True, f'{name}: {status} attr {row["attr"]} does not evaluate to a derivation')
            if row['availability'] == 'default':
                require(probe.get('default') is True, f'{name}: {row["attr"]} is absent from default module packages/fonts')
            if status == 'pkgs':
                local_attrs.add(row['attr'])
                require((repo / 'pkgs' / (row['attr'] + '.nix')).is_file(), f'{name}: local derivation source missing')
        elif status == 'host':
            for option in row['options']:
                require(evidence['options'].get(option) is True, f'{name}: unknown NixOS option {option}')
    exact(local_attrs, set(evidence['local_packages']) - {'default'}, 'flake package coverage')
    return errors


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    for arg in ('repo', 'upstream', 'packaged', 'evidence'):
        parser.add_argument('--' + arg, required=True, type=Path)
    args = parser.parse_args()
    try:
        errors = validate(args.repo, args.upstream, args.packaged, read_json(args.evidence))
    except (ValueError, KeyError, OSError) as error:
        errors = [str(error)]
    for error in errors:
        print('ledger: ' + error, file=sys.stderr)
    if errors:
        return 1
    print('Ledger schemas, pins, inventories, script bodies and Nix package/option probes passed.')
    return 0


if __name__ == '__main__':
    sys.exit(main())
