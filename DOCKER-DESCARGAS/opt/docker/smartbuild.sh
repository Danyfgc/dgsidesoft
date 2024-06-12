#!/bin/bash

set -e

ENVIRONMENT=$1
BACKUP_DEPLOYMENT=false
BACKUP_SOURCE=false
BACKUP_DATABASE=false
ANT_CLEAN=false
ANT_UPDATE_DATABASE=false
ANT_COMPILE_COMPLETE=false
ANT_SMARTBUILD=true

/srv/ob_scripts/bash/compile_openbravo.sh $ENVIRONMENT $BACKUP_DEPLOYMENT $BACKUP_SOURCE $BACKUP_DATABASE $ANT_CLEAN $ANT_UPDATE_DATABASE $ANT_COMPILE_COMPLETE $ANT_SMARTBUILD && date
