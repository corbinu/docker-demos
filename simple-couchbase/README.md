# Simple Couchbase Node.js Example on a cluster in Docker containers

This example uses a Docker Compose file and a shell script that will deploy a Couchbase cluster that can be scaled easily using `docker compose scale couchbase=$n`.

It is tested on straight docker, boot2docker and Joyent's [Triton](https://www.joyent.com/blog/understanding-triton-containers).

Much thanks to [Casey Bisson](https://github.com/misterbisson) who created the original version.


## Requirements
1. [Docker](https://docs.docker.com/)
2. [Docker Compose](https://docs.docker.com/compose/install/)


## Easy instructions

1. clone or download this repo.
1. `cd` into the cloned or downloaded directory.
1. Execute `bash start.sh` to start everything up.
1. The Couchbase dashboard should automatically open. Sign in with the user/pass printed in the output of `bash start.sh` to see the working, one node cluster.
1. Scale the cluster using `docker-compose --project-name=sncb scale up couchbase=$n` and watch the node(s) join the cluster in the Couchbase dashboard.

The UI for the demo app will be on a port mapped to 3000 on the demo container.


## Detailed instructions

The [`start.sh` script](https://raw.githubusercontent.com/corbinu/docker-demos/master/simple-couchbase/start.sh) automatically does the following:

```bash
docker-compose pull
docker-compose --timeout=700 --project-name=sncb up -d --no-recreate
```

Those Docker Compose commands read the [docker-compose.yml](https://raw.githubusercontent.com/corbinu/docker-demos/master/simple-couchbase/docker-compose.yml), which describes the three services in the app. The second command, we can call it `docker-compose up` for short, provisions a single container for each of the services.

The three services include:

- Couchbase, the database at the core of this application
- Consul, to support service discovery and health checking among the different services
- [Couchbase Node Demo](https://github.com/corbinu/consul-node-demo), a simple node travel app.

Consul is running in its default configuration as delivered in [Jeff Lindsay's excellent image](https://registry.hub.docker.com/u/progrium/consul/).

Once the first set of containers is running, the `start.sh` script bootstraps the Couchbase container with the following command:

```bash
docker exec -it ccic_couchbase_1 consul-couchbase-bootstrap bootstrap
```

## Bootstrapping Couchbase

The [Couchbase bootstrap script](https://raw.githubusercontent.com/corbinu/consul-couchbase/master/bin/consul-couchbase-bootstrap) does the following:

1. Set some environmental variables
1. Wait for the Couchbase daemon to be responsive
1. Check if Couchbase is already configured
    1. The boostrap will exit if so
1. Check if Consul is responsive
    1. The bootstrap will exit if Consul is unreachable
1. Initializes the Couchbase node
1. Check for any arguments passed to the bootstrap script
    1. If the script is manually called with the `bootstrap` argument, it does the following:
        1. Initializes the Couchbase cluster
        1. Creates a data bucket if the bucket name is set via $CB_BUCKET
    1. Otherwise, it will...
        1. Check Consul for an established Couchbase cluster
        1. Join the cluster
        1. Rebalance the cluster
1. Check that the cluster is healthy.
1. Register the service with Consul
