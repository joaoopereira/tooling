$git = [bool](Get-Command git -ErrorAction SilentlyContinue)
if(!$git)
{
    Write-Host "git is not installed. Installing..."
    choco install -y git
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