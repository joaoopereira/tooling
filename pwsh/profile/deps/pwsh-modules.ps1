function InstallModule($module) {
    if(!(Get-InstalledModule $module -ErrorAction SilentlyContinue)) {
        Write-Host "$module module is not installed. Installing..."
        Install-Module $module -Scope CurrentUser -AllowClobber -Force
    }
}

InstallModule git-aliases
InstallModule WslInterop
InstallModule Terminal-Icons