#!/bin/bash

tmp_file=$(mktemp)

for i in $(seq 1 4)
do
	echo -e "h1-${i}:index=${i},h2-${i}:index=${i}\tkey${i}\tmsg${i}" >> ${tmp_file}
done
cat ${tmp_file}

working_topic="test02-et-voila"
if [ 1 -eq "${#}" ]
then
	working_topic="${1}"
fi

echo "==="
echo "Producing in src/${working_topic}"
echo "==="

for replicCount in 1 2
do
	topicName="${working_topic}-$(printf %02d ${replicCount})"
	docker compose cp ${tmp_file} kfkbrksrc-00:/tmp/init-poc-topics-src
	docker compose exec -T kfkbrksrc-00 /entryPoint.sh shell <<<"kafka-topics.sh --bootstrap-server localhost:9092 --command-config /kafka/kraft/producer/config --create --topic ${topicName} --replication-factor ${replicCount}"
	docker compose exec -T kfkbrksrc-00 /entryPoint.sh shell <<<"cat /tmp/init-poc-topics-src | kafka-console-producer.sh --bootstrap-server localhost:9092 --producer.config /kafka/kraft/producer/config --property parse.key=true --property parse.headers=true --topic ${topicName} "
done

if [ -e "${tmp_file}" ]
then
	rm -f "${tmp_file}"
fi

