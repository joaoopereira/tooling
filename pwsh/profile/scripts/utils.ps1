# check if a new version of the repo is available comparing the last commits
function CheckToolingUpdates
{
    # move to tooling repo
    Set-Location $env:TOOLING_REPO

    # Fetch the latest changes from the origin branch
    git fetch origin

    # Get the hash of the last commit on the local branch
    $localCommitHash = git log -n 1 --pretty=format:"%h" HEAD

    # Get the hash of the last commit on the origin branch
    $originCommitHash = git log -n 1 --pretty=format:"%h" origin/main

    # Compare the commit hashes to determine which is most recent
    if (git log $localCommitHash..$originCommitHash | Measure-Object | Select-Object -ExpandProperty Count) {
        Write-Host "A new update is available! Please run `tupdate` to update."
    }

    # move back to folder
    Set-Location -
}

# chocolatey for windows
function IsChocoInstalled
{
    $global:IS_CHOCO_INSTALLED = [bool](Get-Command choco -ErrorAction SilentlyContinue)
    if($IsWindows -and !$global:IS_CHOCO_INSTALLED)
    {
        Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
    }
}

function SetWindowsAdmin
{
    if($IsWindows)
    {
        $global:IS_WINDOWS_ADMIN = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
        Write-Host "PowerShell is not running with administrative privileges. Some features may not work." -ForegroundColor Yellow
    }
}



