# es-kibana-nginx
Two node Elasticsearch cluster (6.1.2) , with kibana (6.1.2) frontend and nginx.
Docker-based deployment.



Host requirements: 
4 GB RAM. 2 CPU. 40GB Disk space. Ubuntu 14.x or higher. 


To start cluster:

    cd es-kibana-nginx && bash start-cluster.sh kibana-server.domain.com

Script will create two persistent volumes for elasticsearch and dedicated internal network for backend.
It will also install docker-ce and docker-compose, if not installed before.

It will also create following aliases to check elasticsearch cluster

    escluster:  prerry output JSON with the state of elasticsearch cluster.
    esstat:     short output showing cluster state.
    esindex:    list elasticsearch indexes.
    
To use them relogin, or
    
    source ~/.bashrc

elasticsearch will listen on 0.0.0.0:9200 (bridged to docker network)
kibana will not be accesible from outside: all requests will be proxied to it by nginx.

Important: 

    It takes up to 3-5 minutes to kibana service to start, so don`t panic about 'Bad Gateway:502' error 
    from nginx, directly after cluster start.

Monitor logs (console)

Elasticsearch nodes:
    
    docker-compose -f cluster/docker-compose.yml logs -f --tail='20' elasticsearch
    
    docker-compose -f cluster/docker-compose.yml logs -f --tail='20' elasticsearch2

Kibana:
    
    docker-compose -f cluster/docker-compose.yml logs -f --tail='20' kibana

Nginx:
    
    docker-compose -f cluster/docker-compose.yml logs -f --tail='20' web
    

To destroy cluster:

    cd es-kibana-cluster && destroy-cluster.sh
    
    Choose 'y' and then choose 'all' if you want to destroy persistent volumes and elasticsearch data
    or 'srv' to remove services only, leaving elasticsearch data on disk.
