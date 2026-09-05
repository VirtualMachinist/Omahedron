# Contributing

Internal fleet first, public later. Same rules either way.

1. Read [AGENTS.md](AGENTS.md) and [DECISIONS.md](DECISIONS.md).
2. Do not reopen accepted ADRs. File a new one.
3. Desktop pixels come from `omarchy-src`. OS mechanism comes from NixOS.
4. Classify scripts and packages in `schema/` in the same change as code.
5. Do not add a flake until Maintainer opens that work item against a zicochaos fork.
6. Do not use the brand Omarchanite here.

PR review list is at the bottom of AGENTS.md.

## Validation

Pull requests and pushes to `main` run flake evaluation, formatting, the
Omarchy package build, and 18 non-VM checks. Full system builds and the
Fish, desktop, and UX VM suites run through the `ci` workflow's manual
`validation` input:

```sh
gh workflow run ci.yml --ref <branch> -f validation=all
```

`all` builds the example NixOS system, then runs all three VM suites on the
same runner. Use `system`, `fish`, `desktop`, or `ux` to select one target;
`preflight` only checks the runner, and `light` repeats the normal PR checks.
The full jobs require at least 35 GiB free disk space, and VM runs first
verify that native x86_64 KVM can create a VM. Build logs are retained as
workflow artifacts for seven days.

On a native x86_64 Linux builder, the equivalent full validation is:

```sh
nix build -L .#nixosConfigurations.example.config.system.build.toplevel
nix flake check -L
```

A successful VM run is a pre-gate. Complete the [Latitude checklist](checklists/metal.md)
before claiming verified desktop UX or publishing a product tag.

For ledger changes or an upstream bump, run `nix build -L .#checks.x86_64-linux.omarchy-ledgers`. This validates the JSON schemas against the pinned source and evaluated module, then runs mutation fixtures that must fail on inventory, classification, pin, attribute and option drift. See [the schema contract](docs/SCHEMA.md).
