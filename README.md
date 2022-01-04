# standardnotes-onecontainer
My remix of the standalone standardnotes  nodejs version running in a single container.  

Create a local working directory and git clone api-gateway, auth, and syncing-server-js

Download s6-overlay binary installer (Dockerfile is expecting s6-overlay-amd64-installer) into the root of your working directory.

Clone this repository (services, Dockerfile) into the root of your working directory.

The env.sample file is the consolidation of all the environment variables from each of the standardnotes services.  Modify as required for you environment and make available to your container.

The Dockerfile will copy/chmod each service init script (e.g. auth/run) to the /etc/services.d/ folder so that they can be managed by s6-overlay.  Each run script will set all the environment variables defined in your container (using `with-contenv`).  In addition, each run script can be used to fine tune environment variables for each service (e.g. syncing-server PORT is set to 3000, but apigw PORT is set to 3002).  In particular authsvr/run and syncsvr/run both have DB_DATABASE (and DB_USERNAME) environment variables that need to match your local environment.


Assumes you have https://github.com/just-containers/s6-overlay/releases/tag/v2.2.0.3 
