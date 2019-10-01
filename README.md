# Upgrade process "in-situ" for MarkLogic running in Docker container
This upgrade process was documented and tested for a customer who wanted to upgrade from 8 to 9.

## Create a docker image based on 8.0-4.2
Download the previous version from https://wiki.marklogic.com/display/PS/Previous+MarkLogic+Versions.

```sh
docker build -t marklogic:8.0-4.2 .
docker run --name=initial-install -p 8001:8001 marklogic:8.0-4.2
```
Open http://localhost:8001 to self-install database (skip cluster, set-up admin creds)
`docker commit initial-install marklogic:8.0-4.2`

## Start the newly created image
`docker run -d --name=marklogic-ing -p 8000-8002:8000-8002 marklogic:8.0-4.2`

## Backup the docker container
`docker commit marklogic-ing marklogic-ing-backup`

## Copy the upgrade files into the container
Download the upgrade version from https://developer.marklogic.com/products/marklogic-server/9.0.
Be sure to include the Converters as they are not part of the main download anymore.

```sh
docker cp MarkLogic-9.0-10.3.x86_64.rpm marklogic-ing:/tmp
docker cp MarkLogicConverters-9.0-10.3.x86_64.rpm marklogic-ing:/tmp
```

## Shell into the docker container and upgrade MarkLogic
```sh
docker exec -it marklogic-ing sh
/sbin/service MarkLogic stop
rpm -e MarkLogic
yum -y install libtool-ltdl
rpm -i /tmp/MarkLogic-9.0-10.3.x86_64.rpm
rpm -i /tmp/MarkLogicConverters-9.0-10.3.x86_64.rpm
/sbin/service MarkLogic start
```
Open http://localhost:8001 to ugrade databases