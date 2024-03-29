#!/bin/bash


if [ "$#" -ne 1 ]; then
  echo "Usage ./helm-upgrade.sh <prd|stg>"
  exit 0
fi

ENV=$1

read -p "Are you sure you want to upgrade? (Yy) " -n 1 -r
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
  [[ "$0" = "$BASH_SOURCE" ]] && exit 1 || return 1
fi
echo

helm upgrade --install -f ./helm/circles-graphprotocol/values-$ENV.yaml  -n graph graph-protocol  ./helm/circles-graphprotocol
