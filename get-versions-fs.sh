#!/bin/bash

# Prints label info for containers
# It's meant to be included in 'kustomization.yaml' in 'imageTags'

CURDIR=$(pwd)
GIT_CMD1='git describe --tags --always --dirty'
GIT_CMD2='git rev-parse --abbrev-ref HEAD'
DIRS=("node-container sshd-container")

BASEPATH="- name: eu.gcr.io/${PROJECT_ID}/"
BASETAG="newTag: "

# old
for D in ${DIRS[@]}
do
    if [ -d "$D" ]; then
        cd $D
        HASH=$(${GIT_CMD1})-$(${GIT_CMD2})
        PACKAGE=$(echo ${D} | perl -ne 'print $1 if /([^\/]+)$/')
        echo '  ' ${BASEPATH}${PACKAGE}
        echo '    ' ${BASETAG}"'"${HASH}"'"
        cd ${CURDIR}
    fi
done;


