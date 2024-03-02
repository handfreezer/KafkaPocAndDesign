#!/bin/bash

docker compose stop
docker compose rm -f

docker image ls -f 'reference=kfk' --format '{{.ID}}'|sort|uniq|xargs docker image rm -f
rm -f .env

#docker system prune => shoud not be a good idea for everyone in POC environment

find datas-poc/ -name 'kraft.*' -exec rm {} \;
rm -f datas-poc/CA/{*.srl,*.csr,*.crt,*.key,*.p12,*.jks}

for ext in srl csr crt key p12 jks
do
	find datas-poc/ -type f -name "*.${ext}" -exec rm -f {} \;
done

