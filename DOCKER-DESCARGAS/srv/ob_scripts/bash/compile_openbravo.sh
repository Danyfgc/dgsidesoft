#!/bin/bash

set -e

ENVIRONMENT=$1
echo "ENVIRONMENT=$1"
BACKUP_DEPLOYMENT=$2
echo "BACKUP_DEPLOYMENT=$2"
BACKUP_SOURCE=$3
echo "BACKUP_SOURCE=$3"
BACKUP_DATABASE=$4
echo "BACKUP_DATABASE=$4"
ANT_CLEAN=$5
echo "ANT_CLEAN=$5"
ANT_UPDATE_DATABASE=$6
echo "ANT_UPDATE_DATABASE=$6"
ANT_COMPILE_COMPLETE=$7
echo "ANT_COMPILE_COMPLETE=$7"
ANT_SMARTBUILD=$8
echo "ANT_SMARTBUILD=$8"

PATH_ENV="/opt/openbravo/$ENVIRONMENT"
echo "PATH_ENV=$PATH_ENV"
PATH_SRV="/srv/environments/$ENVIRONMENT"
echo "PATH_SRV=$PATH_SRV"
MAX_OLD_BACKUPS=5
echo "MAX_OLD_BACKUPS=5"
OP_CONTAINER="openbravo"
echo "OP_CONTAINER=$OP_CONTAINER"
PG_CONTAINER="postgres10"
echo "PG_CONTAINER=$PG_CONTAINER"
# DEPLOYMENT=$(docker exec $OP_CONTAINER bash -c 'echo $CATALINA_HOME/webapps/'$ENVIRONMENT)
DEPLOYMENT=$(docker exec $OP_CONTAINER bash -c 'echo $CATALINA_HOME/webapps/*')
echo "DEPLOYMENT=$DEPLOYMENT"

function delete {
    for i in `ls $1`; do
        found=0
        for j in `ls -1t $1 | head -$MAX_OLD_BACKUPS`; do
            if [ "$i" == "$j" ]; then
                found=1
            fi
        done
        if [ $found == 0 ]; then
            echo "delete $i"
            rm -rf $1/$i
        fi
    done
}

echo "----------------------------------------------------------------------------------------------------"
echo "- BEGIN STRUCTURE"
sudo chmod -R 777 /srv
mkdir -p $PATH_SRV/backups/deployment
mkdir -p $PATH_SRV/backups/source
mkdir -p $PATH_SRV/backups/database
mkdir -p $PATH_SRV/backups/installations
mkdir -p $PATH_SRV/translations
mkdir -p $PATH_SRV/install/partial_modules
mkdir -p $PATH_SRV/install/complete_modules
mkdir -p $PATH_SRV/install/config
mkdir -p $PATH_SRV/install/src
mkdir -p $PATH_SRV/install/src-db
echo "- OK"
echo "- END STRUCTURE"
echo "----------------------------------------------------------------------------------------------------"

echo "----------------------------------------------------------------------------------------------------"
echo "- BEGIN PEMISSION SOURCE"
sudo chmod -R 777 $PATH_ENV
echo "- OK"
echo "- END PEMISSION SOURCE"
echo "----------------------------------------------------------------------------------------------------"

if [ $(docker exec $OP_CONTAINER bash -c "test -d $DEPLOYMENT && echo true || echo false") == true ]; then
    if [ $BACKUP_DEPLOYMENT == true ]; then
        echo "----------------------------------------------------------------------------------------------------"
        echo "- BEGIN BACKUP DEPLOYMENT"
        DATE=$(date +%Y%m%d_%H%M)
        echo "tar -czvf $PATH_SRV/backups/deployment/${ENVIRONMENT}_$DATE.tar.gz $DEPLOYMENT"
        docker exec $OP_CONTAINER bash -c "tar -czvf $PATH_SRV/backups/deployment/${ENVIRONMENT}_$DATE.tar.gz $DEPLOYMENT"
        echo "- OK"
        delete $PATH_SRV/backups/deployment
        echo "- END BACKUP DEPLOYMENT"
        echo "----------------------------------------------------------------------------------------------------"
    fi
fi

if [ $ANT_SMARTBUILD == true ]; then
    echo "----------------------------------------------------------------------------------------------------"
    echo "- BEGIN DEPLOYMENT REMOVAL"
    docker exec $OP_CONTAINER bash -c "rm -rf $DEPLOYMENT"
    echo "- OK"
    echo "- END DEPLOYMENT REMOVAL"
    echo "----------------------------------------------------------------------------------------------------"
    echo "- BEGIN RESTART $OP_CONTAINER CONTAINER"
    # docker container restart $OP_CONTAINER
    echo "- OK"
    echo "- END RESTART $OP_CONTAINER CONTAINER"
    echo "----------------------------------------------------------------------------------------------------"
fi

if [ $BACKUP_SOURCE == true ]; then
    echo "----------------------------------------------------------------------------------------------------"
    echo "- BEGIN BACKUP SOURCE"
    if [ -d $PATH_ENV ]; then
        DATE=$(date +%Y%m%d_%H%M)
        tar -czvf $PATH_SRV/backups/source/${ENVIRONMENT}_$DATE.tar.gz \
            --exclude="$PATH_ENV/attachments" \
            --exclude="$PATH_ENV/build" \
            --exclude="$PATH_ENV/build.apply" \
            --exclude="$PATH_ENV/src-gen" \
            --exclude="$PATH_ENV/WebContent" \
            $PATH_ENV
        echo "- OK"
    else
        echo "- $PATH_ENV not found"
    fi
    delete $PATH_SRV/backups/source
    echo "- END BACKUP SOURCE"
    echo "----------------------------------------------------------------------------------------------------"
fi

if [ $BACKUP_DATABASE == true ]; then
    echo "----------------------------------------------------------------------------------------------------"
    echo "- BEGIN BACKUP DATABASE"
    DATE=$(date +%Y%m%d_%H%M)
    docker exec $PG_CONTAINER pg_dump -p 5432 -U postgres -F c -v -f $PATH_SRV/backups/database/${ENVIRONMENT}_$DATE.dmp $ENVIRONMENT
    delete $PATH_SRV/backups/database
    echo "- OK"
    echo "- END BACKUP DATABASE"
    echo "----------------------------------------------------------------------------------------------------"
fi

if [ "$(ls -A $PATH_SRV/install/config)" ]; then
    echo "----------------------------------------------------------------------------------------------------"
    echo "- BEGIN INSTALL CONFIG"
    cp -R $PATH_SRV/install/config/* $PATH_ENV/config/
    echo "- OK"
    echo "- END INSTALL CONFIG"
    echo "----------------------------------------------------------------------------------------------------"
fi

if [ "$(ls -A $PATH_SRV/install/src)" ]; then
    echo "----------------------------------------------------------------------------------------------------"
    echo "- BEGIN INSTALL SRC"
    cp -R $PATH_SRV/install/src/* $PATH_ENV/src/
    echo "- OK"
    echo "- END INSTALL SRC"
    echo "----------------------------------------------------------------------------------------------------"
fi

if [ "$(ls -A $PATH_SRV/install/src-db)" ]; then
    echo "----------------------------------------------------------------------------------------------------"
    echo "- BEGIN INSTALL SRC-DB"
    cp -R $PATH_SRV/install/src-db/* $PATH_ENV/src-db/
    echo "- OK"
    echo "- END INSTALL SRC-DB"
    echo "----------------------------------------------------------------------------------------------------"
fi

if [ "$(ls -A $PATH_SRV/install/complete_modules)" ]; then
    echo "----------------------------------------------------------------------------------------------------"
    echo "- BEGIN INSTALL COMPLETE MODULES"
    env_modules=()
    for i in `ls $PATH_ENV/modules`; do
        env_modules=(${env_modules[@]} $i)
    done

    complete_modules=()
    for i in `ls $PATH_SRV/install/complete_modules`; do
        complete_modules=(${complete_modules[@]} $i)
    done

    for i in ${env_modules[@]}; do
        for j in ${complete_modules[@]}; do
            if [ "$i" == "$j" ]; then
                echo "$i == $j"
                rm -rf $PATH_ENV/modules/$j
            fi
        done
    done

    cp -R $PATH_SRV/install/complete_modules/* $PATH_ENV/modules/
    echo "- OK"
    echo "- END INSTALL COMPLETE MODULES"
    echo "----------------------------------------------------------------------------------------------------"
fi

if [ "$(ls -A $PATH_SRV/install/partial_modules)" ]; then
    echo "----------------------------------------------------------------------------------------------------"
    echo "- BEGIN INSTALL PARTIAL MODULES"
    cp -R $PATH_SRV/install/partial_modules/* $PATH_ENV/modules/
    echo "- OK"
    echo "- END INSTALL PARTIAL MODULES"
    echo "----------------------------------------------------------------------------------------------------"
fi

if [ $ANT_CLEAN == true ]; then
    echo "----------------------------------------------------------------------------------------------------"
    echo "- BEGIN REMOVE AUTOGENERATED DIRECTORIES"
    docker exec $OP_CONTAINER bash -c "cd $PATH_ENV && rm -Rf build/ build.apply/ src-gen/ WebContent/ src-core/build/ src-trl/build/ src-wad/build srcAD"
    echo "- OK"
    echo "- END REMOVE AUTOGENERATED DIRECTORIES"
    echo "----------------------------------------------------------------------------------------------------"
    echo "- BEGIN ANT CLEAN"
    docker exec $OP_CONTAINER bash -c "cd $PATH_ENV && ant clean database.lib core.lib trl.lib wad.lib"
    echo "- OK"
    echo "- END ANT CLEAN"
    echo "----------------------------------------------------------------------------------------------------"
fi

if [ $ANT_UPDATE_DATABASE == true ]; then
    echo "----------------------------------------------------------------------------------------------------"
    echo "- BEGIN SCRIPTS SQL PRE ANT UPDATE.DATABASE"
    docker exec $PG_CONTAINER psql -U postgres -w -d $ENVIRONMENT -a -f /srv/ob_scripts/sql/pre_update.sql
    echo "- OK"
    echo "- END SCRIPTS SQL PRE ANT UPDATE.DATABASE"
    echo "----------------------------------------------------------------------------------------------------"
    echo "- BEGIN ANT UPDATE.DATABASE"
    docker exec $OP_CONTAINER bash -c "cd $PATH_ENV && ant update.database -Dforce=yes"
    echo "- OK"
    echo "- END ANT UPDATE.DATABASE"
    echo "----------------------------------------------------------------------------------------------------"
    echo "- BEGIN SCRIPTS SQL POST ANT UPDATE.DATABASE"
    docker exec $PG_CONTAINER psql -U postgres -w -d $ENVIRONMENT -a -f /srv/ob_scripts/sql/post_update.sql
    echo "- OK"
    echo "- END SCRIPTS SQL POST ANT UPDATE.DATABASE"
    echo "----------------------------------------------------------------------------------------------------"
fi

if [ $ANT_COMPILE_COMPLETE == true ]; then
    echo "----------------------------------------------------------------------------------------------------"
    echo "- BEGIN ANT COMPILE.COMPLETE"
    docker exec $OP_CONTAINER bash -c "cd $PATH_ENV && ant compile.complete"
    echo "- OK"
    echo "- END ANT COMPILE.COMPLETE"
    echo "----------------------------------------------------------------------------------------------------"
fi

if [ "$(ls -A $PATH_SRV/translations)" ]; then
    echo "----------------------------------------------------------------------------------------------------"
    echo "- BEGIN SCRIPTS SQL TRANSLATIONS"
    for i in `ls $PATH_SRV/translations`; do
		echo $i
        docker exec $PG_CONTAINER psql -U postgres -w -d $1 -a -f $PATH_SRV/translations/$i
	done
    echo "- OK"
    echo "- ENDSCRIPTS SQL TRANSLATIONS"
    echo "----------------------------------------------------------------------------------------------------"
fi

if [ $ANT_SMARTBUILD == true ]; then
    echo "----------------------------------------------------------------------------------------------------"
    echo "- BEGIN ANT SMARTBUILD"
    docker exec $OP_CONTAINER bash -c "cd $PATH_ENV && ant smartbuild -Dlocal=yes"
    echo "- OK"
    echo "- END ANT SMARTBUILD"
    echo "----------------------------------------------------------------------------------------------------"
    echo "- BEGIN RESTART $OP_CONTAINER CONTAINER"
    docker container restart $OP_CONTAINER
    echo "- OK"
    echo "- END RESTART $OP_CONTAINER CONTAINER"
    echo "----------------------------------------------------------------------------------------------------"
fi


if [ "$(ls -A $PATH_SRV/install/config)" ]; then
    echo "----------------------------------------------------------------------------------------------------"
    echo "- BEGIN BACKUP CONFIG"
    DATE=$(date +%Y%m%d_%H%M)
    tar -czvf $PATH_SRV/backups/installations/${ENVIRONMENT}_config_$DATE.tar.gz $PATH_SRV/install/config/*
    echo "- OK"
    echo "- END BACKUP CONFIG"
    echo "----------------------------------------------------------------------------------------------------"
    echo "- BEGIN DELETE CONFIG"
    rm -rf $PATH_SRV/install/config/*
    echo "- OK"
    echo "- END DELETE CONFIG"
    echo "----------------------------------------------------------------------------------------------------"
fi

if [ "$(ls -A $PATH_SRV/install/src)" ]; then
    echo "----------------------------------------------------------------------------------------------------"
    echo "- BEGIN BACKUP SRC"
    DATE=$(date +%Y%m%d_%H%M)
    tar -czvf $PATH_SRV/backups/installations/${ENVIRONMENT}_src_$DATE.tar.gz $PATH_SRV/install/src/*
    echo "- OK"
    echo "- END BACKUP SRC"
    echo "----------------------------------------------------------------------------------------------------"
    echo "- BEGIN DELETE SRC"
    rm -rf $PATH_SRV/install/src/*
    echo "- OK"
    echo "- END DELETE SRC"
    echo "----------------------------------------------------------------------------------------------------"
fi

if [ "$(ls -A $PATH_SRV/install/src-db)" ]; then
    echo "----------------------------------------------------------------------------------------------------"
    echo "- BEGIN BACKUP SRC-DB"
    DATE=$(date +%Y%m%d_%H%M)
    tar -czvf $PATH_SRV/backups/installations/${ENVIRONMENT}_src-db_$DATE.tar.gz $PATH_SRV/install/src-db/*
    echo "- OK"
    echo "- END BACKUP SRC-DB"
    echo "----------------------------------------------------------------------------------------------------"
    echo "- BEGIN DELETE SRC-DB"
    rm -rf $PATH_SRV/install/src-db/*
    echo "- OK"
    echo "- END DELETE SRC-DB"
    echo "----------------------------------------------------------------------------------------------------"
fi

if [ "$(ls -A $PATH_SRV/install/complete_modules)" ]; then
    echo "----------------------------------------------------------------------------------------------------"
    echo "- BEGIN BACKUP COMPLETE MODULES"
    DATE=$(date +%Y%m%d_%H%M)
    tar -czvf $PATH_SRV/backups/installations/${ENVIRONMENT}_complete_modules_$DATE.tar.gz $PATH_SRV/install/complete_modules/*
    echo "- OK"
    echo "- END BACKUP COMPLETE MODULES"
    echo "----------------------------------------------------------------------------------------------------"
    echo "- BEGIN DELETE COMPLETE MODULES"
    rm -rf $PATH_SRV/install/complete_modules/*
    echo "- OK"
    echo "- END DELETE COMPLETE MODULES"
    echo "----------------------------------------------------------------------------------------------------"
fi

if [ "$(ls -A $PATH_SRV/install/partial_modules)" ]; then
    echo "----------------------------------------------------------------------------------------------------"
    echo "- BEGIN BACKUP PARTIAL MODULES"
    DATE=$(date +%Y%m%d_%H%M)
    tar -czvf $PATH_SRV/backups/installations/${ENVIRONMENT}_partial_modules_$DATE.tar.gz $PATH_SRV/install/partial_modules/*
    echo "- OK"
    echo "- END BACKUP PARTIAL MODULES"
    echo "----------------------------------------------------------------------------------------------------"
    echo "- BEGIN DELETE PARTIAL MODULES"
    rm -rf $PATH_SRV/install/partial_modules/*
    echo "- OK"
    echo "- END DELETE PARTIAL MODULES"
    echo "----------------------------------------------------------------------------------------------------"
fi
