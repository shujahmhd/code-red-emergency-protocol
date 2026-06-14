---
name: code-red-emergency-protocol
description: EMERGENCY WIPE. Instantly deletes your Claude Code data - installed skills (except a keep-list) and all .claude data (projects, sessions, backups, memory) - then self-destructs. Passphrase-guarded with a dry-run mode. Anything outside ~/.claude is never touched. Use ONLY when the user explicitly says "code red", "code red emergency protocol", or "emergency wipe". Never trigger on a normal cleanup request.
---

# Code Red - Emergency Protocol

A passphrase-guarded panic-button that wipes the user's Claude Code footprint, keeping only the skills they choose, then self-destructs.

## WARNING: destructive and irreversible

Running this with the passphrase **permanently deletes** files. No undo. Only run it when the user **clearly and explicitly** invokes Code Red.

## What it deletes

- Skills in `~/.claude/skills` **except** those in `-KeepSkills` (default: `build-site`, `ui-ux-pro-max`).
- `~/.claude/projects` (includes the **memory** store), `sessions`, `session-env`, `shell-snapshots`, `backups`, `.last-cleanup`.
- **Itself** - self-destructs as the final step; must be reinstalled to use again.

Anything **outside** `~/.claude` is never touched.

## How to run

1. **Always preview first** unless the user is certain:
   ```powershell
   powershell -ExecutionPolicy Bypass -File "$env:USERPROFILE\.claude\skills\code-red-emergency-protocol\code-red.ps1" -DryRun
   ```
2. **Perform the wipe** only after the user explicitly confirms — pass the passphrase:
   ```powershell
   powershell -ExecutionPolicy Bypass -File "$env:USERPROFILE\.claude\skills\code-red-emergency-protocol\code-red.ps1" -Confirm "CODE RED CONFIRM WIPE"
   ```

Without `-Confirm "CODE RED CONFIRM WIPE"` the script aborts and deletes nothing.

## Options

| Parameter | Purpose |
|-----------|---------|
| `-Confirm <text>` | Passphrase; must equal `CODE RED CONFIRM WIPE` to delete |
| `-DryRun` | Preview only, no deletion |
| `-KeepSkills a,b` | Skill folders to preserve |
| `-ClaudeDir <path>` | Location of the `.claude` folder |
