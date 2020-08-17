+++
title = "How to link multiple docker-compose services via network"
date = 2020-06-11
draft = false 
description = "Walkthrough of how to link networks of docker-compose services defined in multiple files"
[taxonomies]
tags = ["docker", "networking"]
categories = ["how-to", "devops"]
+++

This scenario came from a question I was asked docker-compose and network connectivity between services defined in different docker-compose.yml files.

The desired result was to be able to define a docker-compose.yml in one file, and in a second docker-compose.yml have the ability to reach the first service via service or container name for development purposes.

## Default scenario: Two separate docker-compose.yml and two separate default networks

Let’s take a simple docker compose file.

```yaml
version: '3' 
services: 
  service1: 
    image: busybox 
    command: sleep infinity
```

When it starts up, a default network is created. Its name is based on the service name and the directory name of the docker-compose.yml file.

```bash
$ pwd
/tmp/docker-example/compose1

$ docker-compose up -d
Creating network "compose1_default" with the default driver
Creating compose1_service1_1 ... done
```

### Second docker compose file

```yaml
version: '3' 
services: 
  service2: 
    image: busybox 
    command: sleep infinity
```

Starting services in a second docker compose file, we see the same behavior. A new default network is created and used.

```bash
$ pwd
/tmp/docker-example/compose2

$ docker-compose up -d
Creating network "compose2_default" with the default driver
Creating compose2_service2_1 ... done
```

A side-effect of these isolated networks are that the containers are unable to ping one another by service name or container name.

### Test: From Service 1 ping Service 2
```bash
# By service name
$ docker exec -it compose1_service1_1 ping service2
ping: bad address 'service2'

# By container name
$ docker exec -it compose1_service1_1 ping compose2_service2_1 
ping: bad address 'compose2_service2_1'
```

### Test: Service 2 ping Service 1
```bash
# By service name
$ docker exec -it compose2_service2_1 ping service1
ping: bad address 'service1'

# By container name
$ docker exec -it compose2_service2_1 ping compose1_service1_1 
ping: bad address 'compose1_service1_1'
```

## New scenario: Sharing a network between services

If you want define services in multiple docker-compose.yml files, and also have network connectivity between the services, you need to configure your services to use the same network.

To create an external network, you can run `docker network create <name>`. -- where `<name>` can be a single string without spaces.

### Creating the network

```bash
$ docker network create external-example
2af4d92c2054e9deb86edaea8bb55ecb74f84a62aec7614c9f09fee386f248a6
```

### Modified first docker-compose file with network configured
```yaml
version: '3' 
services: 
  service1: 
    image: busybox 
    command: sleep infinity 

networks: 
  default: 
    external: 
      name: external-example 
```

Restarting the services
```bash
$ pwd
/tmp/docker-example/compose1

$ docker-compose up -d
Creating compose1_service1_1 ... done
```

### Modified second docker-compose file with network configured
```yaml
version: '3' 
services: 
  service2: 
    image: busybox 
    command: sleep infinity 

networks: 
  default: 
    external: 
      name: external-example 
```

Restarting the services
```bash
$ pwd
/tmp/docker-example/compose2

$ docker-compose up -d
Creating compose2_service2_1 ... done
```

After running `docker-compose up -d` on both docker-compose.yml files, we see that no new networks were created.

```bash
$ docker network ls
NETWORK ID          NAME                DRIVER              SCOPE
25e0c599d5e5        bridge              bridge              local
2af4d92c2054        external-example    bridge              local
7df4631e9cff        host                host                local
194d4156d7ab        none                null                local
```

With the containers using the `external-example` network, they are able to ping one another.

### Test: Service 1 ping Service 2
```bash
# By service name
$ docker exec -it compose1_service1_1 ping service2
PING service2 (172.24.0.3): 56 data bytes
64 bytes from 172.24.0.3: seq=0 ttl=64 time=0.054 ms
^C
--- service2 ping statistics ---
1 packets transmitted, 1 packets received, 0% packet loss
round-trip min/avg/max = 0.054/0.054/0.054 ms

# By container name
$ docker exec -it compose1_service1_1 ping compose2_service2_1
PING compose2_service2_1 (172.24.0.2): 56 data bytes
64 bytes from 172.24.0.2: seq=0 ttl=64 time=0.042 ms
^C
--- compose2_service2_1 ping statistics ---
1 packets transmitted, 1 packets received, 0% packet loss
round-trip min/avg/max = 0.042/0.042/0.042 ms
```

### Test: Service 2 ping Service 1
```bash
# By service name
$ docker exec -it compose2_service2_1 ping service1
PING service1 (172.24.0.2): 56 data bytes
64 bytes from 172.24.0.2: seq=0 ttl=64 time=0.041 ms
^C
--- service1 ping statistics ---
1 packets transmitted, 1 packets received, 0% packet loss
round-trip min/avg/max = 0.041/0.041/0.041 ms

# By container name
$ docker exec -it compose2_service2_1 ping compose1_service1_1
PING compose1_service1_1 (172.24.0.3): 56 data bytes
64 bytes from 172.24.0.3: seq=0 ttl=64 time=0.042 ms
^C
--- compose1_service1_1 ping statistics ---
1 packets transmitted, 1 packets received, 0% packet loss
round-trip min/avg/max = 0.042/0.042/0.042 ms
```

> As a note, you can configure your services to use a custom container name by declaring the `container_name` key under each service (i.e., at the same level as `image`).
> 
> [Link to Docker-compose docs - container_name](https://docs.docker.com/compose/compose-file/#container_name)

## Takeaway

You can connect services defined across multiple docker-compose.yml files.

In order to do this you’ll need to:
1. Create an external network with `docker network create <network name>`
2. In each of your docker-compose.yml  configure the default network to use your externally created network with the `networks` top-level key.
3. You can use either the service name or container name to connect between containers.