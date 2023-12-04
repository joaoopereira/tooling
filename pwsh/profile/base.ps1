### import utils
. $PSScriptRoot/scripts/utils.ps1

### environment variables
$env:TOOLING_REPO = Get-Item -Path "$PSScriptRoot/../.."
$env:LOCAL_DOMAIN = $env:LOCAL_DOMAIN ?? "jopereira.local"

### pre-requirements
# check updates
CheckToolingUpdates

# Check if PowerShell is running with administrative privileges
SetWindowsAdmin

### import terminal customizations
. $PSScriptRoot/scripts/terminal-customizations.ps1

### git-aliases
#### CREDITS: https://github.com/gluons/powershell-git-aliases
Import-Module git-aliases -DisableNameChecking

# import wsl-alias
. $PSScriptRoot/scripts/wsl-alias.ps1

### git subrepo
$env:GIT_SUBREPO_ROOT = "$PSScriptRoot/plugins/git-subrepo"
$env:PATH = "$env:PATH;$env:GIT_SUBREPO_ROOT/lib"
$env:MANPATH = "$env:GIT_SUBREPO_ROOT/man"

### import alias
. $PSScriptRoot/scripts/alias.ps1

### import chocolatey profile
Import-Module $env:ChocolateyInstall\helpers\chocolateyProfile.psm1