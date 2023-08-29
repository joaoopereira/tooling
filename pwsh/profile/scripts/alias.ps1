### tooling
Set-Alias -Name portainer-stacks "$env:TOOLING_REPO/pwsh/portainer/portainer-manage-stacks.ps1" -Option AllScope

function ansible { docker run --rm -ti -v ${pwd}:/local ansible bash }

Set-Alias -Name tupdate "$PSScriptRoot/scripts/update.ps1" -Option AllScope

### lazy alias

function o { explorer . && Clear-Host }

function cupgrade { choco upgrade all -y }

### computer init script alias
Set-Alias -Name computer-init "$PSScriptRoot/scripts/computer-init.ps1" -Option AllScope