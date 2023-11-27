#!/bin/bash

set -x

DIR_TU="./kafkaTU"

[ -d "${DIR_TU}" ] && rm -rf ./${DIR_TU}/*

docker build -t kfk:poc -f kraft.dockerfile . \
&& docker run -it --rm --name kfk_poc_TU \
	-v ./kafkaTU/config:/kafka/config \
	-v ./kafkaTU/logs:/kafka/logs \
	--env-file testImage.env \
	kfk:poc

	
