#!/bin/bash

#set -x

if [ ${#} -ne 2 ]; then
	echo "Usage: ${0} [PREFIX] [INI_FILE]"
	exit 1
fi

export PREFIX=${1}
export INI_FILE=${2}

echo "" >> ${INI_FILE}
for VAR_NAME in $(env | grep "^${PREFIX}_[^=]\+=.\+" | sed -r "s/${PREFIX}_([^=]*)=.*/\1/g"); do
	ENV_VAR=${PREFIX}_${VAR_NAME}
	FILE_VAR=$(sed -r "s/_/./g" <<<${VAR_NAME,,})
	CONTENT_VAR=${!ENV_VAR}
	echo "Discovered ${VAR_NAME} [${FILE_VAR}=${CONTENT_VAR}]"
	sed -e "/${FILE_VAR}/Id" -i ${INI_FILE}
	echo "${FILE_VAR}=${CONTENT_VAR}" >> ${INI_FILE}
done

for VAR_NAME in $(env | grep "^${PREFIX}-DEL_[^=]\+=.\+" | sed -r "s/${PREFIX}-DEL_([^=]*)=.*/\1/g"); do
	ENV_VAR=${PREFIX}-DEL_${VAR_NAME}
	FILE_VAR=$(sed -r "s/_/./g" <<<${VAR_NAME,,})
	echo "Discovered ${VAR_NAME} [${FILE_VAR}] to be deleted"
	sed -e "/${FILE_VAR}/Id" -i ${INI_FILE}
done

#Cleanning : removing comment lines
sed -e "s/[[:space:]]*#.*$//;/^$/d" -i ${INI_FILE}
sort -o ${INI_FILE} ${INI_FILE}

