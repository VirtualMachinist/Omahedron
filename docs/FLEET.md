# Fleet

How the twelve directors meet this repo. Detail lives in [AGENTS.md](../AGENTS.md).

```
Eli
 ├─ Lea     modules, flake, channels, CI eval
 ├─ Vini    security tags, stub honesty, no host pacman
 ├─ Marci   vendor tree, pkgs/, wraps
 ├─ Sati    pixels, metal truth
 ├─ Jupi    agent runtime glue (with Marci)
 ├─ Merci   schemas, inventories, bump records
 └─ Leo     README, changelog, credits

Out of tree unless Eli writes an ADR:
Elio, Oli, Uri, Nepi
```

Subagents (Cursor, Cline, Kimi K3, GLM, MiniMax, OpenCode, Devin, …) execute under a director card. They do not hold a second constitution.

## Human

One maintainer. Metal hands are the human’s. Agents do not get SSH to the Latitude unless the human says so in a later ADR.

Control plane: MacBook Air. Build horses: Mac minis and Studio VMs. Daily NixOS: Latitude 5420.

## Communication artifacts

| Event | Artifact |
|---|---|
| New official tag | bump record from template |
| Classification fight | ADR |
| Ship | changelog + `omahedron-X.Y.Z` tag |
| Security note | Vini forces `bump-open` |

## Load

Do not assign Uri to Hyprland. Do not assign Nepi to themes. Do not let Oli merge `pkgs/omarchy.nix`.
