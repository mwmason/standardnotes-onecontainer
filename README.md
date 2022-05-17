# standardnotes-onecontainer
My remix of the standalone standardnotes  nodejs version running in a single container.  Leverages [s6-overlay v3.](https://github.com/just-containers/s6-overlay)

## Work in Progress!
**Please deploy/test in a non-production environment, and ensure you have adequate database backups with tested restore procedures before attempting to deploy this to production!**

### Overview
Rather than run each of the standardnotes services in separate containers, we can deploy a process supervisor like s6-overlay which will init each service honoring their dependencies.  The deployment of the required MySQL database instance is not addressed in this project.

### Ports Used
- REDIS 6379
- SYNCING-SERVER is on port 3000
- AUTH is on port 3001
- API-GATEWAY is on port 3002 

### Working Directory Setup
1. Clone this repository into the root of your working directory. 
2. Dockerfile will add the following versions to the build image:  
   a. s6-overlay x86_64 /amd64 v3.1.0.1  
   b. SN Service auth v1.44.1  
   c. SN Service syncing-server-js v1.52.1  
   d. SN Service api-gateway v1.37.0  
3. s6-overlay scripts are in:  
   a. services/apigw  
   b. services/authsvr  
   c. services/redis  
   d. services/syncsvr  
4. Optional loggers are defined in:  
   a. services/apigw-log  
   b. services/authsvr-log  
   c. services/redis-log  
   d. services/syncsvr-log  
5. Each service directory will have a required ``run``, ``type`` and an optional ``dependencies``, ``notification-fd``, and either ``consumer-for`` or ``producer-for``.  If a service is a dependency for another service, the prerequisite service will also have a ``data/check`` directory/file where ``check`` will contain the script necessary to inform s6-overlay that the owning service has successfully started and is active.  For example, redis is a prerequisite for authsvr and syncsvr; its ``data/check`` file contains a redis PING and verifies a PONG is received, returning the result of this check to s6-overlay.  Both authsvr and syncsvr have an optional ``dependencies`` file that contain the service name ``redis``.  s6-overlay will ensure redis has successfully started and confirmed that it is active before starting the dependent services authsvr and syncsvr.
6. The services directory also contains a ``contents`` directory.  ``contents`` has an empty file with a matching filename for each service (defined by a service directory) to be managed by s6-overlay.  A service file exists for the 4 services and 4 loggers.  Only services listed in ``contents`` will be initialized by s6-overlay; feel free to remove the logger files if you'd rather everything logged to stdout.
7. Finally, logger services rely on two files ``produce-for`` which names the logger for which this service produces logs, and ``consumer-for`` which names which service this logger consumes (and then writes) logs for.  


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
