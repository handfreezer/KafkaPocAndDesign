#!/bin/bash

export PORT_BROKER=9092
if [ ! -z "${1}" ]
then
	PORT_BROKER=${1}
fi

export PATH=$PATH:/kafka/server/kafka/bin
kafka-topics.sh --create --topic quickstart-events --bootstrap-server localhost:9092
kafka-topics.sh --describe --topic quickstart-events --bootstrap-server localhost:9092
kafka-console-producer.sh --topic quickstart-events --bootstrap-server localhost:9092 <<EOF
msg1
msg2
EOF
kafka-console-consumer.sh --topic quickstart-events --from-beginning --bootstrap-server localhost:9092

