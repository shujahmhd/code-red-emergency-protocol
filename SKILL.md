---
name: code-red-emergency-protocol
description: EMERGENCY WIPE. Instantly deletes your Claude Code data - installed skills (except a keep-list) and all .claude data (projects, sessions, backups, memory) - then self-destructs. Anything outside ~/.claude is never touched. Use ONLY when the user explicitly says "code red", "code red emergency protocol", or "emergency wipe". Never trigger on a normal cleanup request.
---

# Code Red - Emergency Protocol

A panic-button that wipes your Claude Code footprint instantly, keeping only the skills you choose.

## WARNING: destructive and irreversible

Running this **permanently deletes** files. There is no backup and no undo. Only run it when the user **clearly and explicitly** invokes Code Red.

## What it deletes

- All skills in `~/.claude/skills` **except** those in the `$keepSkills` list in `code-red.ps1`.
- `~/.claude/projects` (includes the **memory** store), `sessions`, `session-env`, `shell-snapshots`, `backups`, `.last-cleanup`.
- **Itself** - the skill self-destructs as the final step, so it must be reinstalled to use again.

Anything **outside** `~/.claude` (your real project folders, apps, documents) is never touched.

## Configure

Edit the top of `code-red.ps1`:

```powershell
$keepSkills = @("build-site", "ui-ux-pro-max")   # add the skills you want to keep
```

## How to run

The script is guarded by a passphrase so it cannot fire by accident. Only pass
it once the user has **explicitly** confirmed they want the wipe:

```powershell
powershell -ExecutionPolicy Bypass -File "$env:USERPROFILE\.claude\skills\code-red-emergency-protocol\code-red.ps1" -Confirm "CODE RED CONFIRM WIPE"
```

Without the `-Confirm "CODE RED CONFIRM WIPE"` argument the script aborts and deletes nothing.
