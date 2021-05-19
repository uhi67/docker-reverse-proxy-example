Docker swarm reverse proxy example with nginx
=============================================

This solution uses the automated nginx proxy from `jwilder/proxy`. 
The point is that in Portainer i made separate stacks for the proxy and the application(s). 

## Test environment:

- Ubuntu 16.04 LTS
- Docker version 17.05.0-ce, build 89658be
- Swarm mode with single node

## The network

The key to the solution is a common network you have to define in the _Networks_ section of Portainer.

| Name  | proxy
|-------|-------
| Driver | overlay
| Scope |	swarm
| Attachable | false
| Internal | false
| Subnet | 10.0.0.0/24
| Gateway | 10.0.0.1

The corresponding docker command is (not tested):

    docker network create --driver overlay --subnet=10.0.0.0/24 --gateway=10.0.0.1 proxy

## The proxy stack

The **proxy** stack is created with `docker-compose-proxy.yml` file.
Contains a single proxy container based on `jwilder/nginx-proxy` image.

```yml
version: '3'
services:
  proxy:
    image: jwilder/nginx-proxy
    ports:
      - 80:80
    volumes:
      - /var/run/docker.sock:/tmp/docker.sock:ro
    networks:
      - proxy
networks:
  proxy:
    external: true
```

## The application stack

The application stack is created with `docker-compose-app.yml` file.
The example contains a single test application using `jwilder/whoami` image.

```yml
version: '3'
services:
  whoami:
    image: jwilder/whoami
    environment:
      - VIRTUAL_HOST=whoami.yourdomain
    ports:
      - 8098:8000
    networks:
      - proxy
networks:
  proxy:
    external: true
```

If the application stack has other containers, e.g. 'db', it also have to connected to the network 'proxy' 
or an other common network with the main application container.
