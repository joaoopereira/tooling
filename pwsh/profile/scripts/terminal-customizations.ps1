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

# zoxide install and configurations
if (![bool](Get-Command zoxide -ErrorAction SilentlyContinue)) {
    choco install -y zoxide
}

Invoke-Expression (& {
    $hook = if ($PSVersionTable.PSVersion.Major -lt 6) { 'prompt' } else { 'pwd' }
    (zoxide init --hook $hook powershell | Out-String)
})
