# Checklist — watch cadence

Not a calendar SLO. Run when a director or the human opens the tree, or on an automation later.

## Official

- [ ] GitHub releases: new tag?
- [ ] Security notes on omarchy.org / release text
- [ ] `quattro` commits since our pin (record count, do not merge to stable)
- [ ] Kernel packaging story still “branded linux package,” not a new family

## Port

- [ ] zicochaos/omarchy-nix commits worth cherry-picking as *glue*, not as a pin
- [ ] nixpkgs 26.05 / 26.11 status
- [ ] Hyprland ≥0.56 still resolvable on the paired nixpkgs

## Ledger hygiene

- [ ] No hand edits to COMPAT that are missing from JSON
- [ ] Open bump records not stuck in `bump-open` without an owner

If a new official tag exists, stop this list and open [bump.md](bump.md).
