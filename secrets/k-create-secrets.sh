#!/bin/bash

if [ "$#" -ne 1 ]; then
  echo "Usage ./k-create-secrets.sh <production|staging>"
  exit 0
fi

ENV=$1

read -p "Are you sure you want to CREATE '$ENV' secrets in your current Kubernetes cluster? (Yy) " -n 1 -r
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
  [[ "$0" = "$BASH_SOURCE" ]] && exit 1 || return 1
fi
echo

kubectl create secret generic aws \
  --from-file=$ENV/aws/AWS_ACCESS_KEY_ID \
  --from-file=$ENV/aws/AWS_SECRET_ACCESS_KEY

kubectl create secret generic relayer \
  --from-file=$ENV/relayer/DJANGO_SECRET_KEY \
  --from-file=$ENV/relayer/SAFE_FUNDER_PRIVATE_KEY \
  --from-file=$ENV/relayer/SAFE_TX_SENDER_PRIVATE_KEY

kubectl create secret generic db \
  --from-file=$ENV/db/POSTGRES_HOST \
  --from-file=$ENV/db/POSTGRES_PASSWORD \
  --from-file=$ENV/db/POSTGRES_PORT \
  --from-file=$ENV/db/POSTGRES_USER
