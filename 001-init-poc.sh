#!/bin/bash

KafkaConnectExtensions="1.0.0"
KafkaIoConfluentDeps="7.5.1"
KafkaIoConfluentPackages="kafka-schema-registry kafka-schema-registry-client"
ApacheAvro="1.11.3"

./999-reset-poc.sh

rm -f datas-poc/connect/smt/*.jar
rm -f datas-poc/libs/*.jar

(
	cd datas-poc/connect/smt
	wget https://github.com/handfreezer/KafkaConnectExtensions/releases/download/${KafkaConnectExtensions}/ulukai-kafka-connect-smt-${KafkaConnectExtensions}.jar 1>/dev/null 2>&1
	echo "SMT > ${?}"
)
(
	cd datas-poc/libs
	wget https://github.com/handfreezer/KafkaConnectExtensions/releases/download/${KafkaConnectExtensions}/ulukai-kafka-connect-mirror-${KafkaConnectExtensions}.jar 1>/dev/null 2>&1
	echo "Mirror > ${?}"
	wget https://repo1.maven.org/maven2/org/apache/avro/avro/${ApacheAvro}/avro-${ApacheAvro}.jar 1>/dev/null 2>&1
	echo "Avro > ${?}"
	for dep in ${KafkaIoConfluentPackages}
	do
		wget https://packages.confluent.io/maven/io/confluent/${dep}/${KafkaIoConfluentDeps}/${dep}-${KafkaIoConfluentDeps}.jar 1>/dev/null 2>&1
		echo "${dep} > ${?}"
	done
	cp /root/git/KafkaConnectExtensions/broker/target/ulukai-kafka-broker-groupkafkaprincipal-1.0.0.jar . 1>/dev/null 2>&1
	echo "GroupsKafkaPrincipals > ${?}"
)	

