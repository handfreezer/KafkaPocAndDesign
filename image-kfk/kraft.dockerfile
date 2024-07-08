FROM debian:bookworm-20240701

ENV DEBIAN_FRONTEND=noninteractive
ENV KFK_VERSION=3.7.1

RUN apt -y update &&\
	apt -y upgrade &&\
	apt install -y --no-install-recommends \
		vim git curl wget python3 procps

RUN apt install -y --no-install-recommends openjdk-17-jre-headless
RUN apt install -y --no-install-recommends ca-certificates
RUN apt install -y --no-install-recommends kcat

RUN mkdir -p /kafka/bin/server &&\
	cd /kafka/bin/server &&\
	curl -kvO "https://downloads.apache.org/kafka/${KFK_VERSION}/kafka_2.13-${KFK_VERSION}.tgz"  &&\
	tar xzvf kafka*.tgz &&\
	rm -rf kafka*.tgz &&\
	ln -sf /kafka/bin/server/kafka_* /kafka/bin/server/kafka 

RUN mkdir -p /kafka/kraft /kafka/logs /kafka/connect /kafka/mm2 /kafka/libs /kafka/acls

VOLUME ["/kafka/kraft"]
VOLUME ["/kafka/logs"]
VOLUME ["/kafka/connect"]
VOLUME ["/kafka/mm2"]
VOLUME ["/kafka/libs"]
VOLUME ["/kafka/acls"]

EXPOSE 9092
EXPOSE 8083

COPY ./entryPoint.sh /entryPoint.sh
COPY ./configIni.sh /configIni.sh
COPY ./testBroker.sh /testBroker.sh

ENTRYPOINT ["/entryPoint.sh"]
CMD ["kraft"]

