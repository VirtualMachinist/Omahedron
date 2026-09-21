"""Exercise neutralized stub bodies with no session environment or user state."""
import argparse
import hashlib
import json
from pathlib import Path
import subprocess
import tempfile


def cases(name):
    # Silence and exit status are part of the caller contract for predicates.
    if name == 'omarchy-pkg-aur-accessible':
        return [([], 1, 'silent')]
    if name in ('omarchy-pkg-missing', 'omarchy-theme-set-browser'):
        return [([], 0, 'silent')]
    if name == 'omarchy-update-available':
        return [([], 1, 'silent'), (['-v'], 1, 'diagnostic'), (['--verbose'], 1, 'diagnostic')]
    if name == 'omarchy-snapshot':
        return [([], 1, 'usage'), (['invalid'], 1, 'usage'),
                (['create'], 0, 'diagnostic'), (['restore'], 0, 'diagnostic')]
    return [([], 0, 'diagnostic')]


def snapshot(root):
    return {str(p.relative_to(root)): hashlib.sha256(p.read_bytes()).hexdigest()
            if p.is_file() else None for p in root.rglob('*')}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    for name in ('ledger', 'packaged', 'bash', 'cat'):
        parser.add_argument('--' + name, type=Path, required=True)
    args = parser.parse_args()
    ledger = json.loads(args.ledger.read_text())
    stubs = [row for row in ledger['scripts'] + ledger['port_scripts'] if row['class'] == 'stub']
    assert stubs, 'No stubs found; refusing a vacuous contract check'
    count = 0
    for row in stubs:
        for argv, expected_rc, output in cases(row['id']):
            with tempfile.TemporaryDirectory() as tmp:
                root = Path(tmp)
                user = root / 'home'
                user.mkdir()
                commands = root / 'commands'
                commands.mkdir()
                (commands / 'cat').symlink_to(args.cat)
                # A forbidden command fails even if the stub swallows its exit
                # code: stderr must also match the declared output contract.
                for name in ('pacman', 'yay', 'sudo', 'nix', 'nixos-rebuild', 'systemctl',
                             'rm', 'cp', 'mkdir', 'touch', 'chmod', 'install', 'tee', 'sed'):
                    command = commands / name
                    command.write_text(f'#!{args.bash}\necho "forbidden command: {name}" >&2\nexit 97\n')
                    command.chmod(0o755)
                result = subprocess.run(
                    [str(args.bash), str(args.packaged / 'bin' / row['id']), *argv],
                    stdin=subprocess.DEVNULL, capture_output=True, text=True, timeout=5,
                    cwd=user,
                    env={'HOME': str(user), 'PATH': str(commands), 'LC_ALL': 'C.UTF-8',
                         'OMARCHY_PATH': str(args.packaged),
                         'XDG_CONFIG_HOME': str(user / '.config'),
                         'XDG_STATE_HOME': str(user / '.local/state'),
                         'XDG_CACHE_HOME': str(user / '.cache')},
                )
                label = f'{row["id"]} {argv}'
                assert result.returncode == expected_rc, (label, result.returncode, result.stderr)
                if output == 'diagnostic':
                    expected = 'omahedron: stub: ' + row['reason']
                    assert result.stdout.splitlines() and result.stdout.splitlines()[0] == expected, (label, result.stdout)
                    assert not result.stderr, (label, result.stderr)
                elif output == 'silent':
                    assert not result.stdout and not result.stderr, (label, result.stdout, result.stderr)
                else:
                    assert not result.stdout and result.stderr.startswith('Usage: omarchy-snapshot '), (label, result.stdout, result.stderr)
                assert snapshot(user) == {}, (label, 'stub changed user state', snapshot(user))
                count += 1
    print(f'Validated {len(stubs)} stub commands across {count} invocations: prefixes, exit codes, silence and unchanged user state.')


if __name__ == '__main__':
    main()
