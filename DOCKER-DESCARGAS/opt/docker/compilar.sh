#!/bin/bash

set -e

ENVIRONMENT=$1
BACKUP_DEPLOYMENT=false
BACKUP_SOURCE=false
BACKUP_DATABASE=false
ANT_CLEAN=true
ANT_UPDATE_DATABASE=false
ANT_COMPILE_COMPLETE=true
ANT_SMARTBUILD=false

/srv/ob_scripts/bash/compile_openbravo.sh $ENVIRONMENT $BACKUP_DEPLOYMENT $BACKUP_SOURCE $BACKUP_DATABASE $ANT_CLEAN $ANT_UPDATE_DATABASE $ANT_COMPILE_COMPLETE $ANT_SMARTBUILD && date
