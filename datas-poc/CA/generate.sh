#!/bin/bash

CA_DIR="/generate-tls/CA"
PWD_P12="PwdP12"
PWD_JKS="PwdJks"
FORCE_RENEW_KEY=0

export caRoot=""

function generateCA() {
	caRoot="ca-${1:-"master"}"
	if [ -e "${CA_DIR}/${caRoot}.jks" ]
	then
		echo "Key for [POC CA ${caRoot}] already exist, no change"
	else
		echo "Generate master CA"
		openssl req -new -nodes -x509 -days 365 -newkey rsa:4096 \
			-keyout "${CA_DIR}/${caRoot}.key" -out "${CA_DIR}/${caRoot}.crt" -config "${CA_DIR}/${caRoot}.cnf"
		echo "Forcing renew of ey for all signed certificates of client"
		FORCE_RENEW_KEY=1
		keytool -keystore "${CA_DIR}/${caRoot}.jks" \
			-alias CA-POC \
			-import -file "${CA_DIR}/${caRoot}.crt" \
			-storepass "${PWD_JKS}" -storetype PKCS12 \
			-noprompt
	fi
}

function generateClientKey() {
	CLIENT_NAME="${1}"
	CLIENT_CRT="${caRoot}-${CLIENT_NAME}"
	if [ -e "${CA_DIR}/${CLIENT_CRT}.p12.jks" -a 0 -eq ${FORCE_RENEW_KEY} ]
	then
		echo "Key for [${CLIENT_CRT}] already exist, no change"
	else
		echo "Generate certificate for ${CLIENT_CRT}"
		openssl genrsa -out "${CA_DIR}/${CLIENT_CRT}.key" 4096
		openssl req -new -config "${CA_DIR}/${CLIENT_CRT}.cnf" -key "${CA_DIR}/${CLIENT_CRT}.key" -out "${CA_DIR}/${CLIENT_CRT}.csr"
		#Easiest way, but not secured
		#openssl x509 -req -days 364 -sha256 -copy_extensions copyall -in "${CA_DIR}/${CLIENT_CRT}.csr" -CA "${CA_DIR}/${caRoot}.crt" -CAkey "${CA_DIR}/${caRoot}.key" -CAcreateserial -out "${CA_DIR}/${CLIENT_CRT}.crt"
		openssl x509 -req -days 364 -sha256 \
			-CA "${CA_DIR}/${caRoot}.crt" -CAkey "${CA_DIR}/${caRoot}.key" -CAcreateserial \
			-in "${CA_DIR}/${CLIENT_CRT}.csr" -out "${CA_DIR}/${CLIENT_CRT}.crt" \
			-extfile "${CA_DIR}/${CLIENT_CRT}.cnf" -extensions v3_req
		openssl pkcs12 -export \
			-in "${CA_DIR}/${CLIENT_CRT}.crt" \
			-inkey "${CA_DIR}/${CLIENT_CRT}.key" \
			-chain -CAfile "${CA_DIR}/${caRoot}.crt" \
			-name ${CLIENT_NAME} \
			-out "${CA_DIR}/${CLIENT_CRT}.p12" \
			-password "pass:${PWD_P12}"
		keytool -importkeystore \
			-srcstoretype PKCS12 -srcstorepass ${PWD_P12} -srckeystore "${CA_DIR}/${CLIENT_CRT}.p12" \
			-deststoretype PKCS12 -deststorepass ${PWD_JKS} -destkeystore "${CA_DIR}/${CLIENT_CRT}.p12.jks" \
			-noprompt
		if [ ! "mm2" = "${CLIENT_NAME:0:3}" ]
		then
			cp ${CA_DIR}/${caRoot}.{jks,crt} "${CA_DIR}/${CLIENT_NAME}/"
			cp "${CA_DIR}/${CLIENT_CRT}.p12.jks" "${CA_DIR}/${CLIENT_NAME}/${CLIENT_CRT}.jks"
		else
			cp "${CA_DIR}/${caRoot}.jks" "${CA_DIR}/mm2/${caRoot}.jks"
			cp "${CA_DIR}/${CLIENT_CRT}.p12.jks" "${CA_DIR}/mm2/${CLIENT_CRT}.jks"
		fi
	fi
}

generateCA "src"
generateClientKey "kfkbrksrc-00"
generateClientKey "kfkbrksrc-01"
generateClientKey "producer"
generateClientKey "kafka-ui"
generateClientKey "mm2-poc"

generateCA "dst"
generateClientKey "kfkbrkdst-00"
generateClientKey "kfkbrkdst-01"
generateClientKey "connect"
generateClientKey "kafka-ui"
generateClientKey "mm2-poc"

echo "Generate ended"
