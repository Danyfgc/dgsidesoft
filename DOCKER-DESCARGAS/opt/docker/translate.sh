#!/bin/bash

set -e

ENVIRONMENT=$1
MODULE=$2

PATH_ENV="/opt/openbravo/$ENVIRONMENT"


if [ "$MODULE" == "" ]; then
    echo "Module name is required"
    exit 1
else
    if [ -d "$PATH_ENV/attachments/lang/es_ES/${MODULE}.es_ES" ]; then
        echo "----------------------------------------------------------------------------------------------------"
        echo "- BEGIN STRUCTURE"
        mkdir -p $PATH_ENV/modules/${MODULE}.es_ES/referencedata/translation
        echo "- OK"
        echo "- END STRUCTURE"
        echo "----------------------------------------------------------------------------------------------------"
        echo "----------------------------------------------------------------------------------------------------"
        echo "- BEGIN EXPORT TRANSLATION"
        cp -R $PATH_ENV/attachments/lang/es_ES/$MODULE/* $PATH_ENV/modules/${MODULE}.es_ES/referencedata/translation/
        echo "- OK"
        echo "- END EXPORT TRANSLATION"
        echo "----------------------------------------------------------------------------------------------------"
    else
        echo "Translation $PATH_ENV/attachments/lang/es_ES/${MODULE}.es_ES not found"
        exit 1
    fi
fi