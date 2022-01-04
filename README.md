# standardnotes-onecontainer
My remix of the standalone standardnotes  nodejs version running in a single container.  

Create a local working directory and git clone api-gateway, auth, and syncing-server-js

Download s6-overlay binary installer (Dockerfile is expecting s6-overlay-amd64-installer) into the root of your working directory.

Clone this repository (services, Dockerfile) into the root of your working directory.

The env.sample file is the consolidation of all the environment variables from each of the standardnotes services.  Modify as required for you environment and make available to your container.


Assumes you have https://github.com/just-containers/s6-overlay/releases/tag/v2.2.0.3 
