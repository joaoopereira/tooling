#### Input
param(
    # option to run:
    # list - print table with all stacks Ids, Names, and Status
    # stop - stop all (or filtered) stacks with status Running
    # start - start all (or filtered) stacks with status Inactive
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [ValidateSet('list', 'stop', 'start')]
    [string]$run,

    # filter stacks by name
    [string]$nameFilter,

    # overrides api/stacks GET, with file content
    [string]$file,

    # export stacks to file
    [switch]$export
)

### Validations
if (!$env:PORTAINER_URL) {
    Write-Host "ERROR: Environment Variable PORTAINER_URL not defined" -ForegroundColor Red
    exit
}

if (!$env:PORTAINER_PAT) {
    Write-Host "ERROR: Environment Variable PORTAINER_PAT not defined" -ForegroundColor Red
    exit
}
# trim last /
$env:PORTAINER_URL = $env:PORTAINER_URL.Trim("/")

### Request Headers
$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Accept", "*/*")
$headers.Add("X-API-Key", $env:PORTAINER_PAT)
Write-Host "Connecting to $env:PORTAINER_URL" -ForegroundColor Blue

try {
    $stacks = Invoke-WebRequest "$env:PORTAINER_URL/api/stacks" -Method GET -Headers $headers | ConvertFrom-Json
}
catch {
    Write-Host "ERROR: $($_.Exception.Message)" -ForegroundColor Red
    exit
}

if (!$file) {
    $stacks = $stacks.Where({ $_.Name -match $nameFilter -and !($_.Name -eq "portainer") })
    $file = "$PSScriptRoot/listed-stacks.json"

    if ($run -eq "stop") {
        $stacks = $stacks.Where({ $run -eq "stop" -and $_.status -eq 1 })
        $file = "$PSScriptRoot/stopped-stacks.json"

    }
    elseif ($run -eq "start") {
        $stacks = $stacks.Where({ $run -eq "start" -and $_.status -eq 2 })
        $file = "$PSScriptRoot/started-stacks.json"
    }

    if ($export) {
        $stacks | ConvertTo-Json -WarningAction SilentlyContinue | Out-File $file
        Write-Host "Exported $file" -ForegroundColor Blue
    }
}
else {
    $stacks = Get-Content -Raw $file | ConvertFrom-Json
}

if ($stacks.Count -eq 0) {
    Write-Host "No Stacks to $run" -ForegroundColor Yellow
}
else {
    $stacks | Format-Table -AutoSize -Property Id, Name, @{name = "Status"; expression = { ($_.status -eq 1) ? "Running" : "Inactive" } }
    Write-Host "TOTAL $($stacks.Count) stacks" -ForegroundColor Blue
    if (!($run -eq "list")) {
        foreach ($stack in $stacks) {
            Write-Host "Running $run $($stack.id)-$($stack.name)..." -ForegroundColor Blue
            $url = "$env:PORTAINER_URL/api/stacks/$($stack.id)/$($run)?endpointId=1"
            $request = Invoke-WebRequest $url -Method POST -Headers $headers -SkipHttpErrorCheck
            if ($request.statuscode -eq 200) {
            }
            else {
                $request | Format-Table -AutoSize -Property StatusCode, StatusDescription, @{name = "Message"; expression = { ($_.Content | ConvertFrom-Json).message } } | Out-String | Write-Host -ForegroundColor Red
            }
        }
    }
}