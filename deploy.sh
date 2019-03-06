#!/bin/bash

echo Deploy new versions. Argument: $1
date

DEV_CLUSTER="gke_foobar-123456_europe-north1-b_xyzzy-dev-cluster"
PROD_CLUSTER="gke_foobar-123456_europe-north1-b_xyzzy-prod-cluster"

if [[ $1 = "prod" || $1 = "all" ]]
then
    echo "Deploy to PROD"
    # 1. Make the PROD cluster active
    # kubectl config set current-context $PROD_CLUSTER
    # 2. Create/update PROD
    cd ./yaml && kustomize build prod | kubectl apply -f - && cd ..
fi

if [[ $1 = "dev" || $1 == "all" || -z "$1" ]]
then
    echo "Deploy to DEV"
    # 1. Make DEV cluster active
    # kubectl config set current-context $DEV_CLUSTER
    # 2. Create/update DEV
    cd ./yaml && kustomize build dev | kubectl apply -f - && cd ..
fi

# Make the DEV cluster active as default
kubectl config set current-context $DEV_CLUSTER

