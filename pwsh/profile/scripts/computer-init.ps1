function SetupGit() {
    [string]$userName = Read-Host -Prompt "Enter the git config global user.name"
    [string]$userEmail = Read-Host -Prompt "Enter the git config global user.email"
    git config --global user.name $userName
    git config --global user.email $userEmail
    git config --global core.editor "code --wait"
}

function SetupChocoPackages() {
    [string]$packageConfig = Read-Host -Prompt "Enter the path to the chocolatey packages.config"
    if(Test-Path $packageConfig) {
        choco install -y $packageConfig
    } elseif (!$packageConfig) {
        Write-Warning "No path provided, skipping choco packages installation"
    } else {
        Write-Error "$packageConfig not found!"
    }
}

function DisableWin11ShowMoreOptions {
    (reg add "HKCU\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32" /f /ve) | Out-Null
}

function SetupWindowsExplorer {
    $regPath = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
    Set-ItemProperty $regPath Hidden 1
    Set-ItemProperty $regPath HideFileExt 0
    Stop-Process -processname explorer
}

SetupGit
SetupWindowsExplorer
DisableWin11ShowMoreOptions
SetupChocoPackages
