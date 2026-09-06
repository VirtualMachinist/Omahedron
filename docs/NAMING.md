# Naming

| String | Use |
|---|---|
| Omahedron | Product / distro name. Human-facing. |
| Hedronite | Org / company. |
| omahedron | Repo, flake attribute, tag prefix (`omahedron-4.0.2`). |
| `omarchy.*` | Nix option namespace inherited from zicochaos. Do not rename in v1. |
| omarchy-src | Flake input that vendors basecamp/omarchy. |
| nix-omarchy | Category descriptor in prose only. |
| Omarchanite | **Forbidden in this repo.** Other substrate, TBD. |
| Omarchy | Upstream product. Always “upstream” or “official” when compared. |
| Omarchs | People who run Omarchy. The community's own word; use it for the audience, never as a product name. |
| Omachron | The Omahedron release schedule: trailing Omarchy's stable tags, patch and security tags with no soak, minor and major after the follow-up train stops. Policy in [CHANNELS.md](CHANNELS.md). |

Module option names stay `omarchy.enable` so we do not break the zicochaos consumer shape on day one. Branding lives in README, greeter copy, and changelog.

## Product mark

The Omahedron mark (lime and dark-green isometric cube on black) is Hedronite's product identity. Not an Omarchy or NixOS mark; separate from the Hedronite gold seal on hedronite.com. Files and usage: [brand/](brand/).
