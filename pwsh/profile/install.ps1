# chocolatey dependencies
Invoke-Expression (New-Object System.Net.WebClient).DownloadString("https://raw.githubusercontent.com/joaoopereira/tooling/main/pwsh/profile/deps/chocolatey.ps1")

# pwsh modules dependencies
Invoke-Expression (New-Object System.Net.WebClient).DownloadString("https://raw.githubusercontent.com/joaoopereira/tooling/main/pwsh/profile/deps/pwsh-modules.ps1")

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