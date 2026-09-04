# Workspace

How Omahedron knowledge moves. This file is the handoff for humans and directors. It does not replace [SPEC.md](../SPEC.md) or [AGENTS.md](../AGENTS.md).

Five tools. Five jobs. Do not merge them.

| Tool | Job | May be messy | May be law |
|---|---|---|---|
| **Git** (this repo, then GitHub) | Constitution and the product | no | **yes** — only law |
| **Obsidian** | Fleet thinking space, shared with the human | **yes** | no |
| **Notion** | Omahedron operations workspace | slightly | process only |
| **Google Drive** | Blessed-file bridge | no | no — transport |
| **Gemini Notebook** (still called NotebookLM) | Closed-corpus librarian | no | only as “what these sources say” |

Google renamed NotebookLM to Gemini Notebook in July 2026. Same product. `notebooklm.google.com` redirects. This repo says **Gemini Notebook**.

There is no native Notion ↔ Gemini Notebook connector. Drive is the bridge. Public Notion URLs work and are forbidden for this project.

## Complementarity in one picture

```
Obsidian          hunches, director journals, arguments
     │
     │  (only after it should become process or law)
     ▼
Git / GitHub      SPEC, ADRs, schema, checklists, code
     │
     ├──► Notion           owners, bump state, work, metal logs
     │
     └──► Drive/blessed    living Docs + frozen PDFs
              │
              ▼
         Gemini Notebook   cited Q&A over a chosen pack
              │
              ├──► Obsidian     if it is still a hunch
              ├──► Notion Work  if it is a task
              └──► Git ADR      if it should become law
```

Rocky/Alma posture needs a librarian that will only speak from the blessed tag pack, a factory board that tracks bumps, a vault where you are allowed to be wrong, and a git tree that ships. Each tool is one of those. None of them is all four.

## Authority

Domain ownership in [AGENTS.md](../AGENTS.md) still applies. Workspace tools sit *under* that:

1. Desktop behavior → pinned `omarchy-src` in git.
2. OS correctness → NixOS modules + COMPAT ledger in git.
3. Release identity → [CHANNELS.md](CHANNELS.md) + lockfile in git.
4. Process (who, when, which bump state) → Notion.
5. Interpretation of a fixed source pack → Gemini Notebook, with citations.
6. Draft thinking → Obsidian.

If a Gemini Notebook answer and `DECISIONS.md` disagree, git wins and the notebook sources are stale. If Notion and git disagree on an ADR body, git wins and Merci refreshes the mirror. If Obsidian and anyone disagree, Obsidian is not evidence.

Subagents (Cursor, Cline, Kimi, GLM, MiniMax, OpenCode, Devin) read **git**. They do not need Notion or Gemini Notebook accounts. A director may paste a *cited* notebook answer into a PR. A vibe summary is not a source.

## Git / GitHub

**Holds:** `SPEC.md`, `DECISIONS.md`, `AGENTS.md`, `schema/*`, checklists, modules, flake, changelog.

**Does:** version the constitution with the code. Tag `omahedron-X.Y.Z`. PR review list in AGENTS.md.

**Does not:** task boards, audio briefings, fleet diary.

When the public remote exists, GitHub is the same tree plus issues/PRs. Issues are optional shadows of Notion Work, not a second constitution.

Accepted ADRs originate in git ([templates/adr.md](../templates/adr.md)). Notion copies them after merge.

## Obsidian

**Holds:** Hedronite fleet thinking. Director journals. Links across projects. Half-true hunches. Omahedron arguments that are not ready to be ADRs.

**Does:** let the human and the twelve directors think in public-to-each-other.

**Does not:** ship. Does not get uploaded wholesale into Gemini Notebook. Does not become “the wiki.”

Promotion path: vault note → (Eli) decide domain → git ADR or Notion Work row. Never vault note → tagged release.

Keep Latitude secrets, SSH, and host inventory out of any vault folder you might later export.

## Notion

Omahedron teamspace. Workshop, not library.

Use **typed databases**, not a deep page tree and not a Notion Wiki. One content type per database. Home page is linked views only.

| Database | One row | Required properties |
|---|---|---|
| Decisions | an ADR | Number, Status, Date, Domain, Git path, Superseded by |
| Bumps | an official Omarchy tag | State (`watching` → `bump-open` → `check-green` → `metal-green` → `tagged`), Kind, security?, checkboxes for the four gates |
| Work | a task | Director, Phase, Blocks tag?, Status, Git PR if any |
| Metal logs | one Latitude session | Pin, pass/fail, RAM note, operator |
| Sources catalog | one Gemini Notebook source | Notebook id, living vs snapshot, Drive path, last synced |

Do **not** duplicate `schema/scripts.lock.json` as a parallel ledger unless Merci is ready to generate one from the other. A stale Notion table that disagrees with JSON is worse than a link to git.

Mirror rule: Decisions and published handbook pages are copied *from git*. Notion does not originate law.

Skip paid Notion AI until the databases exist. Notion AI writes inside the workspace; it is not a citation engine. Do not let it rewrite ADR bodies.

Do not “Share to web” this teamspace so a notebook can scrape it.

## Google Drive

Transport only. Folder convention:

```
Omahedron/
  blessed/          # what notebooks may read
    constitution/   # living Google Docs, one file per git doc
    pins/
      v4.0.2/       # frozen PDFs: official notes, UPSTREAM at tag
  working/          # drafts, exports in progress — not notebook sources
  artifacts/        # Audio Overview files, reports you chose to keep
```

**Living:** Google Docs / Sheets / Slides added as Drive sources in Gemini Notebook. They resync. Use this for constitution files that still move (SPEC, DECISIONS, AGENTS, CHANNELS, COMPAT).

**Frozen:** PDF or a Doc labeled `frozen-vX.Y.Z`. Use this for official release notes and UPSTREAM.md at the pin. Do not let `quattro` HEAD overwrite a frozen pin folder.

Who writes `blessed/`: Merci after `tagged`, or after an accepted ADR merge. Not every vault save.

No secrets in `blessed/`.

## Gemini Notebook (NotebookLM)

Librarian. It will only speak from the sources in that notebook. That constraint is the feature.

Plan math (2026, subject to Google changing meters): free ≈ 50 sources/notebook; Plus 100; Pro 300; Ultra 500–600. Per source ≈ 500k words or 200 MB. Compute quotas refresh about every five hours. **Plus or Pro** once notebook 02 grows; Ultra is not required for this port.

### Notebooks (separate packs)

| Id | Name | Sources | Ask it |
|---|---|---|---|
| 01 | Constitution | blessed constitution Docs | “Can stable track quattro?” “Who signs metal-green?” |
| 02 | Upstream pin | frozen v4.0.2 notes, manual Updates/Security, zicochaos UPSTREAM/README at pin | “What in 4.0.2 breaks wraps?” |
| 03 | Active bump | current bump record + new official text | only while state is `bump-open` or later; archive after `tagged` |
| 04 | Metal | metal checklist + dogfood notes + VM-lie warning | “What counts as verified?” |
| 05 | Agent surface | optional; pin-era Omarchy skill docs + chosen Cursor/Grok notes | packaging, not vault chatter |

Do not build one mega-notebook. Mixing constitution with `quattro` HEAD is how the librarian starts lying.

URL imports are HTML text, not the page you saw (no figures, no nested apps). Split large trees. One concat PDF of the whole repo is worse than the files above.

### Outputs that match roles

- Eli / human: Audio Overview of 01 after an ADR batch. Commute brief, not a decision.
- Merci: report or table only after the lock JSON is a source.
- Leo: report → changelog draft → edit in **git**.
- Sati: Video Overview is not metal.

Deep Research may *propose* new upstream URLs. It may not become an ADR by itself. Vini/Merci decide whether a found page enters notebook 02 or 03.

Sharing: private Viewer/Editor only if a director needs the pack. Do not publish notebooks. Chat-view links still leave sources reachable; treat them as shared.

## Director map

| Director | Notion | Gemini Notebook | Obsidian | Git |
|---|---|---|---|---|
| Eli | Bumps, Work | 01 | fleet orchestration | freeze ADRs |
| Lea | Work | 02, 03 | glue scraps | modules, flake |
| Marci | Work | 02, 03 | vendor scraps | `pkgs/`, wraps |
| Vini | security bump rows | 02 | private threat notes | COMPAT honesty |
| Sati | Metal logs | 04 | pixel diary | no “VM passed” in changelog |
| Merci | Sources catalog | never the only copy of JSON | — | schema, bump records |
| Jupi | agent Work | 05 if it exists | — | HM agent glue |
| Leo | changelog draft page | 01, 02 reports | — | CHANGELOG, README banner |
| Elio, Oli, Uri, Nepi | out | out | vault only if invited | out |

## Anti-patterns

1. One notebook with vault + quattro + constitution.
2. Notion as constitution.
3. Gemini Notebook as project manager.
4. Uploading the Obsidian vault.
5. Public Notion links as the sync hack.
6. Notion AI rewriting ADRs without a git diff.
7. Audio/Video Overview as Latitude verification.
8. Hostname, SSH, or secrets in any synced Doc.
9. Subagents treating a notebook chat as `omarchy-src`.
10. Using the Omarchanite brand in this workspace (reserved; other substrate).

## Stand-up

Do this once. Then stop decorating.

1. Create Drive `Omahedron/blessed/{constitution,pins/v4.0.2}`.
2. Copy current git markdown into living Docs under `constitution/`.
3. Drop v4.0.2 official notes + zicochaos UPSTREAM as frozen files under `pins/v4.0.2/`.
4. Create Gemini Notebooks 01, 02, 04 from those folders. Skip 03 until a bump is open.
5. Create Notion teamspace + Decisions / Bumps / Work only.
6. Add five rows to Sources catalog so living vs frozen is visible.
7. One Audio Overview of 01. Then no more media until the first pin.

Refresh `blessed/constitution` when an ADR is accepted or when state becomes `tagged`. Not on every keystroke.

## When tools collide

| Collision | Winner |
|---|---|
| Notebook vs `DECISIONS.md` | git; refresh Drive sources |
| Notion ADR text vs git ADR | git; Merci mirrors |
| Obsidian note vs SPEC | git; note stays a note |
| Two notebooks disagree | the notebook whose sources match the question; do not average them |
| Notion Work “done” vs failing `nix flake check` | check; Work is wrong |

## Related

- [AGENTS.md](../AGENTS.md) — directors, domain ownership, voice
- [DECISIONS.md](../DECISIONS.md) — ADR-0001–0019
- [CHANNELS.md](CHANNELS.md) — bump state machine
- [FLEET.md](FLEET.md) — who touches the repo
- [METAL.md](METAL.md) — what verification is
