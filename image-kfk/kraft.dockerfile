From debian:bookworm-20240211

env DEBIAN_FRONTEND=noninteractive

Run apt -y update &&\
	apt -y upgrade &&\
	apt install -y --no-install-recommends \
		vim git curl wget python3 procps

Run apt install -y --no-install-recommends openjdk-17-jre-headless
Run apt install -y --no-install-recommends ca-certificates
Run apt install -y --no-install-recommends kcat

Run mkdir -p /kafka/bin/server &&\
	cd /kafka/bin/server &&\
	curl -kvO "https://downloads.apache.org/kafka/3.6.1/kafka_2.13-3.6.1.tgz"  &&\
	tar xzvf kafka*.tgz &&\
	rm -rf kafka*.tgz &&\
	ln -sf /kafka/bin/server/kafka_* /kafka/bin/server/kafka 

Run mkdir -p /kafka/kraft /kafka/logs /kafka/connect /kafka/mm2

VOLUME ["/kafka/kraft"]
VOLUME ["/kafka/logs"]
VOLUME ["/kafka/connect"]
VOLUME ["/kafka/mm2"]

EXPOSE 9092
EXPOSE 8083

COPY ./entryPoint.sh /entryPoint.sh
COPY ./configIni.sh /configIni.sh
COPY ./testBroker.sh /testBroker.sh

ENTRYPOINT ["/entryPoint.sh"]
CMD ["kraft"]

