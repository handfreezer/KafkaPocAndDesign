#!/bin/bash

CA_DIR="/generate-tls/CA"
PWD_P12="PwdP12"
PWD_JKS="PwdJks"
FORCE_RENEW_KEY=0

if [ -e "${CA_DIR}/ca.jks" ]
then
	echo "Key for [POC CA] already exist, no change"
else
	echo "Generate master CA"
	openssl req -new -nodes -x509 -days 365 -newkey rsa:4096 \
		-keyout "${CA_DIR}/ca.key" -out "${CA_DIR}/ca.crt" -config "${CA_DIR}/ca.cnf"
	echo "Forcing renew of ey for all signed certificates of client"
	FORCE_RENEW_KEY=1
	keytool -keystore "${CA_DIR}/ca.jks" \
		-alias CA-POC \
		-import -file "${CA_DIR}/ca.crt" \
		-storepass "${PWD_JKS}" -storetype PKCS12 \
		-noprompt
fi

function generateClientKey() {
	BRK_NAME="${1}"
	if [ -e "${CA_DIR}/${BRK_NAME}.p12.jks" -a 0 -eq ${FORCE_RENEW_KEY} ]
	then
		echo "Key for [${BRK_NAME}] already exist, no change"
	else
		echo "Generate certificate for ${BRK_NAME}"
		openssl genrsa -out "${CA_DIR}/${BRK_NAME}.key" 4096
		openssl req -new -config "${CA_DIR}/${BRK_NAME}.cnf" -key "${CA_DIR}/${BRK_NAME}.key" -out "${CA_DIR}/${BRK_NAME}.csr"
		#Easiest way, but not secured
		#openssl x509 -req -days 364 -sha256 -copy_extensions copyall -in "${CA_DIR}/${BRK_NAME}.csr" -CA "${CA_DIR}/ca.crt" -CAkey "${CA_DIR}/ca.key" -CAcreateserial -out "${CA_DIR}/${BRK_NAME}.crt"
		openssl x509 -req -days 364 -sha256 \
			-CA "${CA_DIR}/ca.crt" -CAkey "${CA_DIR}/ca.key" -CAcreateserial \
			-in "${CA_DIR}/${BRK_NAME}.csr" -out "${CA_DIR}/${BRK_NAME}.crt" \
			-extfile "${CA_DIR}/${BRK_NAME}.cnf" -extensions v3_req
		openssl pkcs12 -export \
			-in "${CA_DIR}/${BRK_NAME}.crt" \
			-inkey "${CA_DIR}/${BRK_NAME}.key" \
			-chain -CAfile "${CA_DIR}/ca.crt" \
			-name ${BRK_NAME} \
			-out "${CA_DIR}/${BRK_NAME}.p12" \
			-password "pass:${PWD_P12}"
		keytool -importkeystore \
			-srcstoretype PKCS12 -srcstorepass ${PWD_P12} -srckeystore "${CA_DIR}/${BRK_NAME}.p12" \
			-deststoretype PKCS12 -deststorepass ${PWD_JKS} -destkeystore "${CA_DIR}/${BRK_NAME}.p12.jks" \
			-noprompt
		cp ${CA_DIR}/ca.{crt,jks} "${CA_DIR}/${BRK_NAME}/"
		cp "${CA_DIR}/${BRK_NAME}.p12.jks" "${CA_DIR}/${BRK_NAME}/server.jks"
	fi
}

generateClientKey "kfkbrksrc-00"
generateClientKey "kfkbrksrc-01"
generateClientKey "kfkbrkdst-00"
generateClientKey "kfkbrkdst-01"
generateClientKey "kafka-ui"
generateClientKey "connect"
echo "Generate ended"
