#!/bin/bash

echo "Your current kubectl context is: $(kubectl config current-context)"

read -p "Are you sure you want to upgrade? (Yy) " -n 1 -r
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
  [[ "$0" = "$BASH_SOURCE" ]] && exit 1 || return 1
fi
echo

helm upgrade --install -f ./helm/circles-graphprotocol/values.yaml graph-protocol  ./helm/circles-graphprotocol
