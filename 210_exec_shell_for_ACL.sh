#!/bin/bash

docker compose exec -T kfkbrksrc-00 /entryPoint.sh shell <<<"/kafka/acls/setACLs.sh ${@}"

