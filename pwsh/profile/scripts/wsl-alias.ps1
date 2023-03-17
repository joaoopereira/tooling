### wsl alias
# only works on windows machines with wsl enabled
if ($IsWindows -and $IsAdmin -and
	((Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux).State -eq "Enabled")) {
	## CREDITS: https://devblogs.microsoft.com/commandline/integrate-linux-commands-into-windows-with-powershell-and-the-windows-subsystem-for-linux/
	Import-Module "$env:TOOLING_REPO/pwsh/profile/plugins/wsl-interop/WslInterop.psd1"
	# import commands
	Import-WslCommand "apt", "awk", "emacs", "find", "grep", "head", "less", "ls", "man", "sed", "seq", "sudo", "tail", "touch", "vim", "docker", "docker-compose", "date", "rm", "earthly", "openssl"

	# workaround for accessing the WSL from windows
	# with a custom dns entry defined by environment variable LOCAL_DOMAIN
	# this will allow to have multiple entries
	# alternative to this function is wsl2host (https://github.com/shayne/go-wsl2-host)
	function wsl-ip {
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
				Write-Host "replacing [$old_ip $hostname] with [$ip $hostname]" -ForegroundColor Blue
				$hostfile = [System.Text.RegularExpressions.Regex]::Replace($hostfile, $match, "$ip $hostname")
			}
			$hostfile | Set-Content -Path $hostfilePath
		}
		else {
			Write-Host "adding [$hostname $ip]" -ForegroundColor Blue
			Add-Content -Path $hostfilePath ([Environment]::NewLine + "$ip $env:LOCAL_DOMAIN")
		}
	}

	function wsl-restart {
		Get-Service LxssManager | Restart-Service
		Start-Sleep -Seconds 5
		wsl-ip
		wsl-docker-restart
	}

	function wsl-docker-restart {
		wsl sudo service docker stop
		wsl sudo service docker start
	}

}