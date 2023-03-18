$git = [bool](Get-Command git -ErrorAction SilentlyContinue)
if(!$git)
{
    Write-Host "Mandatory dependency git is not installed."
    break
}

git clone https://github.com/joaoopereira/tooling.git ./tooling
$basePath = "$pwd/tooling/pwsh/profile/base.ps1"

if(!(Get-Content $PROFILE).Contains(". `"$basePath`""))
{
    ". `"$basePath`"" >> $PROFILE
}