#!/bin/bash

read -p "Are you sure you want to DELETE Kubernetes secrets in your current environment? (Yy) " -n 1 -r
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
  [[ "$0" = "$BASH_SOURCE" ]] && exit 1 || return 1
fi
echo

kubectl delete secret aws
kubectl delete secret relayer
kubectl delete secret db
