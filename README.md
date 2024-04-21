Note : this README will have to be updated! in fact, here, there is a working POC with full ciphering SSL, authentication, two kafka broker cluster (src and dst), a connect cluster on dst side, kafka-ui configured, ACLs defined in a restrctive way, AND a MM2 (MirrorMaker 2) deployed in the connect cluster!

Build source cluster

Build dst cluter

instanciate a connect cluster on dst

launch kafka-ui (on 8080, but nw, there is also a simple conf for AKHQ on 8081 :-) ) to play with the poc

One SMT (Simple Message Transform) exemple : inserting a uuid in headers (have a look on abstract, as you can work on key or value for a peny)

One Replication Policy as exemple BUT very useful : a regex one : RegexReplicationPolicy !

O, yeah!

Note : SMT and replication policy was getting out to https://github.com/handfreezer/KafkaConnectExtensions and should be used by calling ./init-poc.sh the first time of use to get release binaries from this repo.
