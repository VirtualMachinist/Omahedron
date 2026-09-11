# Agent surface

Short contract for directors, Cursor/Cline subagents, and other automation touching this port. Full bar: [COMPETE.md](COMPETE.md) §2.11 and §3.6.

## Stub banners

When an `omarchy-*` command is a stub, na, wrap, or host decline, the **first line of stdout** matches:

```
^omahedron: (stub|na|wrap|host): [a-z0-9-]+$
```

Examples:

```
omahedron: stub: nixos-declarative
omahedron: na: pacman
```

A human sentence follows. Ledger class and `reason` in [schema/scripts.lock.json](../schema/scripts.lock.json) are authoritative; do not invent explanations. CI greps packaged bodies and exercises runtime output (`checks/stub_banners.py`, `checks/stub_output.py`).

Silent no-ops (for example `omarchy-theme-set-browser`, called from `omarchy-theme-set` on every theme change) are listed in those checks and do not print a banner.

## Lapis coexistence

If [Lapis](https://github.com/VirtualMachinist/lapis) (or any vault RAG) is installed in the environment:

- **Notes stay files** — Markdown in the Atrium vault (or any path Lapis indexes). Read and write them with Lapis tools or normal file edits.
- **Omahedron is not a second vault** — this repository is a Nix flake and Omarchy vendor tree. Do not mirror COMPAT, ledgers, or user hypr config into a parallel note system unless the human asks for documentation.
- Prefer Lapis `search` / `neighbors` over blind greps of the vendored tree when working from the vault; cite upstream paths (`bin/omarchy-…`, `default/hypr/…`) when changing desktop behavior.

## Nix verbs

Search / add / remove / apply / update: one page, G0 locator, `omarchy-*` pixels — [NIX-VERBS.md](NIX-VERBS.md).
