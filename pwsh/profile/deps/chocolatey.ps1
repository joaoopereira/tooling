function InstallChocoPackage($package) {
    $command = [bool](Get-Command $package -ErrorAction SilentlyContinue)
    if(!$command)
    {
        Write-Host "$package is not installed. Installing..."
        choco install -y $package
    }
}

function InstallChocoPackages($packages)
{
    foreach($package in $packages)
    {
        InstallChocoPackage $package
    }
}

$choco = [bool](Get-Command choco -ErrorAction SilentlyContinue)
if (!$choco) {
    Write-Host "chocolatey is not installed. Installing..."
    Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
}

InstallChocoPackages git, pwsh, oh-my-posh, zoxide

# Update current process PATH environment variable
$env:Path = [Environment]::GetEnvironmentVariable('Path', [System.EnvironmentVariableTarget]::Machine);