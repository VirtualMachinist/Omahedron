# Contributing

1. Read [AGENTS.md](AGENTS.md) and [DECISIONS.md](DECISIONS.md).
2. Do not reopen accepted ADRs. File a new one.
3. Theme changes belong in `themes/`. The archived desktop port in `legacy/os-port/` is not the product.
4. Do not set `allowUnfree` as a default.
5. Do not use the brand Omarchanite.

## Validation

Pull requests and pushes to `main` run the theme-layout script, `nix flake show`, `nix fmt`, `nix flake check`, and a build of `.#omahedron-themes`.

```sh
bash checks/theme-layout.sh
nix flake check
nix build .#omahedron-themes
```

That is the gate for this repository. The NixOS VM suites in `legacy/os-port/` are not part of it.
