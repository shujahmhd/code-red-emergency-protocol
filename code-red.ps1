<#
.SYNOPSIS
    Code Red - emergency wipe of Claude Code data on Windows.

.DESCRIPTION
    Deletes installed skills (except a keep-list) and the .claude data folders
    (projects/memory, sessions, caches, backups), then self-destructs.
    Passphrase-guarded so it cannot fire by accident. Anything OUTSIDE the
    .claude folder is never touched.

.PARAMETER Confirm
    Exact passphrase required to actually delete: "CODE RED CONFIRM WIPE".
    Without it (and without -DryRun) the script aborts and deletes nothing.

.PARAMETER DryRun
    List everything that WOULD be deleted, without deleting anything.
    No passphrase needed for a dry run.

.PARAMETER KeepSkills
    Skill folder names to preserve. Default: build-site, ui-ux-pro-max.

.PARAMETER ClaudeDir
    Path to the .claude folder. Default: $env:USERPROFILE\.claude.

.EXAMPLE
    .\code-red.ps1 -DryRun
    Preview the wipe safely.

.EXAMPLE
    .\code-red.ps1 -Confirm "CODE RED CONFIRM WIPE"
    Perform the wipe.

.EXAMPLE
    .\code-red.ps1 -Confirm "CODE RED CONFIRM WIPE" -KeepSkills build-site,my-skill
    Wipe but keep extra skills.

.LINK
    https://github.com/shujahmhd/code-red-emergency-protocol
#>
param(
    [string]$Confirm,
    [switch]$DryRun,
    [string[]]$KeepSkills = @("build-site", "ui-ux-pro-max"),
    [string]$ClaudeDir = (Join-Path $env:USERPROFILE ".claude")
)

$ErrorActionPreference = "SilentlyContinue"
$PASSPHRASE = "CODE RED CONFIRM WIPE"
$self       = "code-red-emergency-protocol"

function Write-Line($msg, $color = "Gray") { Write-Host $msg -ForegroundColor $color }

Write-Line ""
Write-Line "  ####  ###  ###  ####    ###  ####  ###  " Red
Write-Line "  #    # # # #  # #       #  # #     # # # " Red
Write-Line "  ###  # # # #  # ###     ###  ###   # # # " Red
Write-Line "  #    #   # #  # #       # #  #     #   # " Red
Write-Line "  ####  ### ###  ####    #  # ####  ### # " Red
Write-Line "  EMERGENCY PROTOCOL - Claude Code wipe" Red
Write-Line ""

# ---- Build the deletion plan ----------------------------------------------
$skillsDir = Join-Path $ClaudeDir "skills"
$dataItems = @("projects", "sessions", "session-env", "shell-snapshots", "backups", ".last-cleanup")

$plan = New-Object System.Collections.Generic.List[string]

Get-ChildItem $skillsDir -Directory -Force |
    Where-Object { $KeepSkills -notcontains $_.Name -and $_.Name -ne $self } |
    ForEach-Object { $plan.Add($_.FullName) }

foreach ($item in $dataItems) {
    $p = Join-Path $ClaudeDir $item
    if (Test-Path $p) { $plan.Add($p) }
}

# Self-destruct goes LAST.
$selfPath = Join-Path $skillsDir $self
$selfQueued = Test-Path $selfPath

Write-Line "Target .claude folder : $ClaudeDir"
Write-Line "Skills preserved      : $($KeepSkills -join ', ')"
Write-Line "Items queued          : $($plan.Count + [int]$selfQueued)" Yellow
Write-Line ""

if ($plan.Count -eq 0 -and -not $selfQueued) {
    Write-Line "Nothing to delete. Exiting." Green
    exit 0
}

# ---- Dry run: list and exit ------------------------------------------------
if ($DryRun) {
    Write-Line "DRY RUN - nothing will be deleted:" Cyan
    foreach ($t in $plan) { Write-Line "  WOULD DELETE: $t" }
    if ($selfQueued) { Write-Line "  WOULD DELETE: $selfPath  (self-destruct, last)" }
    Write-Line ""
    Write-Line "Re-run with -Confirm `"$PASSPHRASE`" to perform the wipe." Cyan
    exit 0
}

# ---- Passphrase guard ------------------------------------------------------
if ($Confirm -ne $PASSPHRASE) {
    Write-Line "ABORTED - passphrase required. Nothing was deleted." Yellow
    Write-Line "To wipe, re-run with:  -Confirm `"$PASSPHRASE`"" Yellow
    Write-Line "To preview safely, re-run with:  -DryRun" Yellow
    exit 1
}

# ---- Execute ---------------------------------------------------------------
$deleted = 0
foreach ($t in $plan) {
    Remove-Item $t -Recurse -Force
    if (-not (Test-Path $t)) { Write-Line "  deleted: $t"; $deleted++ }
    else { Write-Line "  FAILED : $t" Yellow }
}

# Self-destruct last (script is already in memory, safe on Windows).
if ($selfQueued) {
    Write-Line "  deleting (self-destruct): $selfPath"
    Remove-Item $selfPath -Recurse -Force
    $deleted++
}

Write-Line ""
Write-Line "=== CODE RED complete: $deleted item(s) removed ===" Red
Write-Line "Preserved: $($KeepSkills -join ', ') (and everything outside $ClaudeDir)"
