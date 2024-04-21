#!/bin/bash

echo "POC will start, logs will be displayed as a 'tail -f' , you can/should stop with Ctrl-C"
echo "(You can consider POC is started when 'kafka-ui' service is displaying logs about metrics)"
sleep 5

serviceList="kfkcnt-00 kfkcnt-01 kafka-ui"

docker compose up --force-recreate -d ${serviceList}
docker compose logs -f --since 0m ${serviceList}

