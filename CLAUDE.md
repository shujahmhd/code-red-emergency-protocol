# CLAUDE.md

Guidance for AI assistants (Claude Code and others) working in this repository.

## What this repository is

**Code Red — Emergency Protocol** is a single, self-contained **Claude Code
skill** for **Windows**. It is a passphrase-guarded "panic button" that
permanently wipes a user's Claude Code footprint under `~/.claude` — installed
skills (except a keep-list) plus data folders (projects/memory, sessions,
caches, backups) — and then deletes its own skill folder as the final step.

This is not an application with a build or test pipeline. It is a small
distributable skill: one PowerShell script plus its skill manifest and docs.

### ⚠️ This code is destructive by design

`code-red.ps1` **permanently deletes files with no undo.** When editing it,
assume every change is safety-critical. The two guardrails that must never be
weakened without an explicit user request are:

1. **Passphrase guard** — deletion only runs when `-Confirm` exactly equals
   the constant `CODE RED CONFIRM WIPE` (`code-red.ps1:102`).
2. **Scope guard** — only paths under `$ClaudeDir` (default
   `$env:USERPROFILE\.claude`) are ever touched. Never introduce a deletion
   target outside that folder.

`-DryRun` must always remain a no-op preview that deletes nothing
(`code-red.ps1:92`). When testing or demonstrating, use `-DryRun`; never run a
real wipe against a machine you care about.

## Repository layout

| File | Purpose |
|------|---------|
| `code-red.ps1` | The skill's implementation — the PowerShell wipe script. All behavior lives here. |
| `SKILL.md` | Claude Code skill manifest (YAML front matter + usage docs). Defines the skill `name`, `description`, and trigger conditions. |
| `README.md` | Human-facing documentation: features, install, usage, options. |
| `CHANGELOG.md` | Version history (currently at v2.0.0). |
| `LICENSE` | MIT, © shujah. |

There are no subdirectories, dependencies, package manifests, or CI config.

## How the script works

`code-red.ps1` runs in a fixed sequence:

1. **Parse params** — `-Confirm`, `-DryRun`, `-KeepSkills` (default
   `build-site, ui-ux-pro-max`), `-ClaudeDir` (default `~/.claude`).
2. **Build the deletion plan** — collects skill folders under
   `$ClaudeDir\skills` that are *not* on the keep-list and are not the skill
   itself, plus the fixed data items: `projects`, `sessions`, `session-env`,
   `shell-snapshots`, `backups`, `.last-cleanup`.
3. **Queue self-destruct last** — the skill's own folder
   (`code-red-emergency-protocol`) is always deleted last.
4. **Branch:**
   - `-DryRun` → list what would be deleted, exit 0.
   - `-Confirm` mismatch → abort, delete nothing, exit 1.
   - Correct passphrase → execute deletions, then self-destruct, print a
     summary count.

Key invariants when modifying the plan logic (`code-red.ps1:62-89`):
- The keep-list and the skill's own name always exclude folders from deletion.
- Self-destruct runs **after** everything else and only if the folder exists.
- The empty-plan case prints "Nothing to delete" and exits cleanly.

## Conventions

- **Language/platform:** Windows PowerShell 5+. Windows-only paths and cmdlets
  (`Join-Path`, `Get-ChildItem`, `Remove-Item`, `$env:USERPROFILE`).
- **Output style:** all console output goes through the `Write-Line` helper
  (`code-red.ps1:51`) with color arguments — match this rather than calling
  `Write-Host` directly.
- **Error handling:** `$ErrorActionPreference = "SilentlyContinue"`; deletions
  are verified after the fact with `Test-Path` and reported as `deleted` /
  `FAILED`.
- **Constants:** the passphrase (`$PASSPHRASE`) and self name (`$self`) are
  defined once near the top; reference them, don't hard-code duplicates.
- **Comment-based help:** the `<# .SYNOPSIS ... #>` block at the top powers
  `Get-Help .\code-red.ps1 -Full`. Keep it in sync with parameter changes.

## When you change behavior, update all four surfaces

Behavior is documented in four places that must stay consistent. A change to
parameters, defaults, or what gets deleted should be reflected in **all** of:

1. `code-red.ps1` — the implementation and its comment-based help block.
2. `SKILL.md` — options table and "What it deletes" section.
3. `README.md` — features, options table, examples.
4. `CHANGELOG.md` — add an entry; bump the version following semver.

The default keep-list (`build-site`, `ui-ux-pro-max`) and the data-items list
appear in multiple files — keep them identical everywhere.

## Testing / verifying changes

There is no automated test suite. To verify safely:

```powershell
# Syntax check without running
powershell -NoProfile -Command "& { [void][ScriptBlock]::Create((Get-Content -Raw .\code-red.ps1)) }"

# Preview against a throwaway .claude folder — deletes nothing
.\code-red.ps1 -DryRun -ClaudeDir C:\path\to\test-claude
```

Use `-ClaudeDir` pointed at a disposable fixture directory to exercise the real
deletion path without risking a real `~/.claude`. **Never** run a non-dry-run
wipe to "test" against your actual Claude Code install.

## Git workflow

- Default branch: `main`.
- Commit messages in history are concise and version-oriented (e.g.
  `v2.0.0: dry-run mode, parameters, deletion summary...`).
- Only commit and push when the user asks.

## The skill's trigger contract

Per `SKILL.md`, this skill must **only** activate when the user explicitly says
"code red", "code red emergency protocol", or "emergency wipe" — **never** on a
normal cleanup request. If you are operating as the running skill: always
preview with `-DryRun` first and require the user's explicit confirmation before
passing the passphrase.
