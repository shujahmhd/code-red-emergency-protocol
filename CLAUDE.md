# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repository is

This is a **Claude Code skill package**, not an application. It ships a single
destructive utility skill — `code-red-emergency-protocol` — that Windows users
install into `~/.claude/skills/`. When invoked, it wipes the user's Claude Code
data (`~/.claude` subfolders) and installed skills, then deletes its own skill
folder as the last step.

The repo has no build system, package manager, dependencies, or test suite —
it is three files that together define the skill:

- **`SKILL.md`** — the skill definition Claude Code loads. The YAML
  frontmatter (`name`, `description`) controls *when Claude auto-invokes this
  skill*; the body is the instructions Claude follows when running it
  (preview-first workflow, passphrase requirement, options table).
- **`code-red.ps1`** — the actual PowerShell implementation the skill shells
  out to.
- **`README.md`** — user-facing install/usage docs (GitHub-facing, not loaded
  by Claude Code).

Because `SKILL.md`'s frontmatter description is what triggers auto-invocation,
any change to the script's behavior (new flags, changed defaults, changed
deletion targets) must be mirrored in `SKILL.md`'s description and body, and
usually in `README.md`'s tables too. These three files describe the same
behavior at three levels (trigger condition, agent instructions, human docs)
and should never drift out of sync.

## Development workflow

There is no build/lint/test tooling in this repo (no `package.json`, no CI).
"Development" means editing `code-red.ps1` and keeping the docs in sync.

To exercise a change, run the script directly with PowerShell (Windows or
`pwsh` on other platforms):

```powershell
# Safe preview — lists what would be deleted, deletes nothing
.\code-red.ps1 -DryRun

# Preview against a throwaway directory instead of the real ~/.claude
.\code-red.ps1 -DryRun -ClaudeDir "C:\path\to\scratch\.claude"

# Full wipe (only with the exact passphrase)
.\code-red.ps1 -Confirm "CODE RED CONFIRM WIPE"

# View comment-based help
Get-Help .\code-red.ps1 -Full
```

**Always test destructive changes against a scratch `-ClaudeDir`, never the
real `~/.claude`.** There are no unit tests — verification is manual: run
`-DryRun` against a fake `.claude` tree with sample `skills/`, `projects/`,
`sessions/`, etc., and confirm the printed deletion plan matches expectations
before testing the real (`-Confirm`) path.

## Script architecture (`code-red.ps1`)

The script runs as a linear pipeline, in this order — preserve this order
when modifying it, since self-destruct depends on running last:

1. **Parse params**: `-Confirm`, `-DryRun`, `-KeepSkills` (default
   `build-site, ui-ux-pro-max`), `-ClaudeDir` (default `~/.claude`).
2. **Build the deletion plan** (a `List[string]` of paths) without deleting
   anything yet:
   - All subfolders of `<ClaudeDir>/skills` except those named in
     `-KeepSkills` and except the skill's own folder name
     (`code-red-emergency-protocol`, hardcoded in `$self`).
   - Fixed data items if present: `projects` (this includes Claude's
     memory store), `sessions`, `session-env`, `shell-snapshots`,
     `backups`, `.last-cleanup`.
   - The skill's own folder is tracked separately (`$selfQueued`) so it is
     always deleted **last**, since the running script lives inside it.
3. **Dry run branch**: if `-DryRun`, print the plan and exit 0 — no
   passphrase needed, nothing touched.
4. **Passphrase guard**: if `-Confirm` doesn't exactly equal
   `"CODE RED CONFIRM WIPE"`, abort with exit 1 and delete nothing.
5. **Execute**: `Remove-Item -Recurse -Force` each planned path, verifying
   removal; delete the self folder last; print a summary count.

Key invariants to preserve in any change:
- Anything **outside** `$ClaudeDir` must never be touched.
- Without the exact passphrase (and without `-DryRun`), the script must
  delete nothing.
- Self-destruct must remain the final action in the sequence.
- `$ErrorActionPreference = "SilentlyContinue"` is intentional (Windows/OneDrive
  file locks etc. shouldn't hard-fail the run); deletion success is verified
  per-item via `Test-Path` afterward, not via exceptions.

## Windows-only PowerShell conventions

- Written for Windows PowerShell (`$env:USERPROFILE`, backslash paths via
  `Join-Path`). Keep new path handling going through `Join-Path` rather than
  string concatenation.
- Uses comment-based help (`<# .SYNOPSIS ... #>`) at the top of the script —
  update it when parameters or behavior change, since it's the source for
  `Get-Help -Full`.
- Colors/banner output uses the local `Write-Line` helper
  (`Write-Host` wrapper); follow the same pattern for new output rather than
  calling `Write-Host` directly.

## Safety expectations when touching this skill

This skill is explicitly destructive and irreversible by design. When editing
it:
- Do not weaken the passphrase check, the dry-run path, or the "anything
  outside `~/.claude` is untouched" boundary without the user explicitly
  asking for that specific change.
- `SKILL.md`'s frontmatter `description` explicitly restricts auto-invocation
  to explicit user phrases ("code red", "code red emergency protocol",
  "emergency wipe") and says not to trigger on normal cleanup requests —
  preserve that restriction if you edit the description.
- Bump `CHANGELOG.md` (and the version implied by its `vX.Y.Z` headers) for
  any behavior change, matching the existing terse bullet style.
