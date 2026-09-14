---
name: nix-forensics
description: >
  Use when a NixOS rebuild, flake check, or evaluation fails on Omahedron:
  --show-trace, nix log, journalctl, nix why-depends, path-info, infinite
  recursion, option collisions, hash mismatches, failed switch. Not for a
  healthy rebuild (nix-rebuild) or writing options (nix-module).
---

# Rebuild / eval forensics

Failed switch is a **read-then-classify** loop (odoom: hashes and drv paths only from tool output).

## Observe first

```bash
sudo nixos-rebuild dry-activate --flake <flake>#<host> --show-trace
nix flake check <flake> --show-trace
journalctl -eu nixos-rebuild -n 80 --no-pager
ls -lt /nix/var/log/nix/drvs 2>/dev/null | head
```

If a drv path appears in the error, `nix log <drv>` is the body. Do not guess the log.

## Strategies (classify, then one fix)

| Class | Signals | Fix |
|---|---|---|
| **eval** | infinite recursion, `option already defined`, missing attr, type mismatch | **nix-module** — smallest revert or `mkForce`; do not switch |
| **fetch** | hash mismatch, `specified hash` vs `got` | take **got** from the error (tool result); never invent SRI |
| **build** | builder failed, gcc/cmake, missing dep | `nix log <drv>`; `nix why-depends /run/current-system <bad-pkg>` |
| **activate** | switch built but activation failed | `journalctl -eu nixos-rebuild`; failed systemd units |
| **locator** | wrong flake / missing `nixosConfigurations.<host>` | **nix-flake** G0; fail closed |
| **stub-misread** | `omahedron: stub:` then the agent wrote `/etc` | **omahedron-compat** — set the named option instead |

## Tool loop

1. Capture the **full** error (`--show-trace`). Do not retry switch yet.
2. Classify (table above). One class.
3. Pull evidence: `nix log`, journal, the cited `.nix` file (read current bytes).
4. Patch the consumer flake/module — not `$OMARCHY_PATH`.
5. Eval: `nix flake check` then dry-activate. Only then switch (**nix-rebuild**).
6. If still red, stop and show the trace. Do not `nix-collect-garbage -d` as a fix.

```bash
nix log /nix/store/<drv>
nix why-depends /run/current-system nixpkgs#hello
nix path-info -Sh /run/current-system
```

## Fail recipes

**Infinite recursion** — a module imports itself or `osConfig` is mirrored into the option that gates `mkIf cfg.enable`. Read the cycle in the trace; Omahedron HM already avoids `omarchy = osConfig.omarchy` inside `mkIf cfg.enable`.

**Hash mismatch** — use the `got sha256-…` from the error. Rebuild. Do not copy a hash from chat memory.

**Option collision** — two assignments without `mkMerge`/`mkForce`. Read both files, keep one winner.

**Activation failed after a successful build** — generation exists but current-system did not switch. `journalctl`; fix the unit; `test` then `switch`.

**Rollback after a bad switch** — `omarchy rollback`. `$HOME` stays dirty; say so.

## Eval

Dry-activate exits 0. The original error string is gone from a fresh `--show-trace`. Switch only after that.

## Out of scope

Healthy switch (nix-rebuild). Channel/pin choice (omahedron-pins). Desktop rice (`omarchy`).
