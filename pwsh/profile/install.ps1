$choco = [bool](Get-Command choco -ErrorAction SilentlyContinue)
if (!$choco) {
    Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
}

$git = [bool](Get-Command git -ErrorAction SilentlyContinue)
if(!$git)
{
    Write-Host "git is not installed. Installing..."
    choco install -y git
    # Update current process PATH environment variable
    $env:Path = [Environment]::GetEnvironmentVariable('Path', [System.EnvironmentVariableTarget]::Machine);
}

git clone https://github.com/joaoopereira/tooling.git ./tooling
$basePath = "$pwd/tooling/pwsh/profile/base.ps1"

if(!(Test-Path $PROFILE))
{
    "" >> $PROFILE
}
if(!(Get-Content $PROFILE).Contains(". `"$basePath`""))
{
    ". `"$basePath`"" >> $PROFILE
}