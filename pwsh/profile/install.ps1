$choco = [bool](Get-Command choco -ErrorAction SilentlyContinue)
if (!$choco) {
    Write-Host "chocolatey is not installed. Installing..."
    Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
}

$git = [bool](Get-Command git -ErrorAction SilentlyContinue)
if(!$git)
{
    Write-Host "git is not installed. Installing..."
    choco install -y git
}

$pwsh = [bool](Get-Command pwsh -ErrorAction SilentlyContinue)
if(!$pwsh)
{
    Write-Host "pwsh is not installed. Installing..."
    choco install -y pwsh
}

$ohmyposh = [bool](Get-Command oh-my-posh -ErrorAction SilentlyContinue)
if(!$ohmyposh)
{
    Write-Host "oh-my-posh is not installed. Installing..."
    choco install -y oh-my-posh
}

# Update current process PATH environment variable
$env:Path = [Environment]::GetEnvironmentVariable('Path', [System.EnvironmentVariableTarget]::Machine);

 # configure pwsh
pwsh -Command {

    git clone https://github.com/joaoopereira/tooling.git ./tooling
    $basePath = "$pwd/tooling/pwsh/profile/base.ps1"

    if(!(Test-Path $PROFILE))
    {
        New-Item -Path $PROFILE -Value "`n" -ItemType File -Force
    }
    if(!(Get-Content $PROFILE).Contains(". `"$basePath`""))
    {
        ". `"$basePath`"" >> $PROFILE
    }
}

# open
pwsh