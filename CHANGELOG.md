# Changelog

## v2.0.0
- Added `-DryRun` mode to preview the wipe without deleting anything.
- Added `-KeepSkills` and `-ClaudeDir` parameters (configure without editing the script).
- Added a deletion summary (counts what was removed) and a startup banner.
- Comment-based help (`Get-Help .\code-red.ps1 -Full`).
- README: badges, feature list, options table; added this changelog.

## v1.1.0
- Added passphrase guard (`-Confirm "CODE RED CONFIRM WIPE"`) to prevent accidental wipes.
- Set license holder.

## v1.0.0
- Initial release: wipe non-kept skills + `.claude` data folders, self-destruct.
