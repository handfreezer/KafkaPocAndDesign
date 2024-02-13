Build source cluster

Build dst cluter

instanciate a connect cluster on dst

launch kafka-ui (on 8080, but nw, there is also a simple conf for AKHQ on 8081 :-) ) to play with the poc

One SMT (Simple Message Transform) exemple : inserting a uuid in headers (have a look on abstract, as you can work on key or value for a peny)

One Replication Policy as exemple BUT very useful : a regex one : RegexReplicationPolicy !

O, yeah!

Note : SMT and replication policy was getting out to https://github.com/handfreezer/KafkaConnectExtensions and should be used by calling ./init-poc.sh the first time of use to get reease binaries from this repo.
