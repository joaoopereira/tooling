### import utils
. $PSScriptRoot/scripts/utils.ps1

### environment variables
$env:TOOLING_REPO = "$PSScriptRoot/../.."
$env:LOCAL_DOMAIN = $env:LOCAL_DOMAIN ?? "jopereira.local"

### pre-requirements
# check updates
CheckToolingUpdates

# chocolatey for windows
IsChocoInstalled

# brew for macos
$global:IS_BREW_INSTALLED = [bool](Get-Command brew -ErrorAction SilentlyContinue)

# Check if PowerShell is running with administrative privileges
SetWindowsAdmin

### import terminal customizations
. $PSScriptRoot/scripts/terminal-customizations.ps1

### git-aliases
#### CREDITS: https://github.com/gluons/powershell-git-aliases
Import-Module "$env:TOOLING_REPO/pwsh/profile/plugins/git-aliases/src/git-aliases.psd1" -DisableNameChecking

# import wsl-alias
. $PSScriptRoot/scripts/wsl-alias.ps1

### tooling
Set-Alias -Name portainer-stacks "$env:TOOLING_REPO/pwsh/portainer/portainer-manage-stacks.ps1" -Option AllScope

### git subrepo
$env:GIT_SUBREPO_ROOT = "$env:TOOLING_REPO/pwsh/profile/plugins/git-subrepo"
$env:PATH = "$env:PATH;$env:GIT_SUBREPO_ROOT/lib"
$env:MANPATH = "$env:GIT_SUBREPO_ROOT/man"


#region lazy alias

function o { if ($IsWindows) { explorer .; Clear-Host } }
function cupgrade { if ($global:IS_CHOCO_INSTALLED) { choco upgrade all -y } }

function bupgrade { if ($global:IS_BREW_INSTALLED) { brew update; brew upgrade } }

function ansible { docker run --rm -ti -v ${pwd}:/local ansible bash }

function tupdate { Set-Location ~/Developer/tooling/pwsh/profile && git pull && Set-Location - }

#endregion
