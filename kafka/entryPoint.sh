#!/bin/bash

set -x

DIR_CONFIG="/kafka/config"
DIR_KRAFT="${DIR_CONFIG}/kraft"
DIR_KFK="/kafka/server/kafka"

if [ ! -d "${DIR_KRAFT}" ]
then
	mkdir -p "${DIR_KRAFT}"
	KAFKA_CLUSTER_ID="$(${DIR_KFK}/bin/kafka-storage.sh random-uuid)"
	${DIR_KFK}/bin/kafka-storage.sh format -t "$KAFKA_CLUSTER_ID" -c ${DIR_KRAFT}/server.properties
fi

exec ${*}

