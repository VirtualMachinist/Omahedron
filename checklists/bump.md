# Checklist — official stable tag bump

Copy this into the bump record. Do not delete items. Mark `[x]` or `n/a` with a reason.

Pin target this run: `v__.__.__`  
Previous pin: `v__.__.__`  
Kind: security / patch / minor / major

## Open

- [ ] Official GitHub tag exists
- [ ] Release notes read (security vs feature)
- [ ] State moved to `bump-open` (Merci or Vini)
- [ ] No soak, or soak reason recorded (patch train still live)

## Diff

- [ ] `bin/`
- [ ] `default/`
- [ ] `themes/` (count synced)
- [ ] `shell/`
- [ ] `install/omarchy-*.packages`
- [ ] `default/omarchy/omarchy-menu.jsonc`
- [ ] `default/systemd/user/`
- [ ] agents skills if present
- [ ] `grep -rn 'cp ' "$SRC/bin/" | grep '\$OMARCHY_PATH'`
- [ ] `grep -rn '/usr/\|/etc/pacman\|pacman ' "$SRC/bin/"`

## Lock and glue

- [ ] `omarchy-src` updated to the **tag**, not `quattro`
- [ ] `--replace-fail` failures fixed or dropped with COMPAT note
- [ ] `schema/scripts.lock.json` updated; zero unclassified `omarchy-*`
- [ ] `schema/packages.map.json` updated
- [ ] `docs/COMPAT.md` matches JSON
- [ ] menu rewires / expected_removes rechecked
- [ ] one logical commit (or PR) for this rev + glue

## Verify

- [ ] `nix flake check`
- [ ] VM pre-gate (eval, import, session if possible)
- [ ] Latitude metal ([metal.md](metal.md))
- [ ] Cursor + Grok launch paths resolve (v1+)
- [ ] Update path does not invoke pacman

## Ship

- [ ] Changelog line: `parity with Omarchy vX.Y.Z; known gaps: …`
- [ ] Module identity fields: desktop / frozen date / channel
- [ ] Tag `omahedron-X.Y.Z`
- [ ] State `tagged`
- [ ] Credits still accurate
