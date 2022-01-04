# standardnotes-onecontainer
My remix of the standalone standardnotes  nodejs version running in a single container. 

## Work in Progress!

### Ports Used
- SYNCING-SERVER is on port 3000
- AUTH is on port 3001
- API-GATEWAY is on port 3002

### Working Directory Setup
1. Create a local working directory and git clone api-gateway, auth, and syncing-server-js
2. Download s6-overlay binary installer (Dockerfile is expecting s6-overlay-amd64-installer) into the root of your working directory.
3. Clone this repository (services, Dockerfile) into the root of your working directory.

### Customize Environment variables
The env.sample file is the consolidation of all the environment variables from each of the standardnotes services.  Modify as required for your environment and make available to your container.

### Prepare to build
The Dockerfile will copy/chmod each service init script (e.g. auth/run) to the /etc/services.d/ folder so that they can be managed by s6-overlay:
- Each run script will set all the environment variables defined in your container (using `with-contenv`).  
- In addition, each run script can be used to fine tune environment variables for each service (e.g. syncing-server PORT is set to 3000, but apigw PORT is set to 3002).  
- So, if you wanted to have a separate db instance for AUTH versus SYNCING-SERVER, you could export new DB_DATABASE variables in the respective run scripts.

### Deploy your container
When you build your container - s6-overlay will be started:
- In turn, s6-overlay will start each service found in /etc/services.d/ .  
- In addition, s6-overlay will create service specific log folders in /var/log/ (e.g. /var/log/authsvr, /var/log/redis).  A log file for the respective service will appear in this folder  
- Connect to your container after starting it and navigate to each /var/log directory and confirm that each service has started successfully.

If everything started - you should be able to connect to api-gateway on port 3002.
