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

SetupGit
SetupChocoPackages