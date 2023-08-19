# chocolatey dependencies
. $PSScriptRoot/deps/chocolatey.ps1

# pwsh modules dependencies
. $PSScriptRoot/deps/pwsh-modules.ps1

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