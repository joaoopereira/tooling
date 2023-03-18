### wsl alias
# only works on windows machines with wsl enabled
if ($global:IS_WINDOWS_ADMIN -and
	((Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux).State -eq "Enabled")) {
	## CREDITS: https://devblogs.microsoft.com/commandline/integrate-linux-commands-into-windows-with-powershell-and-the-windows-subsystem-for-linux/
	Import-Module "$env:TOOLING_REPO/pwsh/profile/plugins/wsl-interop/WslInterop.psd1"
	# import commands
	Import-WslCommand "apt", "awk", "emacs", "find", "grep", "head", "less", "ls", "man", "sed", "seq", "sudo", "tail", "touch", "vim", "docker", "docker-compose", "date", "rm", "earthly", "openssl"

	# workaround for accessing the WSL from windows
	# with a custom dns entry defined by environment variable LOCAL_DOMAIN
	# this will allow to have multiple entries
	# alternative to this function is wsl2host (https://github.com/shayne/go-wsl2-host)
	function wsli {
		Write-Host "Updating hosts file with new ips for all *.$env:LOCAL_DOMAIN..." -ForegroundColor Gray
		$env:LOCAL_DOMAIN = $env:LOCAL_DOMAIN ?? "wsl.local"
		$wslIpAddr = (wsl hostname -I).Trim()
		$ip = $wslIpAddr.Split(" ")[0]

		$hostfilePath = "C:\windows\system32\drivers\etc\hosts"
		$hostfile = (Get-Content $hostfilePath -Encoding UTF8 -Raw).Trim()
		$matchResult = [System.Text.RegularExpressions.Regex]::Matches($hostfile, "(?<ip>[\d\.]*\.[\d\.]*).*$env:LOCAL_DOMAIN")

		if ($matchResult.Count) {
			foreach ($match in $matchResult) {
				$hostname = $match.Value.Split(" ")[1];
				$old_ip = $match.Value.Split(" ")[0];
				# Write-Host "replacing [$old_ip $hostname] with [$ip $hostname]" -ForegroundColor Gray
				$hostfile = [System.Text.RegularExpressions.Regex]::Replace($hostfile, $match, "$ip $hostname")
			}
			$hostfile | Set-Content -Path $hostfilePath
		}
		else {
			# Write-Host "adding [$hostname $ip]" -ForegroundColor Gray
			Add-Content -Path $hostfilePath ([Environment]::NewLine + "$ip $env:LOCAL_DOMAIN")
		}
	}

	# restart wsl
	function wslr {
		Write-Host "Restarting wsl..." -ForegroundColor Gray
		wsl --shutdown

		# docker resstart
		wsldr

		# set hostname on hosts file
		wsli
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

	function wsl-restart {
		Write-Host "This command will be deprecated in the next release. Please use wslr" -ForegroundColor Yellow
		wslr
	}

	function wsl-docker-restart {
		Write-Host "This command will be deprecated in the next release. Please use wsldr" -ForegroundColor Yellow
		wsldr
	}
}