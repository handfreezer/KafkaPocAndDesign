#!/bin/bash

KafkaConnectExtensions="1.0.0"

./999-reset-poc.sh

rm -f datas-poc/connect/smt/*.jar
rm -f datas-poc/connect/libs/*.jar

(cd datas-poc/connect/smt && wget https://github.com/handfreezer/KafkaConnectExtensions/releases/download/${KafkaConnectExtensions}/ulukai-kafka-connect-smt-${KafkaConnectExtensions}.jar)

(cd datas-poc/connect/libs && wget https://github.com/handfreezer/KafkaConnectExtensions/releases/download/${KafkaConnectExtensions}/ulukai-kafka-connect-mirror-${KafkaConnectExtensions}.jar)

