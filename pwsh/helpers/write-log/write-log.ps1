## Some simple write functions with color

function Log($message) {
	return ("{0} {1}" -f (Get-Date), $message)
}

function Write-Info ($message) {
	$message = Log("INFO: $message");
	Write-Host $message -ForegroundColor Blue
}

function Write-Error ($message) {
	$message = Log("ERROR: $message");
	Write-Host $message -ForegroundColor Red
}

function Write-Warning ($message) {
	$message = Log("WARNING: $message")
	Write-Host $message -ForegroundColor Yellow
}

function Write-Verbose {
	if($env:VERBOSE) {
		$message = Log("VERBOSE: $message");
		Write-Host $message -ForegroundColor Gray
	}
}

function Write-Success ($message) {
	$message = Log("SUCCESS: $message");
	Write-Host $message -ForegroundColor Green
}