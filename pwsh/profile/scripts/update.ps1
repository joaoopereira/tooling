Write-Host "Updating tooling..."
Set-Location $env:TOOLING_REPO
git pull > $null
. $PSScriptRoot/../deps/chocolatey.ps1
. $PSScriptRoot/../deps/pwsh-modules.ps1
Set-Location -