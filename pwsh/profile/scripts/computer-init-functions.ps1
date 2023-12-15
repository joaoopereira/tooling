function SetupGit() {
    [string]$userName = Read-Host -Prompt "Enter the git config global user.name"
    [string]$userEmail = Read-Host -Prompt "Enter the git config global user.email"
    git config --global user.name $userName
    git config --global user.email $userEmail
    git config --global core.editor "code --wait"
    git config --global core.autocrlf false
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

function SetupUbuntuWSL() {
    $wslDistro = $env:WSL_DEFAULT_DISTRO;
    $wslHostname = "$wslDistro.$($env:LOCAL_DOMAIN)"

    # pre-requirements
    Write-Host "Installing WSL pre-requirements..."
    (dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart) | Out-Null
    (dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart) | Out-Null
    (wsl --install --no-distribution) | Out-Null
    (wsl --set-default-version 2) | Out-Null
    # https://github.com/microsoft/WSL/issues/6264
    $wslEthernetCard = "vEthernet (WSL)"
    netsh int ipv4 set subinterface $wslEthernetCard mtu=1420 store=persistent

    #.wslconfig file
    $wslConfig = "$env:USERPROFILE\.wslconfig"
    if(!(Test-Path $wslConfig))
    {
        Copy-Item -Path "$env:TOOLING_REPO\pwsh\profile\scripts\setupwsl-utils\.wslconfig" -Destination "$wslConfig"
    }

    # distro download and unzip
    $wslDistroUrl = "https://cloud-images.ubuntu.com/wsl/jammy/current/ubuntu-jammy-wsl-amd64-wsl.rootfs.tar.gz"
    $wslDistroFullPath  = "$env:TEMP\$wslDistro.tar.gz"

    if(!(Test-Path($wslDistroFullPath))) {
        Write-Host "Downloading $wslDistroUrl..."
        Invoke-WebRequest $wslDistroUrl -OutFile $wslDistroFullPath
    }
    $wslInstallationPath = "$env:USERPROFILE\wsl\$wslDistro"
    $wslUsername = $env:USERNAME.ToLower().Replace(" ", "")

    if (!(Test-Path -Path $wslInstallationPath)) {
        mkdir $wslInstallationPath | Out-Null
    }

    # import
    Write-Host "Importing $wslDistroFullPath as $wslDistro..."
    (wsl --import $wslDistro $wslInstallationPath $wslDistroFullPath) | Out-Null

    # set distro as default
    wsl -s $wslDistro

    $installFolder = $env:TOOLING_REPO.Replace("\", "/")
    $installFolder = $installFolder.Replace("C:", "/mnt/c")

    # create your user and add it to sudoers
    (wsl -d $wslDistro -u root bash -ic "$installFolder/pwsh/profile/scripts/setupwsl-utils/createUser.sh $wslUsername ubuntu") | Out-Null

    $installFolder = $installFolder.Replace("/mnt/c", "/c")

    # ensure WSL Distro is restarted when first used with user account
    (wsl -t $wslDistro) | Out-Null

    Write-Host "Installing docker in $wslDistro..."

    # install and configure docker
    (wsl -d $wslDistro -u root bash -ic "$installFolder/pwsh/profile/scripts/setupwsl-utils/setupDocker.sh") | Out-Null

    # ensure WSL Distro is restarted
    (wsl -t $wslDistro) | Out-Null

    # configure docker rootless
    (wsl -d $wslDistro bash -ic "$installFolder/pwsh/profile/scripts/setupwsl-utils/setupDockerRootless.sh") | Out-Null

    # set distro as default
    wsl -s $wslDistro

    # install docker-cli
    $docker = [bool](Get-Command docker -ErrorAction SilentlyContinue)
    if(!$docker)
    {
        Write-Host "docker is not installed. Installing..."
        choco install -y docker-cli
    }
    refreshenv

    docker context create $wslDistro --docker "host=tcp://$($wslHostname):2375"

    docker context use $wslDistro

    # configure local hostname
    Write-Host "Setting $wslHostname as hostname for distro"
    wsl2host $wslHostname
}