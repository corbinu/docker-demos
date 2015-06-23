Docker Demos
=================

This is the top level repo for a set of Docker Demos. 

They use [Consul](https://www.consul.io) for service discovery and demonstrate how to wrap the various parts of an application in Docker containers. 

The purpose being to show an Architecture that can be used for in container development on a developer machine, scaled directly to production via docker-compose and run benchmarks by swapping various application components easily as they are in their own container and also benchmark environments. 

## Current
Currently the simple-couchbase example is the only option which brings up a Consul, a scalable Couchbase Cluster, and a Demo Node.js app with an Angular GUI.

The Couchbase cluster can be be called up dynamically via docker-compose the details are in the read me in [simple-couchbase](https://github.com/corbinu/docker-demos/blob/master/simple-couchbase/README.md)

They are currently tested on strait docker, boot2docker and Joyent's [Triton](https://www.joyent.com/blog/understanding-triton-containers)

## Plans
Some general plans how ever please feel free to open issues with ideas.

* Currently the containers use bash scripts for service discovery. These will be replaced with a node.js app that not only starts and bootstraps the applications but also does health checking. This should also make the app scalable also.
* The start.sh script will also be replaced with a node.js cli app that can also scale down and report cluster health.
* Break the UI into its own container using Nginx
* Consul configured HAProxy which sit its own container in front of the ode API and UI app* 
* Make the [ACMEAir](https://github.com/acmeair/acmeair-nodejs) demo also run via this architecture. (This also means consul containers for MongoDB and Cassandr
* Create consul containers for Elasticsearch, Logstash and Kibana)
* Write a new demo based on the Couchbase and ACMEAir ones which supports logging and full text search with ELK and supports Couchbase, MongoDB and Cassandra
* Benchmarking container which will test the various database options on what ever architecture the cluster is brought up on