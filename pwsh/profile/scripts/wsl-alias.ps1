### wsl alias
# only works on windows machines with wsl enabled
if ($global:IS_WINDOWS_ADMIN -and [bool](Get-Command wsl -ErrorAction SilentlyContinue)) {
	### wsl-interop
	## CREDITS: https://github.com/mikebattista/PowerShell-WSL-Interop
	Import-Module WslInterop
	# import commands
	Import-WslCommand "apt", "awk", "emacs", "find", "grep", "head", "less", "man", "sed", "seq", "sudo", "tail", "touch", "vim", "date", "earthly", "openssl", "make", "wget", "export"

	# restart wsl
	function wslr($wslDistro = $env:WSL_DEFAULT_DISTRO) {
		Write-Warning "wslr will be replaced by wsldockerr in a future release. Please run wsldockeri a dedicated wsl docker distro"
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

	function wsldockerr
	{
		function isDockerRunning {
			return !(wsldockerbash "docker ps 2>&1").ToString().Contains("Cannot connect to the Docker daemon")
		}

		Write-Host "Restarting $($env:WSL_DOCKER_DISTRO)..." -ForegroundColor Gray
		wsl -t $env:WSL_DOCKER_DISTRO

		# docker restart
		Write-Host "Waiting for docker to start..." -ForegroundColor Gray
		$systemd = ("running" -eq (wsldockerbash "systemctl is-system-running"))
		if (isDockerRunning) {
			if(!$systemd) {
				wsldockerbash "sudo service docker stop &>/dev/null"
			} else {
				wsldockerbash "sudo systemctl stop docker.service &>/dev/null"
			}
		}

		if(!$systemd) {
			wsldockerbash "sudo service docker start &>/dev/null &>/dev/null"
		} else {
			wsldockerbash "sudo systemctl start docker.service"
		}

		while (!(isDockerRunning)) {
			Start-Sleep -Milliseconds 500
		}
	}

	## CREDITS: https://github.com/shayne/go-wsl2-host
	function wsl2host($wslDistro = $env:WSL_DEFAULT_DISTRO) {
		$wslHostname = "$wslDistro.$($env:LOCAL_DOMAIN)"
		$wsl2hostPath = "$env:TOOLING_REPO/wsl2host.exe"
		if(!(Test-Path $wsl2hostPath)) {
			$ProgressPreference = 'SilentlyContinue'
			Invoke-WebRequest https://github.com/shayne/go-wsl2-host/releases/download/latest/wsl2host.exe -OutFile $env:TOOLING_REPO/wsl2host.exe
			$ProgressPreference = 'Continue'
		}

		$command = "[[ -f ~/.wsl2hosts ]] && grep -q '$wslHostname' ~/.wsl2hosts || echo '$wslHostname' >> ~/.wsl2hosts"
		wslbash $command $wslDistro

		Invoke-Expression "$wsl2hostPath run"
	}

	function wsldockeri {
		### import computer-init functions
		. $PSScriptRoot/computer-init-functions.ps1

		$distroExists = ((wsl --list) -like "$env:WSL_DOCKER_DISTRO*")
		if($distroExists) {
			Write-Host "$env:WSL_DOCKER_DISTRO distro already exists and will be removed." -ForegroundColor Yellow
			$yn = Read-Host "Do you want to continue? (y/n)"
			while($yn -ne "y" -and $yn -ne "n") {
				$yn = Read-Host "Do you want to continue? (y/n)"
			}

			if($yn -eq "n") {
				return
			} else {
				wsl --unregister $env:WSL_DOCKER_DISTRO
			}
		}
		SetupWSLDocker
	}

	function wslpwd { $pwd.Path.Replace("\","/").Replace("C:", "/mnt/c") }

	function wslbash ($bashCommand, $wslDistro = $env:WSL_DEFAULT_DISTRO) { wsl -d $wslDistro bash -c "$bashCommand" }

	function wsldockerbash ($bashCommand) { wslbash $bashCommand $env:WSL_DOCKER_DISTRO}
}