# :whale: run ansible from docker container
> [dockerfile](dockerfile) made by [m-s-](https://github.com/m-s-)
```sh
docker build --rm . -t ansible

cd [playbook folder]

docker run --rm -ti -v ${pwd}:/local ansible bash # pwsh
docker run --rm -ti -v %CD%:/local ansible bash # cmd
docker run --rm -ti -v $(pwd):/local ansible bash # bash
docker run --rm -ti -v (pwd):/local ansible bash # fish
```

> because I'm a lazy person, I usually add this as an alias on my powershell profile
```powershell
function ansible {
    docker run --rm -ti -v ${pwd}:/local ansible bash
}
```
# configure windows host
in the target machine, run:
```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString("https://raw.githubusercontent.com/joaoopereira/tooling/main/ansible/configure-windows-host/run.ps1"))
```

to test the connection:
create an inventory file
```yaml
servers:
  hosts:
    SERVER-NAME-OR-IP:
  vars:
    ansible_ssh_port: 5986
    ansible_connection: winrm
    ansible_winrm_server_cert_validation: ignore
    ansible_winrm_transport: credssp
```

then, run:
```docker
docker run --rm -ti -v ${pwd}:/local ansible bash
```

```bash
ansible all -i inventory.yml -u "username" --ask-pass -m win_ping
```
