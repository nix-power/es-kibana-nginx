#!/bin/bash
OK=0
ERROR=1

remove_cluster='no'
remove_data='no'

echo "This is destructive action, es cluster nodes and data can be destroyed"

while true; do
  read -p "Are you sure ? [y|n] " yn
  case ${yn} in
    [Yy]* ) remove_cluster='yes'; break     ;;
    [Nn]* ) remove_cluster='no'; break      ;;
    *     ) echo 'Choose [Y|y]es or [N|n]o' ;;
   esac
done

if [[ $remove_cluster == 'no' ]]; then
  echo 'Aborting'
  exit $ERROR
else
  sed -i "s/^\s\+server_name.\+$/  server_name server1.domain.com server1;/" cluster/conf/nginx/default.conf
  echo "You have choosen to destroy cluster, remove it with data [all] or services only [srv]"
  while true; do
  read -p "Remove cluster only, or cluster with elasticsearch data ? [srv|all] " choice
    case ${choice} in
      "srv" ) docker-compose -f cluster/docker-compose.yml down && docker network rm esnet 2>/dev/null
              echo "Elasticsearch cluster shut down and deleted. Data saved on docker persistent volumes es1-data and es2-data"
              exit $OK
      ;;
      "all" ) docker-compose -f cluster/docker-compose.yml down
              docker volume rm -f es1-data 2>/dev/null && docker volume rm -f  es2-data 2>/dev/null
              docker network rm esnet 2>/dev/null
              echo "Elasticsearch cluster shut down and deleted. Data and all relevant docker infrastructure components removed"
              exit $OK
      ;;
      *    ) echo "Type 'all' or 'srv'"
      ;;
    esac
  done
fi  
