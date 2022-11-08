#### Inputs
$url = "https://raw.githubusercontent.com/ansible/ansible/devel/examples/scripts/ConfigureRemotingForAnsible.ps1"
$file = "$env:temp\ConfigureRemotingForAnsible.ps1"
$ErrorActionPreference = "Stop";

#### Pre-Requirements
If(-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent() ).IsInRole( [Security.Principal.WindowsBuiltInRole] "Administrator")) {
	throw "Run command in an administrator PowerShell prompt"
}

#### Run
Invoke-WebRequest $url -OutFile $file
powershell.exe -ExecutionPolicy ByPass -File $file -EnableCredSSP -GlobalHttpFirewallAccess

#### Cleanup
Remove-Item $file -Force
Remove-Item $PSCommandPath -Force