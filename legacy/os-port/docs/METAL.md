# Metal

What counts as verified UX.

## Machines

| Host | Role | Counts as |
|---|---|---|
| MacBook Air 24 GB | control plane | nothing desktop |
| Mac mini 16 GB / Studio 36 GB NixOS VMs | pre-gate | eval, check, maybe greeter |
| Dell Latitude 5420, 8 GB, Intel iGPU | ship gate | session, theme, menus, lock, first-run |

The Latitude already runs zicochaos omarchy-nix. First Omahedron metal pass is an upgrade of that box, lite-loaded.

## Doctrine

Bare-minimum hardware is canonical. Tools are installed. They do not all have to be open. Cloud Grok stays in the cloud. If Quickshell + Hyprland + terminal + one agent editor + a browser *can* start (not simultaneously at full load), the bump may pass.

Record memory pressure in the metal log anyway. A pass that leaves 50 MB free is a pass with a note, not a fail.

## Lies

These are not verification:

- VMSVGA VirtualBox
- QEMU software framebuffer
- “I saw the bar in a screenshot from the VM”
- `ps aux | grep quickshell` on a box that never drew a frame

zicochaos and the original brief both say software FB lies about Quickshell. Believe them.

GPU passthrough from a Mac is a future pre-gate improvement. It is not required to tag `omahedron-4.0.2`.

## Ship-gate actions

See [checklists/metal.md](../checklists/metal.md). Minimum:

1. Super+Enter opens the default terminal (foot unless the pin changed it)
2. Live theme swap changes colors, not only wallpaper
3. Launcher / menu actions that are `vendor` or `wrap` run
4. Lock and polkit prompt appear
5. First-run markers exist and do not loop
6. Update menu does not call pacman
7. Cursor and Grok launch paths resolve (they may then talk to the cloud)

## Hostname trap

zicochaos notes that some menu rebuild actions require `nixosConfigurations."$(hostname)"`. Hedronite host config for the Latitude must use the real hostname. Document that hostname in the first implementation PR. Do not put the hostname into the public module defaults.
