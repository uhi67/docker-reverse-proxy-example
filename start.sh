#!/bin/sh
docker network create --driver overlay --attachable proxy || true
docker compose -f docker-compose-proxy.yml up -d --force-recreate --remove-orphans
