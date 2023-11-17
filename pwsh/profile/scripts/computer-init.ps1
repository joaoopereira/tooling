function SetupGit {
    git config --global core.editor "code --wait"
}

function SetupChocoPackages($packageConfig) {
    if(!$packageConfig -or !(Test-Path $packageConfig)) {
        [string]$packageConfig = Read-Host -Prompt "Enter the path to the chocolatey packages.config"
        if(Test-Path $packageConfig) {
            choco install -y $packageConfig
        } else {
            Write-Error "$packageConfig not found!"
        }
    }
}

function DisableWin11ShowMoreOptions {
    $regPath = 'HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}'
    Set-ItemProperty $regPath InprocServer32 ''
}

function SetupWindowsExplorer {
    $regPath = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
    Set-ItemProperty $regPath Hidden 1
    Set-ItemProperty $regPath HideFileExt 0
    Set-ItemProperty $regPath ShowSuperHidden 1
    Stop-Process -processname explorer
}

SetupGit
SetupWindowsExplorer
DisableWin11ShowMoreOptions
SetupChocoPackages

