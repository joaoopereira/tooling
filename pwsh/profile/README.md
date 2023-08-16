# requirements
this poweshell profile, installs by default a package manager:
- [chocolatey](https://chocolatey.org/) (on windows)

# installation
in the target folder, run:
```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; Invoke-Expression (New-Object System.Net.WebClient).DownloadString("https://raw.githubusercontent.com/joaoopereira/tooling/main/pwsh/profile/install.ps1")
```
