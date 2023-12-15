### wsl alias
# only works on windows machines with wsl enabled
if ($global:IS_WINDOWS_ADMIN -and [bool](Get-Command wsl -ErrorAction SilentlyContinue)) {
	### wsl-interop
	## CREDITS: https://github.com/mikebattista/PowerShell-WSL-Interop
	Import-Module WslInterop
	# import commands
	Import-WslCommand "apt", "awk", "emacs", "find", "grep", "head", "less", "man", "sed", "seq", "sudo", "tail", "touch", "vim", "date", "earthly", "openssl", "make", "wget", "export"

	# restart wsl
	function wslr {
		function isDockerRunning {
			return !(wslbash "docker ps 2>&1").ToString().Contains("Cannot connect to the Docker daemon")
		}

		Write-Host "Restarting $($env:WSL_DEFAULT_DISTRO)..." -ForegroundColor Gray
		wsl -t $env:WSL_DEFAULT_DISTRO

		# docker restart
		Write-Host "Waiting for docker to start..." -ForegroundColor Gray
		$systemd = ("running" -eq (wslbash "systemctl is-system-running"))
		if (isDockerRunning) {
			if(!$systemd) {
				wslbash "sudo service docker stop &>/dev/null"
			} else {
				wslbash "sudo systemctl stop docker.service &>/dev/null"
			}
		}

		if(!$systemd) {
			wslbash "sudo service docker start &>/dev/null &>/dev/null"
		} else {
			wslbash "sudo systemctl start docker.service"
		}

		while (!(isDockerRunning)) {
			Start-Sleep -Milliseconds 500
		}

		# set hostname on hosts file
		wsl2host
	}

	## CREDITS: https://github.com/shayne/go-wsl2-host
	function wsl2host($hostname = $env:LOCAL_DOMAIN) {
		$wsl2hostPath = "$env:TOOLING_REPO/wsl2host.exe"
		if(!(Test-Path $wsl2hostPath)) {
			$ProgressPreference = 'SilentlyContinue'
			Invoke-WebRequest https://github.com/shayne/go-wsl2-host/releases/download/latest/wsl2host.exe -OutFile $env:TOOLING_REPO/wsl2host.exe
			$ProgressPreference = 'Continue'
		}

		wslbash "[[ -f ~/.wsl2hosts ]] && grep -q '$hostname' ~/.wsl2hosts || echo '$hostname' >> ~/.wsl2hosts"

		Invoke-Expression "$wsl2hostPath run"
	}

	function wsl-reinit {
		### import computer-init functions
		. $PSScriptRoot/computer-init-functions.ps1
		SetupUbuntuWSL
	}

	function wslpwd { $pwd.Path.Replace("\","/").Replace("C:", "/mnt/c") }

	function wslbash ($bashCommand) { wsl -d $env:WSL_DEFAULT_DISTRO bash -c "$bashCommand"}
}