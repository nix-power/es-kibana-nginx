#!/bin/bash
OK=1
ERROR=1
COMPOSE_VER='1.18.0'
SERVER_NAME=''

check_curl() {
  test -x $(which curl)

  if [[ $? -ne 0 ]]; then
    echo "Please install curl package before proceeding"
    exit $ERROR
  fi
}

check_docker() {
  test -x $(which docker)

  if [[ $? -ne 0 ]]; then
    add_docker_repo
    install_docker
  fi

   test -x $(which docker-compose)

   if [[ $? -ne 0 ]]; then
     install_docker_compose
   fi
}

add_docker_repo() {
  apt-get update && apt-get -y install curl software-properties-common
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
  add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
  apt-get update
}

install_docker() {
  apt-get install -y docker-ce
}

install_docker_compose() {
  curl -sL https://github.com/docker/compose/releases/download/${COMPOSE_VER}/docker-compose-`uname -s`-`uname -m` -o /usr/bin/docker-compose
  chmod +x /usr/bin/docker-compose
}

create_volumes_and_net() {
  echo "Creating network and persistent volumes for es cluster"
  /bin/bash cluster/net_and_volume.sh
}

main() {
  sleep 2
  check_curl
  if [[ "$#" -eq 0 ]]; then
    echo "Provide FQDN of the server name to configure nginx"
    exit $ERROR
  else
    SERVER_NAME="$1"
    SHORT_SERVER_NAME=$(echo $SERVER_NAME | sed 's/\..*//')
    sed -i "s/^\s\+server_name.\+$/  server_name ${SERVER_NAME} ${SHORT_SERVER_NAME};/" cluster/conf/nginx/default.conf
  fi 
 
  echo "Starting and configuring two node elasticsearch cluster with kibana and nginx"
  
  check_docker
  create_volumes_and_net
  cd cluster && docker-compose up -d

  if [[ $? -eq 0 ]]; then
    INTERNALIP=$(curl -s icanhazip.com)
    sleep 2

    echo 'Creating mgmt aliases'
    grep 'escluster' ~/.bashrc ||  echo "alias escluster='curl http://127.0.0.1:9200/_cluster/health?pretty'" >> ~/.bashrc
    grep 'esindex'   ~/.bashrc ||  echo "alias esindex='curl -X GET  http://127.0.0.1:9200/_cat/indices?v'" >> ~/.bashrc
    grep 'esstat'    ~/.bashrc ||  echo "alias esstat='curl http://127.0.0.1:9200/_cat/health'" >> ~/.bashrc

    sleep 2
  
    echo "elasticsearch cluster is ready. You can acceess it via http://${INTERNALIP} or http://${SERVER_NAME}."

    echo 'Attention: it takes up to 5 minutes to kibana frontend to start, so don`t afraid of 502 Nginx error in first minutes'
    echo 'To check status of kibana frontend execute: docker-compose -f cluster/docker-compose.yaml logs --f -tail='15' kibana'
    echo 'To check health of your cluster run esstat or escluster coomand'
    echo 'To see all indexes in elasticsearch use esindex command'
    exit $OK
  else
    echo 'Error creating and configuring es cluster, - check logs or run manually'
    exit $ERROR
  fi 
}

main "$@"
