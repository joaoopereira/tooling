function SetupGit() {
    [string]$userName = Read-Host -Prompt "Enter the git config global user.name"
    [string]$userEmail = Read-Host -Prompt "Enter the git config global user.email"
    git config --global user.name $userName
    git config --global user.email $userEmail
    git config --global core.editor "code --wait"
    git config --global core.autocrlf true
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
    $regPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
    Set-ItemProperty $regPath Hidden 1
    Set-ItemProperty $regPath HideFileExt 0
    Stop-Process -processname explorer
}

function SetupUbuntuWSL($wslDistro = "wslubuntu2204") {
    # pre-requirements
    Write-Host "Installing WSL pre-requirements..."
    (dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart) | Out-Null
    (dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart) | Out-Null
    (wsl --install --no-distribution) | Out-Null
    (wsl --set-default-version 2) | Out-Null

    #.wslconfig file
    $wslConfig = "$env:USERPROFILE\.wslconfig"
    if(!(Test-Path $wslConfig))
    {
        Copy-Item -Path "$env:TOOLING_REPO\pwsh\profile\scripts\setupwsl-utils\.wslconfig" -Destination "$wslConfig"
    }

    # distro download and unzip
    $wslDistroUrl = "https://aka.ms/$wslDistro"
    $fileFullPath  = "$env:TEMP\$wslDistro.appx"

    Write-Host "Downloading and Importing $wsldistro..."
    if(!(Test-Path($fileFullPath))) {
        $ProgressPreference = "SilentlyContinue"
        Invoke-WebRequest $wslDistroUrl -OutFile $fileFullPath
        $ProgressPreference = "Continue"
    }
    $wslInstallationPath = "$env:USERPROFILE\wsl\$wslDistro"
    $wslUsername = $env:USERNAME.ToLower().Replace(" ", "")
    $wslStagingFolder = "$env:TEMP\$wslDistro-staging"

    # create staging directory if it does not exists
    if (!(Test-Path -Path $wslStagingFolder)) {
        mkdir $wslStagingFolder | Out-Null
    }

    $ProgressPreference = "SilentlyContinue"
    Copy-Item $env:TEMP\$wslDistro.appx $wslStagingFolder\$wslDistro-Temp.zip -Force | Out-Null
    Expand-Archive $wslStagingFolder\$wslDistro-Temp.zip $wslStagingFolder\$wslDistro-Temp -Force | Out-Null
    Move-Item $wslStagingFolder\$wslDistro-Temp\*_x64.appx $wslStagingFolder\$wslDistro.zip -Force | Out-Null
    Expand-Archive $wslStagingFolder\$wslDistro.zip $wslStagingFolder\$wslDistro -Force | Out-Null
    $ProgressPreference = "Continue"

    if (!(Test-Path -Path $wslInstallationPath)) {
        mkdir $wslInstallationPath | Out-Null
    }

    # import
    (wsl --import $wslDistro $wslInstallationPath $wslStagingFolder\$wslDistro\install.tar.gz) | Out-Null

    # cleanup
    Remove-Item $wslStagingFolder\ -Recurse -Force

    $installFolder = $env:TOOLING_REPO.Replace("\", "/")
    $installFolder = $installFolder.Replace("C:", "/mnt/c")

    # create your user and add it to sudoers
    (wsl -d $wslDistro -u root bash -ic "$installFolder/pwsh/profile/scripts/setupwsl-utils/createUser.sh $wslUsername ubuntu") | Out-Null

    # ensure WSL Distro is restarted when first used with user account
    (wsl -t $wslDistro) | Out-Null

    # configure local hostname
    Write-Host "Setting $($env:LOCAL_DOMAIN) as hostname for distro"
    wsl2host

    Write-Host "Do you want to install docker? (y/n) " -NoNewline
    $configureDocker = $Host.UI.RawUI.ReadKey()
    Write-Host
    if($configureDocker.Character -eq "y")
    {
        Write-Host "Installing and Configuring docker..."

        # install and configure docker
        wsl -d $wslDistro -u root bash -ic "$installFolder/pwsh/profile/scripts/setupwsl-utils/setupDocker.sh"

        # ensure WSL Distro is restarted
        (wsl -t $wslDistro) | Out-Null

        # configure docker rootless
        (wsl -d $wslDistro bash -ic "$installFolder/pwsh/profile/scripts/setupwsl-utils/setupDockerRootless.sh") | Out-Null

        docker context create $wslDistro --docker "host=tcp://$($env:LOCAL_DOMAIN):2375"
    }
}