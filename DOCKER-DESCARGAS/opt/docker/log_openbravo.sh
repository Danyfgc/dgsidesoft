#!/bin/bash

set -e

ENVIRONMENT=$1

clear && docker exec -it $ENVIRONMENT tail -n 1000 -f /usr/local/tomcat/logs/openbravo.log
