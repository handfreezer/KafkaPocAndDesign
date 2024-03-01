  MirrorHeartBeatConfig "security.protocol":"SSL",
  AdminConfig "target.cluster.security.protocol":"SSL",
  ProducerConfig : "producer.override.security.protocol":"SSL",

  MirrorCheckpointConnector 
	"source.cluster.security.protocol"
	"target.cluster.security.protocol"

  MirrorSourceConnector
	"source.cluster/target.cluster/producer.override"

