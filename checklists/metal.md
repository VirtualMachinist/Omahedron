# Checklist — Latitude ship gate

Host: Dell Latitude 5420, 8 GB, Intel iGPU  
Doctrine: lite dogfood. Tools installed, not all loaded.  
VM results do not fill this form.

Pin under test: `v__.__.__` / `omahedron-__.__.__`  
Date:  
Operator:

## Session

- [ ] SDDM (or configured greeter) shows Omahedron/Omarchy theme
- [ ] Hyprland session starts via the same path as the module (uwsm if still used)
- [ ] Exactly one Quickshell desktop process owns bar / launcher / notifs / lock / polkit
- [ ] Super+Enter opens the default terminal
- [ ] Default bindings match the pinned tag for the actions we classify `vendor`/`wrap`

## Theme

- [ ] Live theme swap changes colors, not only wallpaper
- [ ] Restarting the shell keeps the chosen theme

## Menus and scripts

- [ ] Launcher opens
- [ ] A sample of `vendor`/`wrap` menu actions run
- [ ] A sample of `stub` actions print `omahedron: stub:` or `omahedron: na:` and do not call pacman
- [ ] Update action does not call pacman

## Lock / polkit / first-run

- [ ] Lock screen appears and unlocks
- [ ] Polkit prompt appears for one privileged action we still allow
- [ ] First-run markers exist and do not loop
- [ ] Identity came from Nix options or user metadata (no surprise TUI unless we chose C — we did not)

## Agents (lite)

- [ ] Cursor launch path resolves
- [ ] Grok launch path resolves (cloud backend is fine)
- [ ] No requirement to hold Cursor + Grok + browser + IDE all at full load

## Pressure notes (required even on pass)

- Free RAM after session + terminal + bar, approximate:
- Swap use:
- Anything that stuttered:

## Sign-off

- [ ] Sati accepts pixels
- [ ] Vini accepts “no pacman on PATH for update/install”
- [ ] Human operator initials:
