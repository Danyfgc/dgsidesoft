#!/bin/bash

set -e

ENVIRONMENT=$1

PATH_ENV="/opt/openbravo/$ENVIRONMENT"

docker exec openbravo bash -c "cd $PATH_ENV && ant export.config.script"