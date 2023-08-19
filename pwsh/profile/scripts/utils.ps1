# variables
$lastUpdateCheckPath = "$PSScriptRoot/lastUpdateCheck"

# check if a new version of the repo is available comparing the last commits
function CheckToolingUpdates {

    if((IsToCheckUpdates) -and (CanAccessGithub)) {
        New-Item -Path $lastUpdateCheckPath -Value (Date) -ItemType File -Force | Out-Null
        
        # move to tooling repo
        Set-Location $env:TOOLING_REPO

        # Fetch the latest changes from the origin branch
        git fetch origin > $null

        # Get the hash of the last commit on the local branch
        $localCommitHash = (git log -n 1 --pretty=format:"%h" HEAD)

        # Get the hash of the last commit on the origin branch
        $originCommitHash = (git log -n 1 --pretty=format:"%h" origin/main)

        # Compare the commit hashes to determine which is most recent
        if (git log $localCommitHash..$originCommitHash | Measure-Object | Select-Object -ExpandProperty Count) {
            Write-Host "A new update is available! Please run " -NoNewline -ForegroundColor DarkYellow;
            Write-Host -ForegroundColor DarkBlue "tupdate" -NoNewline;
            Write-Host " to get the latest version." -NoNewline -ForegroundColor DarkYellow;
            Write-Host
        }

        # move back to source folder
        Set-Location -
    }
}
function SetWindowsAdmin {
    if ($IsWindows) {
        $global:IS_WINDOWS_ADMIN = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
        if (!$global:IS_WINDOWS_ADMIN) {
            Write-Host "PowerShell is not running with administrative privileges. Some features may not work." -ForegroundColor Yellow
        }
    }
}

function CanAccessGithub {
    Write-Host "CAN ACCESS"
    $result = (Test-Connection github.com -WarningAction SilentlyContinue -ErrorAction SilentlyContinue -Count 1).Status
    return ($result -eq "Success")
}

function SetupGit {
    git config --global core.editor "code --wait"
}

function IsToCheckUpdates {
    $currentDate = Date
    $isToCheckUpdates = $false

    if(Test-Path $lastUpdateCheckPath) {
       $lastUpdateCheckDate = [DateTime](Get-Content $lastUpdateCheckPath)
       if(($currentDate - $lastUpdateCheckDate).Days -gt 15) {
            $isToCheckUpdates = $true
       }
    }
    else {
        $isToCheckUpdates = $true
    }

    return $isToCheckUpdates
}