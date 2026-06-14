# 🔴 Code Red — Emergency Protocol

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
![Platform](https://img.shields.io/badge/platform-Windows-0078D6?logo=windows)
![Shell](https://img.shields.io/badge/PowerShell-5391FE?logo=powershell&logoColor=white)
![Type](https://img.shields.io/badge/Claude%20Code-skill-8A2BE2)

A **panic-button skill for [Claude Code](https://claude.com/claude-code) on Windows** that instantly wipes your Claude data while keeping the skills you choose — then deletes itself.

> ## ⚠️ WARNING — read this first
> This **permanently deletes files. There is no undo.** It is a deliberate "nuke my Claude setup" button. The wipe only runs when you supply an exact passphrase, and a `-DryRun` mode lets you preview it safely. **Use at your own risk.**

---

## ✨ Features

- 🧹 **One-shot wipe** of your `~/.claude` data + installed skills
- 🛟 **Keep-list** — preserve any skills you name (default: `build-site`, `ui-ux-pro-max`)
- 🔒 **Passphrase guard** — won't fire by accident
- 👀 **Dry-run mode** — see exactly what would be deleted, delete nothing
- 💣 **Self-destructs** — removes its own skill folder as the final step
- 🔧 **Configurable** via parameters — keep-list, target folder, no code edits needed
- 🛡️ **Scoped** — anything outside `~/.claude` is never touched

## 🧨 What it deletes

| Deleted | Kept |
|---|---|
| Skills in `~/.claude/skills` **not** on the keep-list | Skills on the keep-list |
| `projects` (includes **memory**), `sessions`, `session-env`, `shell-snapshots`, `backups`, `.last-cleanup` | Everything **outside** `~/.claude` (your real projects, apps, files) |
| Itself (`code-red-emergency-protocol`) | — |

## 📦 Install

Copy the skill into your Claude Code skills folder:

```powershell
$dest = "$env:USERPROFILE\.claude\skills\code-red-emergency-protocol"
New-Item -ItemType Directory -Force $dest | Out-Null
Copy-Item .\SKILL.md, .\code-red.ps1 $dest
```

## 👀 Preview (dry run — deletes nothing)

```powershell
.\code-red.ps1 -DryRun
```

## 🚀 Run

The wipe only happens with the exact passphrase:

```powershell
.\code-red.ps1 -Confirm "CODE RED CONFIRM WIPE"
```

Or just tell Claude **"run code red"** — the skill will confirm with you, then run it.

## ⚙️ Options

| Parameter | Purpose | Default |
|---|---|---|
| `-Confirm <text>` | Passphrase. Must equal `CODE RED CONFIRM WIPE` to delete | — |
| `-DryRun` | Preview only, no deletion | off |
| `-KeepSkills a,b` | Skill folders to preserve | `build-site, ui-ux-pro-max` |
| `-ClaudeDir <path>` | Location of the `.claude` folder | `$env:USERPROFILE\.claude` |

```powershell
# Keep extra skills during the wipe
.\code-red.ps1 -Confirm "CODE RED CONFIRM WIPE" -KeepSkills build-site,ui-ux-pro-max,my-skill
```

## 📄 License

MIT — see [LICENSE](LICENSE).
