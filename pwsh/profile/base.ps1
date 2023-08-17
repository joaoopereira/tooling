### import utils
. $PSScriptRoot/scripts/utils.ps1

### environment variables
$env:TOOLING_REPO = "$PSScriptRoot/../.."
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
Import-Module "$PSScriptRoot/plugins/git-aliases/src/git-aliases.psd1" -DisableNameChecking

# import wsl-alias
. $PSScriptRoot/scripts/wsl-alias.ps1

### tooling
Set-Alias -Name portainer-stacks "$env:TOOLING_REPO/pwsh/portainer/portainer-manage-stacks.ps1" -Option AllScope

### git subrepo
$env:GIT_SUBREPO_ROOT = "$PSScriptRoot/plugins/git-subrepo"
$env:PATH = "$env:PATH;$env:GIT_SUBREPO_ROOT/lib"
$env:MANPATH = "$env:GIT_SUBREPO_ROOT/man"


#region lazy alias

function o { if ($IsWindows) { explorer . && Clear-Host } elseif ($IsMacOS) { open . && Clear-Host } }

function cupgrade { choco upgrade all -y }

function ansible { docker run --rm -ti -v ${pwd}:/local ansible bash }

function tupdate { Write-Host "Updating tooling..." && Set-Location $env:TOOLING_REPO && (git pull > $null) && Set-Location - }

#endregion
