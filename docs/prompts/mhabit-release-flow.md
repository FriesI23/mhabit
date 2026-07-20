# mhabit release-flow orchestrator

Call scripts/sub-prompts in order. Stop at confirmation gates. Procedural facts → wiki.

## Constraint

**Always invoke scripts, never hand-run.** Each stage has a designated script; manual commands are fallback only (script won't run → tell user → then hand-run). Do not substitute `flutter`/`make`/`git`/python for what a script does.

## Pin → Source of Truth

`version: HEAD` = floating. Resolve: `git log -1 --format=%H -- docs/wiki/Dev꞉-Push-To-New-Version.md`. Re-read SoT each time. Fixed hash = pinned, re-validate only on user bump.

SoT = `docs/wiki/Dev꞉-Push-To-New-Version.md` @ pinned commit. Covers steps 1–7 (gated at 7). Steps 8–9 + Post-1: **manual always** — never execute, point to wiki.

## Files & verification paths

| File/Path | Role | Scope |
|---|---|---|
| `pubspec.yaml` | version authority | — |
| `Makefile aio-full` | gen→fix→verify→test | — |
| `scripts/release_bump.{sh,cmd}` | Stage 1: `bump_version.py` confirm → `flutter clean && make aio-full` | — |
| `scripts/release_postgen.{sh,cmd}` | Stage 3: `release_postgen.py` → fastlane/Apple/Flatpak | — |
| `prompts/mhabit-release-notes.md` | Stage 2: all release-note content judgment | parent workspace |
| `fastlane/metadata/android/*/changelogs` | F-Droid | stable |
| `android/…/f_store/fastlane/metadata/android/*/changelogs` | Google Play | stable + beta |
| `ios/fastlane`, `macos/fastlane` | Apple | stable |
| `configs/flatpak_builder/*.metainfo.xml` | Flatpak | stable + beta |
| `flatpak/*.metainfo.xml` | Flathub | stable only; no diff on beta is expected (`-pre` stripped) |

After Stage 3, verify ALL paths with `git status`/`git diff` — don't trust exit code.

## Pre-flight

If stable-vs-pre/beta or mode (ask/plan/execute) not stated → ask via interactive choice. Never infer.

## Rules

| # | Rule |
|---|---|
| R1 | stable vs pre/beta: **user's call**, never infer |
| R2 | **Version+Build Number**: both advance together. Bump patch → bump build. E.g. `1.25.2+168` → `1.25.3+169`. Show reasoning. |
| R3 | **Pre→Stable**: always bump patch+build, never just drop `-pre`. E.g. `1.25.6+171-pre` → `1.25.7+172`. |
| R4 | Stage 1: only `release_bump.{sh,cmd}`. No direct `pubspec.yaml`/`flutter`/`make`. Fail → surface verbatim. Fallback only if script can't run. |
| R5 | Stage 2: delegate to `mhabit-release-notes` Execute Mode. Stable + beta both get `CHANGELOG.md`/`zh.md`. That prompt owns deleting superseded `-pre` sections. |
| R5a | **Changelog sort order**: after merging entries (stable supersedes `-pre`), sort by category: **Feature → Fix → Other**. Within each category, sort by PR# ascending; entries without PR# sort after those with. |
| R6 | Stage 3: only `release_postgen.{sh,cmd} --release\|--pre`. No direct `gen_*.sh`. Then verify paths. Fallback only if script can't run. |
| R7 | **Stage 3 recovery**: if validate warnings appear (length>500, platform keywords), **never accept skips**. |
| R7a | Run generator py scripts **without `--validate`** to get raw files. |
| R7b | >500 chars: compress (shorten descriptions, drop redundant wording). Preserve all entries. Verify: `wc -m <file>` < 500. |
| R7c | Platform keywords: remove only lines with `android\|windows\|linux`. Keep rest. Verify: `grep -ci` = 0. |
| R7d | Run `scripts/gen_flatpak_info.sh` separately if Flatpak unchanged in `git diff`. |
| R8 | **Never delete old build-numbered files** (e.g. `171.txt`). Each is a historical record. Generators add new files alongside old ones — no pre-cleaning. If stale deletion markers appear in staging, `git restore --staged <file>` only. |
| R9 | Stage 4 (step 7: commit+tag+push) **always gated**: stop, ask. Skip only with standing session auto-upload auth. One "yes" = one gate only. |
| R10 | Steps 8–9 + Post-1: **manual forever**, never execute. Point to wiki. |
| R11 | Confirm before **every** stage transition — never auto-chain. |

## Modes

| Mode | Behavior | Output |
|---|---|---|
| **Ask** | Read-only. Inspect version, tags, gen paths, doc state. | Current stage, outstanding work, next action. |
| **Plan** | No edits. Confirm mode, compute version+build with reasoning, list Stages 1–3 commands+gates, note Stage 4 is gated. | Step plan + validation plan + recommended next. |
| **Execute** | Run Stages 1→3 per rules, stop at each gate. After Stage 3, ask about Stage 4 (unless standing auto-upload). | Per stage: outcome, what needs confirming, next. |

{{{input}}}
