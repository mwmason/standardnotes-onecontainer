# standardnotes-onecontainer
My remix of the standalone standardnotes  nodejs version running in a single container.  Leverages [s6-overlay v3.](https://github.com/just-containers/s6-overlay)

## Work in Progress!
**Please deploy/test in a non-production environment, and ensure you have adequate database backups with tested restore procedures before attempting to deploy this to production!**

### Overview
Rather than run each of the standardnotes services in separate containers, we can deploy a process supervisor like s6-overlay which will init each service honoring their dependencies.  The deployment of the required MySQL database instance is not addressed in this project.

### Ports Used  
|Service|Port|
|-----|-----|
|Syncing Server|3000|
|Auth| 3001|
|Api-Gateway|3002|
|Redis|6379|

Standardnotes services' healthcheck will be available on localhost:port/healthcheck (e.g., http://localhost:3002/healthcheck) and only Api-Gateway needs to be exposed to support client connections.

### Working Directory Setup
1. Clone this repository into the root of your working directory. 
2. Dockerfile will add the following versions to the container image: 
   | Component | Version |  
   |-----|-----|
   |s6-overlay x86_64/amd64|v3.1.0.1|    
   |SN Service auth|v1.44.1|  
   |SN Service syncing-server-js|v1.52.1|   
   |SN Service api-gateway|v1.37.0|  
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
5. Each service directory will have the required files ``run`` and ``type``, and for dependency definition, the optional files ``dependencies``, ``notification-fd`` and ``data/check``.   
   - If a service is a dependency for another service, the prerequisite service will also have a ``data/check`` directory/file where ``check`` will contain the script necessary to inform s6-overlay that the owning service has successfully started and is active.  For example, redis is a prerequisite for authsvr and syncsvr; its ``data/check`` file contains a redis PING and verifies a PONG is received, returning the result of this check to s6-overlay.  
   - Both authsvr and syncsvr have an optional ``dependencies`` file that contain the service name ``redis``.  s6-overlay will ensure redis has successfully started and confirmed that it is active before starting its dependent services, authsvr and syncsvr.
   - apigw has a defined dependency on authsvr
7. The services directory also contains a ``contents`` directory. 
   - ``contents`` has an empty file with a matching filename for each service (defined by a service directory) to be managed by s6-overlay.  
   - A service file exists for the 4 services and 4 loggers.  Only services listed in ``contents`` will be initialized by s6-overlay; feel free to remove the logger files if you'd rather everything logged to stdout.
9. Optional logger services have also been defined.  In addition to the required files ``run`` and ``type``, logger coordination requires either the existence of either the file ``producer-for`` or ``consumer-for``:
   - ``producer-for`` should be located in the service directory for the service that is producing log output.  The file contains the name of its paired logger (e.g., redis service ``producer-for`` contains the service name ``redis-log``)
   - ``consumer-for`` is located in the service directory for the logger service consumes (and then writes) logs for.  The file contains the name of its paired service (e.g., redis-log service ``consumer-for`` file contains the service name ``redis``)  


### Customize Environment variables
The env.sample file is the consolidation of all the environment variables from each of the standardnotes services.  DB variables (host, databasename, user, password, etc.) should be modified here.  In addition, any other standardnotes customization should be set here.    

Each standardnotes service ``run`` script imports the container environment variables using s6-overlay's ``with-contenv`` utility.  However, as required, these variables can be overriden for the service (e.g. ``PORT`` is set separately in each ``run``).  Feel free to add any required variables for your environment.

### Deploy your container
When you run your container - s6-overlay will be started, which will s6-overlay will start each service:
   1. redis
   2. authsvr
   3. synsvr
   4. api-gateway  

### Verify your deployment
- The optional loggers will be started and their output can be found in /var/log/servicename (e.g. /var/log/authsvr).
- Monitor stdout or review each service log to verify the container has started successfully.   
- Further verify each service using its respective healtcheck (e.g. redis ping, //localhost:port/healthcheck) 

**Connect your app on the container exposed port for 3002 - and start taking notes!**
