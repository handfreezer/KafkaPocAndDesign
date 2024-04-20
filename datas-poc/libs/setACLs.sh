#!/bin/bash

function kafkaAcl() {
	kafka-acls.sh --bootstrap-server localhost:9092 --command-config /kafka/kraft/producer/config.acls "${@}"
}

PRINCIPAL_LIST="User:CN=kafka-ui,OU=kfk-brk-ui,O=POC,L=IDF,C=FR"
PRINCIPAL_LIST="Regex:OU=kfk-brk-ui,"

if [ 0 -ne "${#}" ]
then
	kafkaAcl "${@}"
else
	clear

	kafkaAcl --list
	echo
	echo "========================================="
	echo
	
	for principal in ${PRINCIPAL_LIST}
	do
		kafkaAcl --topic "*" --add --allow-principal ${principal}   --allow-host "*" --operation Read --operation DescribeConfigs
		kafkaAcl --cluster "*" --add --allow-principal ${principal} --allow-host "*" --operation Describe --operation DescribeConfigs
		kafkaAcl --group "*" --add --allow-principal ${principal}   --allow-host "*" --operation Describe
	done
	
	echo
	echo "========================================="
	echo
	kafkaAcl --list
fi

