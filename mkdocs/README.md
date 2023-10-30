# :whale: run mkdocs from docker container
```sh
docker build --rm . -t mkdocs

docker run --rm -t -p 8081:80 -v ${pwd}:/app mkdocs # pwsh
docker run --rm -t -p 8081:80 -v %CD%:/app mkdocs # cmd
docker run --rm -t -p 8081:80 -v $(pwd):/app mkdocs # bash
docker run --rm -t -p 8081:80  -v (pwd):/app mkdocs # fish
```

> because I'm a lazy person, I usually add this as an alias on my powershell profile
```powershell
function mkdocs {
  docker run --rm -t -v ${pwd}:/app -p 8001:80 mkdocs
}
```