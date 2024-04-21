#!/bin/bash

echo "POC will start, logs will be displayed as a 'tail -f' , you can/should stop with Ctrl-C"
echo "(You can consider this step as started when logs stop scrolling and one of broker is saying it is started)"
sleep 5

serviceList="kfkbrksrc-00 kfkbrksrc-01 kfkbrkdst-00 kfkbrkdst-01"

docker compose up --force-recreate -d ${serviceList}
docker compose logs -f --since 0m ${serviceList}
