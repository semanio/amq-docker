amq-docker
==============

This project builds a [docker](http://docker.io/) container for running Apache ActiveMQ message broker. It can be also used to form clusters of activeMQ brokers. Multiple protocols are supported i.e. MQTT, AMQP 1.0, Openwire and web sockets

Try it out
----------
I haven't as yet added this to the Docker Repository so you'll have to follow the instructions for building it locally.

Once installed you should be able to try it out via

    docker run -P -d -it --name amq1 --env NC_DUPLEX=true --env NC_TTL=5 --env hostname=localhost -p 8161:8161 -p 61616:61616 amq:amq

You can also add network connectors by using the --link argument when running the container. The duplex and TTL settings for these network connectors can also be set using --env variables.

For example the following code will setup and network of four activemq brokers capable of passing message back and forth


 amq1<-------|
 
             amq-central<----->amq3 
 
 amq2<-------|


	docker run  -d -P --name amq1 --env NC_DUPLEX=true --env NC_TTL=5 amq:amq
	
	docker run  -d -P --name amq2 --env NC_DUPLEX=true --env NC_TTL=5 amq:amq
	
	docker run  -d -P --name amq-central --link amq1:east1 --link amq2:east2  --env NC_DUPLEX=true --env NC_TTL=5 amq:amq
	
	docker run  -d -P --name amq3  --link amq-central:central --env NC_DUPLEX=true --env NC_TTL=5 amq:amq

There is no security settings configured on the ActiveMQ brokers


Building the docker container locally
-------------------------------------
Once you have [installed docker](https://www.docker.io/gettingstarted/#h_installation) you should be able to create the containers via the following:

git clone https://github.com/noelo/amq-docker.git

docker build -t amq:amq .


