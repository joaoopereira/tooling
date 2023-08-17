# installation
in the target folder, run:
```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; Invoke-Expression (New-Object System.Net.WebClient).DownloadString("https://raw.githubusercontent.com/joaoopereira/tooling/main/pwsh/profile/install.ps1")
```
# notes
this poweshell profile installer, installs by default:
- [chocolatey](https://chocolatey.org)
- [git](https://git-scm.com)
- [pwsh](https://learn.microsoft.com/powershell/scripting/overview)
- [oh-my-posh](https://ohmyposh.dev)
- [zoxide](https://github.com/ajeetdsouza/zoxide)