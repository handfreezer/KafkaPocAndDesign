#!/bin/bash

#set -x

DIR_CONFIG="/kafka/config"
DIR_KRAFT="${DIR_CONFIG}/kraft"
DIR_KFK="/kafka/server/kafka"
KRAFT_CONFIG="${DIR_KRAFT}/kraft.properties"

if [ -z "${KAFKA_CLUSTER_ID}" ]
then
	echo "No KAFKA Cluster ID defined, stopping"
	echo "Run : kafka-storage.sh random-uuid to get one"
	echo "Here is the result of the command for this time:"
	${DIR_KFK}/bin/kafka-storage.sh random-uuid
else
	if [ ! -d "${DIR_KRAFT}" ]
	then
		echo "EntryPoint Init for [${DIR_KRAFT}] with UUID [${KAFKA_CLUSTER_ID}]"
		mkdir -p "${DIR_KRAFT}"
		cp ${DIR_KFK}/config/kraft/server.properties ${KRAFT_CONFIG}
		/configIni.sh KRAFT ${KRAFT_CONFIG}
		${DIR_KFK}/bin/kafka-storage.sh format -t "$KAFKA_CLUSTER_ID" -c ${KRAFT_CONFIG}
	fi
	
	exec "${@}"
fi

exit 1

