#!/bin/bash

rm -f .env
docker compose stop
docker compose rm -f
docker image ls -f 'reference=kfk' --format '{{.ID}}'|sort|uniq|xargs docker image rm -f
#docker system prune => shoud not be a good idea for everyone in POC environment

