# Upgrade process "in-situ" for MarkLogic running in Docker container
This upgrade process was documented and tested for a customer who wanted to upgrade from 8 to 9. First of all, make sure to log a ticket with support@marklogic.com to get the latest information on specifics for the versions.

## Prepare a docker image based on 8.0-4.2
In this step we build an image that is comparable to the customer's image.

Download the previous version from https://wiki.marklogic.com/display/PS/Previous+MarkLogic+Versions.

```sh
docker build -t marklogic:8.0-4.2 .
docker run --name=initial-install -p 8001:8001 marklogic:8.0-4.2
```
Open http://localhost:8001 to self-install database (skip cluster, set-up admin creds). After that, save the installed image.

```sh
docker commit initial-install marklogic:8.0-4.2
```

## Start the newly created image
```sh
docker run -d --name=marklogic-cust -p 8000-8002:8000-8002 marklogic:8.0-4.2`
```

## Backup the customer's Docker container
```sh
docker commit marklogic-cust marklogic-cust-backup
```

## Copy the upgrade files into the container
Download the upgrade version from https://developer.marklogic.com/products/marklogic-server/9.0.
Be sure to include the Converters as they are not part of the main download anymore.

```sh
docker cp MarkLogic-9.0-10.3.x86_64.rpm marklogic-cust:/tmp
docker cp MarkLogicConverters-9.0-10.3.x86_64.rpm marklogic-cust:/tmp
```

## Shell into the docker container and upgrade MarkLogic
Start the shell:

```sh
docker exec -it marklogic-cust sh
```

Within the shell, run the following commands:

```sh
/sbin/service MarkLogic stop
rpm -e MarkLogic
yum -y install libtool-ltdl
rpm -i /tmp/MarkLogic-9.0-10.3.x86_64.rpm
rpm -i /tmp/MarkLogicConverters-9.0-10.3.x86_64.rpm
/sbin/service MarkLogic start
```
Open http://localhost:8001 to ugrade databases.