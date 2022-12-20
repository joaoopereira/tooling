#### Imports
. $PSScriptRoot/../helpers/write-log/write-log.ps1

#### Pre-Requirements
$ErrorActionPreference="Stop";

$adminRole = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
If(!$adminRole) { throw "Run command in an administrator PowerShell prompt" }

#### Input
if(!$env:SQL_ISO) {	throw "Environment Variable SQL_ISO not defined" }

if(!$env:SQL_CONFIG) { $env:SQL_CONFIG = "$PSScriptRoot/assets/ConfigurationFile.ini" }

if(!(Test-Path -Path $env:SQL_CONFIG)) { throw "$env:SQL_CONFIG does not exist." }

if(!$env:SQL_SA_PWD) {throw "Environment Variable SQL_SA_PWD not defined" }

if(!$env:SQL_DATA_DRIVE) { $env:SQL_DATA_DRIVE = "D:\" }

if(!(Test-Path -Path $env:SQL_DATA_DRIVE)) { throw "$env:SQL_DATA_DRIVE does not exist." }

if(!$env:SQL_INSTANCE) { $env:SQL_INSTANCE = "ONLINE" }

if(!$env:ROLLBACK_IF_FAILS) { $env:ROLLBACK_IF_FAILS = $false }

$disableFirewall = $false
$createUser = $false
$createFolders = $false
$mountIso = $false

$foldersToCreate = "Backup", "Data", "Log", "Temp", "OLAP\Backup", "OLAP\Data", "OLAP\Log", "OLAP\Temp"

try {
	#### Disable Firewall
	$firewallEnabled = ((Get-NetFirewallProfile -Profile Domain).Enabled -or (Get-NetFirewallProfile -Profile Public).Enabled -or (Get-NetFirewallProfile -Profile Private).Enabled)
	if($firewallEnabled) {
		Write-Info "Disabling Firewall..."
		Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False
		$disableFirewall = $true
	} else {
		Write-Verbose "Firewall already disabled"
	}

	#### Create User
	$localUser = Get-LocalUser -Name "sql-service" -ErrorAction Ignore
	if(!$localUser) {
		Write-Info "Creating sql-service User..."
		$secureSaPassword = ConvertTo-SecureString -String $env:SQL_SA_PWD -AsPlainText
		New-LocalUser -Name "sql-service" -Password $secureSaPassword -FullName "SQL Service" -Description "Service that runs SQL Services" | Out-Null
		$createUser = $true
	} else {
		Write-Verbose "User sql-service already exists"
	}

	#### Create Folder Structure
	Write-Info "Creating required folders on Data Drive..."
	foreach ($folderToCreate in $foldersToCreate) {
		New-Item -ItemType Directory -Path $env:SQL_DATA_DRIVE -Name "$folderToCreate" -Force -OutVariable folder | Out-Null
		$folder = $folder.FullName
	}
	$createFolders = $true

	#### SQL ISO
	Write-Info "Mounting SQL ISO..."
	Mount-DiskImage -StorageType ISO -ImagePath $env:SQL_ISO -PassThru | Out-Null
	$isoDrive = ((Get-DiskImage -ImagePath $env:SQL_ISO | Get-Volume).DriveLetter) + ":/"
	$mountIso = $true

	#### SQL Install
	Write-Info "Installing SQL Server..."
	$process = Start-Process "$isoDrive\setup.exe" "/ConfigurationFile='$env:SQL_CONFIG' /IAcceptSQLServerLicenseTerms /SAPWD='$env:SQL_SA_PWD'" -PassThru -Wait
	if($process.ExitCode -ne 0) {
		throw "SQL Server installation failed"
	}
	Dismount-DiskImage -ImagePath $env:SQL_ISO | Out-Null

	#### Reporting Services Install
	$installed = (Get-ItemProperty HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*).DisplayName -Contains "Microsoft SQL Server Reporting Services"
	if(!$installed)
	{
		Write-Info "Installing Reporting Services..."
		$installerSRSS = "$env:TEMP\SQLServerReportingServices.exe"
		if(!(Test-Path -Path $installerSRSS)) {
			Invoke-WebRequest “https://download.microsoft.com/download/1/a/a/1aaa9177-3578-4931-b8f3-373b24f63342/SQLServerReportingServices.exe" -OutFile $InstallerSRSS
		}
		$process = Start-Process $installerSRSS "/quiet /norestart /IAcceptLicenseTerms /Edition=Dev" -PassThru -Wait
		if($process.ExitCode -ne 0) {
			throw "Reporting Services installation failed"
		}
	} else {
		Write-Verbose "Reporting Services already installed"
	}

	#### Reporting Services Configuration
	Write-Info "Configuring Reporting Services..."
	$global:LASTEXITCODE = 0
	Invoke-Expression -Command "$PSScriptRoot\config-report-server.ps1"
	if($LASTEXITCODE -ne 0) {
		throw "Reporting Services configuration failed"
	}

	Write-Success "SQL Server Installed and configured"
}
catch {
	Write-Error "$_"

	if($env:ROLLBACK_IF_FAILS) {
		Write-Warning "Starting Rollback"
		if($disableFirewall) {
			Write-Warning "Enable Firewall"
			Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled True
		}

		if($createUser) {
			Write-Warning "Delete user"
			Remove-LocalUser -Name "sql-service" | Out-Null
		}

		if($createFolders) {
			Write-Warning "Delete Folders"
			foreach ($folderToCreate in $foldersToCreate) {
				Remove-Item -Path "$env:SQL_DATA_DRIVE/$folderToCreate"
			}
		}

		if($mountIso) {
			Write-Warning "Dismount ISO"
			Dismount-DiskImage -ImagePath $env:SQL_ISO | Out-Null
		}
	}
}
finally {
	Set-Location $PSScriptRoot
}