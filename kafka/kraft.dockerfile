From debian:bookworm-20231030

env DEBIAN_FRONTEND=noninteractive

Run apt update &&\
	apt upgrade &&\
	apt install -y --no-install-recommends \
		vim git curl wget python3

Run apt install -y --no-install-recommends openjdk-17-jre-headless
Run apt install -y --no-install-recommends ca-certificates
Run apt install -y --no-install-recommends kcat

Run mkdir -p /kafka/server &&\
	cd /kafka/server &&\
	curl -kvO "https://downloads.apache.org/kafka/3.6.0/kafka_2.13-3.6.0.tgz" 

Run cd /kafka/server &&\
	tar xzvf kafka*.tgz &&\
	rm -rf kafka*.tgz

Run mkdir -p /kafka/config

Run ln -sf /kafka/server/kafka_* /kafka/server/kafka 

VOLUME ["/kafka/config"]
VOLUME ["/kafka/logs"]
EXPOSE 9092

COPY ./entryPoint.sh /entryPoint.sh
COPY ./configIni.sh /configIni.sh
COPY ./testBroker.sh /testBroker.sh

ENTRYPOINT ["/entryPoint.sh"]
CMD ["/kafka/server/kafka/bin/kafka-server-start.sh", "/kafka/config/kraft/kraft.properties"]

