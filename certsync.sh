#!/usr/bin/env bash
sync_path=$(dirname "$(readlink -f "$0")")
source $sync_path/certsync.config
for domain in "${domains[@]}"
do
  response=$(curl -d "{\"secretapikey\":\"$secret_key\",\"apikey\":\"$api_key\"}" -H "Content-Type: application/json" https://api.porkbun.com/api/json/v3/ssl/retrieve/$domain)
  response_status=$(echo $response | jq -r .status)
  if [[ "$response_status" == "SUCCESS" ]]; then
    mkdir -p $sync_path/certificates/$domain
    jq -r .certificatechain <<< "$response" > $sync_path/certificates/$domain/fullchain.pem
    jq -r .privatekey <<< "$response" > $sync_path/certificates/$domain/privatekey.pem
    jq -r .publickey <<< "$response" > $sync_path/certificates/$domain/publickey.pem
  fi
done
