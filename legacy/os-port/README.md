# Archived NixOS desktop port

This directory is the Omahedron NixOS port as it stood when the repository became a theme pack ([ADR-0027](../../DECISIONS.md), 2026-09-21).

The product is the Hedron themes at the repository root. This tree is kept so the port's modules, ledgers, and docs stay in history without remaining the pitch.

The last tagged desktop release is [`omahedron-4.0.3`](https://github.com/VirtualMachinist/Omahedron/releases/tag/omahedron-4.0.3) (parity with Omarchy v4.0.3). That tag predates this archive move.

`flake.nix` here is the old entry point. Root CI does not build it. Evaluating it still pulls the Omarchy pin, Hyprland, and the NixOS modules.

```sh
nix flake metadata path:./legacy/os-port
```
