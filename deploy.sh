#!/bin/bash

echo Deploy new versions. Argument: $1
date

TEST_CLUSTER="gke_foobar-123456_europe-north1-b_xyzzy-test-cluster"
PROD_CLUSTER="gke_foobar-123456_europe-north1-b_xyzzy-prod-cluster"

if [[ $1 = "prod" || $1 = "all" ]]
then
    echo "Deploy to PROD"
    # 1. Make the PROD cluster active
    # kubectl config set current-context $PROD_CLUSTER
    # 2. Create/update PROD
    cd ./yaml && kustomize build prod | kubectl apply -f - && cd ..
fi

if [[ $1 = "test" || $1 == "all" || -z "$1" ]]
then
    echo "Deploy to TEST"
    # 1. Make TEST cluster active
    # kubectl config set current-context $TEST_CLUSTER
    # 2. Create/update TESt
    cd ./yaml && kustomize build test | kubectl apply -f - && cd ..
fi

# Make the TEST cluster active as default
kubectl config set current-context $TEST_CLUSTER

