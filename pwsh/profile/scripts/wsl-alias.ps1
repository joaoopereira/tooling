### wsl alias
# only works on windows machines with wsl enabled
if ($global:IS_WINDOWS_ADMIN -and [bool](Get-Command wsl -ErrorAction SilentlyContinue)) {
	### wsl-interop
	## CREDITS: https://github.com/mikebattista/PowerShell-WSL-Interop
	Import-Module WslInterop
	# import commands
	Import-WslCommand "apt", "awk", "emacs", "find", "grep", "head", "less", "man", "sed", "seq", "sudo", "tail", "touch", "vim", "date", "rm", "earthly", "openssl", "make", "wget", "export"

	# restart wsl
	function wslr {
		Write-Host "Restarting wsl..." -ForegroundColor Gray
		wsl --shutdown

		# docker restart
		wsldr

		# set hostname on hosts file
		wsl2host
	}

	## CREDITS: https://github.com/shayne/go-wsl2-host
	function wsl2host {
		$wsl2hostPath = "$env:TOOLING_REPO/wsl2host.exe"
		if(!(Test-Path $wsl2hostPath)) {
			$ProgressPreference = 'SilentlyContinue'
			Invoke-WebRequest https://github.com/shayne/go-wsl2-host/releases/download/latest/wsl2host.exe -OutFile $env:TOOLING_REPO/wsl2host.exe
			$ProgressPreference = 'Continue'
		}

		wsl bash -c "[[ -f ~/.wsl2hosts ]] && grep -q '$env:LOCAL_DOMAIN' ~/.wsl2hosts || echo '$env:LOCAL_DOMAIN' >> ~/.wsl2hosts"

		Invoke-Expression "$wsl2hostPath run"
	}

	function isDockerRunning {
		return !(wsl docker ps 2>&1).ToString().Contains("Cannot connect to the Docker daemon");
	}

	# restart wsl
	function wsldr {
		Write-Host "Waiting for docker to start..." -ForegroundColor Gray
		if (isDockerRunning) {
			wsl bash -ic "sudo service docker stop &>/dev/null"
		}

		wsl bash -ic "sudo service docker start &>/dev/null"

		while (!(isDockerRunning)) {
			Start-Sleep -Milliseconds 500
		}
	}



	function wsl-reinit {
		### import computer-init functions
		. $PSScriptRoot/computer-init-functions.ps1
		SetupUbuntuWSL
	}
}