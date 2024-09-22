#!/bin/bash

function kafkaAclSrc() {
	iHost=$1
	shift
	kafka-acls.sh --bootstrap-server kfkbrksrc-${iHost}:9092 --command-config /kafka/acls/config.src.acls "${@}"
}
function kafkaAclDst() {
	iHost=$1
	shift
	kafka-acls.sh --bootstrap-server kfkbrkdst-${iHost}:9092 --command-config /kafka/acls/config.dst.acls "${@}"
}

if [ 0 -ne "${#}" ]
then
	cluster=${1}
	shift
	iHost=${1}
	shift
	kafkaAcl${cluster} ${iHost} "${@}"
else
	clear
	
	echo
	echo "====== ACLs List of Source Cluster ==================================="
	echo
	kafkaAclSrc 00 --list
	echo
	echo "====== ACLs List of Destination Cluster =============================="
	echo
	kafkaAclDst 00 --list
	echo
	echo "======================================================================"
	echo
	
	echo "Inserting ACLs for kafka-ui as read-only browser"
	principal="AclRegex:OU=kfk-brk-ui,"
	for host in 00
	do
		kafkaAclSrc ${host} --topic "*" --add --allow-principal ${principal}   --allow-host "*" --operation Read --operation DescribeConfigs
		kafkaAclDst ${host} --topic "*" --add --allow-principal ${principal}   --allow-host "*" --operation Read --operation DescribeConfigs
		kafkaAclSrc ${host} --cluster "*" --add --allow-principal ${principal} --allow-host "*" --operation Describe --operation DescribeConfigs
		kafkaAclDst ${host} --cluster "*" --add --allow-principal ${principal} --allow-host "*" --operation Describe --operation DescribeConfigs
		kafkaAclSrc ${host} --group "*" --add --allow-principal ${principal}   --allow-host "*" --operation Describe
		kafkaAclDst ${host} --group "*" --add --allow-principal ${principal}   --allow-host "*" --operation Describe
	done
	
	echo "Inserting ACLs for producer on Source Cluster only"
	principal="User:CN=producer,OU=kfk-brk-src,O=POC,L=IDF,C=FR"
	for host in 00
	do
		kafkaAclSrc ${host} --topic "*" --add --allow-principal ${principal}   --allow-host "*" --operation Create --operation Read --operation Write
	done

	echo "Inserting ACLs for Connect Cluster on Destination Cluster only"
	principal="AclRegex:CN=cluster-connect-dst,"
	for host in 00
	do
		kafkaAclDst ${host} --add --allow-principal ${principal}   --allow-host "*" --operation Create --operation Read --operation Write \
			--topic ConnectClusterGroupId-Offsets \
			--topic ConnectClusterGroupId-Configs \
			--topic ConnectClusterGroupId-Status
		kafkaAclDst ${host} --add --allow-principal ${principal}   --allow-host "*" --operation All \
			--group ConnectClusterGroupId 
	done

	echo "Inserting ACLs for MM2 instance : read on Src"
	principal="AclRegex:OU=kfk-mm2-src,"
	for host in 00
	do
		kafkaAclSrc ${host} --topic "*" --add --allow-principal ${principal}   --allow-host "*" --operation Read --operation DescribeConfigs
		kafkaAclSrc ${host} --cluster "*" --add --allow-principal ${principal} --allow-host "*" --operation Describe --operation DescribeConfigs
		kafkaAclSrc ${host} --group "*" --add --allow-principal ${principal}   --allow-host "*" --operation Describe
	done

	echo "Inserting ACLs for MM2 instance : write on Dst"
	principal="AclRegex:OU=kfk-mm2-dst,"
	for host in 00
	do
		kafkaAclDst ${host} --topic 'heartbeats' --add --allow-principal ${principal}   --allow-host "*" --operation All
		kafkaAclDst ${host} --resource-pattern-type "PREFIXED" --topic "cluster-src" --add --allow-principal ${principal}   --allow-host "*" --operation All
	#	kafkaAclDst ${host} --topic "*" --add --allow-principal ${principal}   --allow-host "*" --operation All
	#	kafkaAclDst ${host} --cluster "*" --add --allow-principal ${principal} --allow-host "*" --operation All
	#	kafkaAclDst ${host} --group "*" --add --allow-principal ${principal}   --allow-host "*" --operation All
	done

	echo
	echo "====== ACLs List of Source Cluster ==================================="
	echo
	kafkaAclSrc 00 --list
	echo
	echo "====== ACLs List of Destination Cluster =============================="
	echo
	kafkaAclDst 00 --list
	echo
	echo "======================================================================"
	echo
fi

