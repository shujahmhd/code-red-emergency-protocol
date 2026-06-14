# ============================================================================
#  CODE RED - EMERGENCY PROTOCOL
#  Instant wipe of your Claude Code data. NO confirmation. NO undo.
#
#  Deletes installed skills (except a keep-list) and the .claude data folders
#  (projects/memory, sessions, caches, backups). Anything OUTSIDE ~/.claude is
#  never touched. The skill self-destructs as the final step.
# ============================================================================

param(
    # Safety guard: the wipe only runs if this exact passphrase is supplied.
    [string]$Confirm
)

$ErrorActionPreference = "SilentlyContinue"

$PASSPHRASE = "CODE RED CONFIRM WIPE"
if ($Confirm -ne $PASSPHRASE) {
    Write-Host "Code Red ABORTED - passphrase required." -ForegroundColor Yellow
    Write-Host "Nothing was deleted. To actually wipe, re-run with:" -ForegroundColor Yellow
    Write-Host "  -Confirm `"$PASSPHRASE`"" -ForegroundColor Yellow
    exit 1
}

# ---- CONFIG: edit to taste ------------------------------------------------
$claude     = Join-Path $env:USERPROFILE ".claude"   # your Claude data folder
$keepSkills = @("build-site", "ui-ux-pro-max")       # skills to PRESERVE
$self       = "code-red-emergency-protocol"          # this skill's folder name
# ---------------------------------------------------------------------------

Write-Host "=== CODE RED: wiping Claude data ===" -ForegroundColor Red

# 1. Delete non-kept skills (leave self for the very end so this script keeps running).
Get-ChildItem (Join-Path $claude "skills") -Directory -Force |
    Where-Object { $keepSkills -notcontains $_.Name -and $_.Name -ne $self } |
    ForEach-Object {
        Write-Host "  deleting skill: $($_.Name)"
        Remove-Item $_.FullName -Recurse -Force
    }

# 2. Delete Claude data folders (projects/memory, sessions, backups, caches).
$wipe = @("projects", "sessions", "session-env", "shell-snapshots", "backups", ".last-cleanup")
foreach ($item in $wipe) {
    $p = Join-Path $claude $item
    if (Test-Path $p) {
        Write-Host "  deleting: $item"
        Remove-Item $p -Recurse -Force
    }
}

Write-Host "Preserved skills: $($keepSkills -join ', ')"

# 3. Self-destruct: delete this skill's own folder LAST. The script is already
#    loaded in memory, so removing the file mid-execution is safe on Windows.
Write-Host "  deleting skill: $self (self-destruct)"
Remove-Item (Join-Path $claude "skills\$self") -Recurse -Force

Write-Host "=== CODE RED complete - this skill has removed itself ===" -ForegroundColor Red
