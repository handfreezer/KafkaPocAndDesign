#!/bin/bash

set -x

BASE_DIR="/generate-tls"
CA_DIR="${BASE_DIR}/CA"
export $(cat .env|xargs)

docker run -i --rm -v ./datas-poc/:${BASE_DIR} ${IMG_KFK} shell <<<"${CA_DIR}/generate.sh"

