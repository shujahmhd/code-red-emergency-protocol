# Code Red - Emergency Protocol (Claude Code skill)

A **panic-button skill for [Claude Code](https://claude.com/claude-code) on Windows** that instantly wipes your Claude data while keeping the skills you choose.

> ## ⚠️ WARNING
> This **permanently deletes files with no confirmation and no undo.** It is intended as a deliberate "nuke my Claude setup" button. Read the script before you run it. Use at your own risk.

## What it does

When triggered, it:

1. Deletes every skill in `~/.claude/skills` **except** the ones in your keep-list.
2. Wipes `~/.claude` data: `projects` (which includes the **memory** store), `sessions`, `session-env`, `shell-snapshots`, `backups`, `.last-cleanup`.
3. **Self-destructs** — removes its own skill folder as the last step.

Anything **outside** `~/.claude` (your real projects, apps, documents) is **never touched**.

## Install

Copy the skill into your Claude Code skills folder:

```powershell
$dest = "$env:USERPROFILE\.claude\skills\code-red-emergency-protocol"
New-Item -ItemType Directory -Force $dest | Out-Null
Copy-Item .\SKILL.md, .\code-red.ps1 $dest
```

## Configure

Open `code-red.ps1` and edit the keep-list near the top:

```powershell
$keepSkills = @("build-site", "ui-ux-pro-max")   # skills to PRESERVE
```

## Run

Either tell Claude **"run code red"**, or run it directly:

```powershell
powershell -ExecutionPolicy Bypass -File "$env:USERPROFILE\.claude\skills\code-red-emergency-protocol\code-red.ps1"
```

## Dry run (see what it *would* delete, without deleting)

```powershell
$claude = "$env:USERPROFILE\.claude"; $keep = @("build-site","ui-ux-pro-max"); $self="code-red-emergency-protocol"
Get-ChildItem "$claude\skills" -Directory | ForEach-Object {
    $v = if ($keep -contains $_.Name) {"KEEP"} elseif ($_.Name -eq $self) {"DELETE (self)"} else {"DELETE"}
    "[{0,-13}] {1}" -f $v, $_.Name
}
```

## License

MIT — see [LICENSE](LICENSE).
