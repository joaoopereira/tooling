### environment variables vars
$env:TOOLING_REPO = "$PSScriptRoot/../.."
$env:LOCAL_DOMAIN = "jopereira.local"

### terminal customizations
. $PSScriptRoot/scripts/terminal-customizations.ps1

### git
## CREDITS: https://github.com/gluons/powershell-git-aliases
Import-Module git-aliases -DisableNameChecking

### wsl
. $PSScriptRoot/scripts/wsl-alias.ps1

### tooling
Set-Alias -Name portainer-stacks "$env:TOOLING_REPO/pwsh/portainer/portainer-manage-stacks.ps1" -Option AllScope

#region lazy alias

function chocoupgrade {
	choco upgrade all -y
}

function ansible {
	docker run --rm -ti -v ${pwd}:/local ansible bash
}

function open {
	explorer .
	Clear-Host
}

function drive {
	Set-Location "G:/My Drive"
	Clear-Host
}

function temp {
	$myTemp = "C:/_temp"
	if (!(Get-Item $myTemp)) {
		New-Item -ItemType Directory -Path $myTemp
	}
	Set-Location $myTemp
	Clear-Host
}

#endregion