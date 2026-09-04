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

Module option names stay `omarchy.enable` so we do not break the zicochaos consumer shape on day one. Branding lives in README, greeter copy, and changelog.
