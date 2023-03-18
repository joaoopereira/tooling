# requirements
this poweshell profile, installs by default a package manager:
- [chocolatey](https://chocolatey.org/) (on windows)
- [homebrew](https://brew.sh/) (on macos)

# installation
in the target folder, run:
```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; Invoke-Expression (New-Object System.Net.WebClient).DownloadString("https://raw.githubusercontent.com/joaoopereira/tooling/main/pwsh/profile/install.ps1")
```

# requirements
This PowerShell profile includes the installation of a package manager by default. Depending on your operating system, the package manager will be one of the following:

- [chocolatey](https://chocolatey.org/) (for windows)
- [homebrew](https://brew.sh/) (for macos)

# installation
To install the PowerShell profile, follow these steps:

Open a PowerShell console.
Navigate to the target folder.
Run the following command:
```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; Invoke-Expression (New-Object System.Net.WebClient).DownloadString("https://raw.githubusercontent.com/joaoopereira/tooling/main/pwsh/profile/install.ps1")
```



