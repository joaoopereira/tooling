function SetupGit() {
    [string]$userName = Read-Host -Prompt "Enter the git config global user.name"
    [string]$userEmail = Read-Host -Prompt "Enter the git config global user.email"
    git config --global user.name $userName
    git config --global user.email $userEmail
    git config --global core.editor "code --wait"
    git config --global core.autocrlf false
    git config --global core.eol lf
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

function SetupWSLDistro($wslDistro = "Ubuntu") {
    $wslHostname = "$wslDistro.$($env:LOCAL_DOMAIN)"

    # pre-requirements
    Write-Host "Installing WSL pre-requirements..."
    (dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart) | Out-Null
    (dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart) | Out-Null
    (wsl --install --no-distribution) | Out-Null
    (wsl --set-default-version 2) | Out-Null

    #.wslconfig file
    $wslConfig = "$env:USERPROFILE\.wslconfig"
    if(!(Test-Path $wslConfig)) {
        Copy-Item -Path "$env:TOOLING_REPO\pwsh\profile\scripts\setupwsl-utils\.wslconfig" -Destination "$wslConfig"
    }

    # distro download and unzip
    $wslDistroFile = "ubuntu-jammy-wsl-amd64-wsl.rootfs.tar.gz";
    $wslDistroUrl = "https://cloud-images.ubuntu.com/wsl/jammy/current/$wslDistroFile"
    $wslDistroFullPath  = "$env:TEMP\$wslDistroFile"

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

    $toolingFolder = $env:TOOLING_REPO.Replace("\", "/").Replace("C:", "/mnt/c")

    # create your user and add it to sudoers
    (wsl -d $wslDistro -u root bash -ic "$toolingFolder/pwsh/profile/scripts/setupwsl-utils/createUser.sh $wslUsername ubuntu") | Out-Null

    $toolingFolder = $toolingFolder.Replace("/mnt/c", "/c")

    # ensure WSL Distro is restarted when first used with user account
    (wsl -t $wslDistro) | Out-Null

    # configure local hostname
    Write-Host "Setting $wslHostname as hostname for distro"
    wsl2host $wslDistro
}

function SetupWSLDocker() {
    $wslDistro = $env:WSL_DOCKER_DISTRO
    $wslHostname = "$wslDistro.$($env:LOCAL_DOMAIN)"

    SetupWSLDistro $wslDistro

    $toolingFolder = $env:TOOLING_REPO.Replace("\", "/").Replace("C:", "/c")

    Write-Host "Installing docker..."

    # install and configure docker
    (wsl -d $wslDistro -u root bash -ic "$toolingFolder/pwsh/profile/scripts/setupwsl-utils/setupDocker.sh") | Out-Null

    # ensure WSL Distro is restarted
    (wsl -t $wslDistro) | Out-Null

    # configure docker rootless
    (wsl -d $wslDistro bash -ic "$toolingFolder/pwsh/profile/scripts/setupwsl-utils/setupDockerRootless.sh") | Out-Null

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
}