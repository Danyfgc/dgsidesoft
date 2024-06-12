#!/bin/bash

set -e

CONTAINER=$1

clear && docker logs -n 500 -f $CONTAINER
