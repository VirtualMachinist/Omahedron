"""Mutation tests: the real pinned inputs must pass, independent drift must fail."""
import argparse
import copy
import json
from pathlib import Path
import shutil
import tempfile
import unittest

from ledgers import read_json, validate


class LedgerTests(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        root = Path(self.tmp.name)
        self.repo, self.upstream, self.packaged = [root / name for name in ('repo', 'upstream', 'packaged')]
        self.repo.mkdir()
        for source in ARGS.repo.iterdir():
            if source.name == 'schema':
                shutil.copytree(source, self.repo / source.name)
            elif source.name == 'flake.lock':
                shutil.copyfile(source, self.repo / source.name)
            else:
                (self.repo / source.name).symlink_to(source)
        shutil.copytree(ARGS.upstream / 'bin', self.upstream / 'bin')
        (self.upstream / 'install').mkdir()
        for source in (ARGS.upstream / 'install').glob('*.packages'):
            shutil.copyfile(source, self.upstream / 'install' / source.name)
        shutil.copytree(ARGS.packaged / 'bin', self.packaged / 'bin')
        # Store files are read-only. Mutations operate solely on copied fixtures.
        for directory in (self.repo / 'schema', self.upstream, self.packaged):
            directory.chmod(directory.stat().st_mode | 0o200)
            for file in directory.rglob('*'):
                file.chmod(file.stat().st_mode | 0o200)
        self.scripts = read_json(self.repo / 'schema/scripts.lock.json')
        self.packages = read_json(self.repo / 'schema/packages.map.json')
        self.evidence = copy.deepcopy(read_json(ARGS.evidence))

    def row(self, name):
        return next(row for row in self.scripts['scripts'] if row['id'] == name)

    def errors(self):
        for name, value in [('scripts.lock', self.scripts), ('packages.map', self.packages)]:
            (self.repo / f'schema/{name}.json').write_text(json.dumps(value))
        return validate(self.repo, self.upstream, self.packaged, self.evidence)

    def fails(self, message):
        self.assertTrue(any(message in error for error in self.errors()), message)

    def test_real_inputs(self):
        self.assertEqual(self.errors(), [])

    def test_new_nonmutating_upstream_command(self):
        (self.upstream / 'bin/omarchy-new-command').write_text('#!/bin/bash\necho hello\n')
        self.fails('upstream scripts: unclassified/missing omarchy-new-command')

    def test_removed_upstream_command(self):
        (self.upstream / 'bin/omarchy-version').unlink()
        self.fails('upstream scripts: stale/unexpected omarchy-version')

    def test_duplicate_script(self):
        self.scripts['scripts'].append(self.scripts['scripts'][0])
        self.fails('scripts: duplicate')

    def test_invalid_script_class(self):
        self.row('omarchy-version')['class'] = 'maybe'
        self.fails("'maybe' is not one of")

    def test_pin_drift(self):
        self.packages['upstream_rev'] = '0' * 40
        self.fails('packages: revision differs from flake.lock')

    def test_evaluated_source_drift(self):
        self.evidence['upstream_rev'] = '0' * 40
        self.fails('evaluated input pin/revision differs')

    def test_na_is_not_shipped(self):
        self.row('omarchy-version').update({'class': 'na', 'user_visible': False})
        self.fails('packaged scripts: stale/unexpected omarchy-version')

    def test_command_not_executable(self):
        (self.packaged / 'bin/omarchy').chmod(0o644)
        self.fails('omarchy: packaged executable mode disagrees')

    def test_vendor_body_drift(self):
        (self.packaged / 'bin/omarchy').write_text('#!/bin/bash\necho different router\n')
        self.fails('omarchy: vendor body changed')

    def test_stub_reclassified_as_wrap(self):
        self.row('omarchy-dns')['class'] = 'wrap'
        self.fails('omarchy-dns: packaged stub body disagrees')

    def test_stub_body_removed(self):
        (self.packaged / 'bin/omarchy-dns').write_text('#!/bin/bash\necho arbitrary behavior\n')
        self.fails('omarchy-dns: packaged stub body disagrees')

    def test_runtime_class_drift(self):
        self.evidence['runtime']['scripts']['omarchy'] = {'class': 'declarative-note'}
        self.fails('omarchy: declarative-note requires stub')

    def test_new_port_helper(self):
        (self.packaged / 'bin/omarchy-nix-new').write_text('#!/bin/bash\nexit 0\n')
        self.fails('packaged scripts: stale/unexpected omarchy-nix-new')

    def test_missing_packaged_command(self):
        (self.packaged / 'bin/omarchy-version').unlink()
        self.fails('packaged scripts: unclassified/missing omarchy-version')

    def test_new_upstream_package(self):
        with (self.upstream / 'install/omarchy-other.packages').open('a') as file:
            file.write('\nnew-hardware-package\n')
        self.fails('upstream packages: unclassified/missing new-hardware-package')

    def test_new_package_list(self):
        (self.upstream / 'install/omarchy-new.packages').write_text('bat\n')
        self.fails('bat: package source lists differ')

    def test_stale_package(self):
        row = copy.deepcopy(self.packages['packages'][0])
        row['upstream'] = 'no-longer-upstream'
        self.packages['packages'].append(row)
        self.fails('upstream packages: stale/unexpected no-longer-upstream')

    def test_duplicate_package(self):
        self.packages['packages'].append(self.packages['packages'][0])
        self.fails('packages: duplicate')

    def test_unresolved_candidate_field(self):
        self.packages['nixpkgs_candidates'] = ['anything']
        self.fails('nixpkgs_candidates')

    def test_bad_attribute(self):
        self.evidence['packages']['bat']['valid'] = False
        self.fails('bat: nixpkgs attr bat does not evaluate')

    def test_stale_attribute_evidence(self):
        next(row for row in self.packages['packages'] if row['upstream'] == 'bat')['attr'] = 'missing-attr'
        self.fails('bat: package probe does not match')

    def test_default_package_removed(self):
        self.evidence['packages']['bat']['default'] = False
        self.fails('bat: bat is absent from default module')

    def test_bad_host_option(self):
        self.evidence['options']['services.printing.enable'] = False
        self.fails('cups: unknown NixOS option')

    def test_unmapped_local_package(self):
        self.evidence['local_packages'].append('new-local-app')
        self.fails('flake package coverage: unclassified/missing new-local-app')

    def test_missing_extra_evidence(self):
        self.packages['extra_packages'][0]['evidence'] = ['no-such-file.nix']
        self.fails('missing/unsafe repository evidence')

    def test_empty_inventory_fails_closed(self):
        for file in (self.upstream / 'install').iterdir():
            file.unlink()
        with self.assertRaisesRegex(ValueError, 'inventory is empty'):
            self.errors()

    def test_duplicate_json_key(self):
        fixture = Path(self.tmp.name) / 'duplicate.json'
        fixture.write_text('{"pin": "v4.0.2", "pin": "v4.0.3"}')
        with self.assertRaisesRegex(ValueError, 'duplicate JSON key pin'):
            read_json(fixture)


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    for name in ('repo', 'upstream', 'packaged', 'evidence'):
        parser.add_argument('--' + name, required=True, type=Path)
    ARGS = parser.parse_args()
    unittest.main(argv=['test_ledgers'], verbosity=2)
