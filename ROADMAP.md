# ROADMAP.md

The product is the Hedron theme pack, then plugins. The NixOS desktop port is archived.

## Now — theme pack (ADR-0027)

- [x] `themes/hedron` and `themes/hedron-light` with wallpapers and stock theme files
- [x] README leads with `~/.config/omarchy/themes/` and `omarchy theme set`
- [x] Thin flake: overlay, theme package, opt-in Home Manager module
- [x] NixOS desktop port moved to [legacy/os-port/](legacy/os-port/) and dropped from root CI
- [x] Editor stubs name published schemes (Kanagawa, Catppuccin Latte)

## Next — plugins

Ship a plugin only when its files exist in this repo and the README can tell a stranger how to enable it on stock Omarchy.

- [Facet](https://github.com/Hedronite/facet)
- [Geode](https://github.com/Hedronite/geode)
- [Lapis](https://github.com/Hedronite/lapis-lattice)
- [Hedronos](https://github.com/Hedronite/hedronos) / [fullstack-lab](https://github.com/Hedronite/fullstack-lab)

Each one gets a flake output next to the themes. The default install stays free of `allowUnfree`.

## Archived — NixOS desktop port

Landed through tag [`omahedron-4.0.3`](https://github.com/VirtualMachinist/Omahedron/releases/tag/omahedron-4.0.3) (Omarchy v4.0.3). Tree: [legacy/os-port/](legacy/os-port/). Root CI does not build it. New desktop-port work needs a new ADR; it is not the roadmap above.
