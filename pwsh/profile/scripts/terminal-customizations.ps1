### terminal customizations
$env:OH_MY_POSH_CONFIG = $env:OH_MY_POSH_CONFIG ?? "$PSScriptRoot/../oh-my-posh/config.json"

# Make addon listen to history
Set-PSReadLineOption -PredictionSource HistoryAndPlugin
Set-PSReadLineOption -PredictionViewStyle ListView
Set-PSReadLineOption -HistoryNoDuplicates:$true

# Shows navigable menu of all options when hitting Tab
Set-PSReadlineKeyHandler -Key Tab -Function MenuComplete

# Autocompletion for arrow keys
Set-PSReadlineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadlineKeyHandler -Key DownArrow -Function HistorySearchForward

# Ensure posh-git is loaded
oh-my-posh init pwsh --config "$env:OH_MY_POSH_CONFIG" | Invoke-Expression

### font settings
if(!(Get-ChildItem C:\Windows\Fonts -Filter MesloLGMNerdFont*).Count -gt 1) {
    oh-my-posh font install Meslo
}

# zoxide configurations
Invoke-Expression (& {
    $hook = if ($PSVersionTable.PSVersion.Major -lt 6) { 'prompt' } else { 'pwd' }
    (zoxide init --hook $hook powershell | Out-String)
})

### terminal-icons
#### CREDITS: https://github.com/devblackops/Terminal-Icons
Import-Module Terminal-Icons

## windows terminal specific settings
$terminalSettingsFile = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json";
if(Test-Path $terminalSettingsFile)
{
    # Create the profiles object
    $defaults = @{
        font = @{
            face = "MesloLGM Nerd Font"
            size = 10
        }
    }

    # Load existing settings if the file exists
    if (Test-Path $terminalSettingsFile) {
        $terminalSettings = Get-Content -Raw $terminalSettingsFile | ConvertFrom-Json
    } else {
        $terminalSettings = [PSCustomObject]@{}
    }

    # Add the "profiles" block to the settings
    $terminalSettings.profiles.defaults = $defaults

    # Convert the updated settings back to JSON and save to the file
    $terminalSettings | ConvertTo-Json -Depth 10 | Set-Content -Path $terminalSettingsFile
}