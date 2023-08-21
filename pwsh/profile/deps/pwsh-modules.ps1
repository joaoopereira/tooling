function InstallModule($module) {
    if(!(Get-InstalledModule $module -ErrorAction SilentlyContinue)) {
        Write-Host "$module module is not installed. Installing..."
        Install-Module $module -Scope CurrentUser -AllowClobber -Force
    }
}

function InstallModules($modules) {
    foreach($module in $modules)
    {
        InstallModule $module
    }
}
InstallModules git-aliases, WslInterop, Terminal-Icons