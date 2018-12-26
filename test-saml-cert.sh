#!/bin/bash
#Author: Carl Dunkelberger(cdunkelb)
#Date: 12/26/2018
#Usage: Enable client bundle and then run this file. `./test-saml-cert.sh TESTURL`
#Example ./test-saml.cert.sh https://login.microsoftonline.com/ 

usage(){
  echo "Activate client bundle before running this script"
  echo "Usage: $0 TESTURL"
  echo "Example: $0 https://login.microsoftonline.com"
  exit
}

if [[ -z $1 ]]; then
  echo "No Test URL Provided"
  usage
fi

if [[ -z $DOCKER_HOST ]]; then
  echo "No DOCKER_HOST environment variable set. Did you enable your UCP client bundle?"
  usage
fi

URL=$1
CID=$(docker ps -aq -f name=auth-api --filter status=running | head -n1)
CONNAME=$(docker inspect $CID --format {{.Name}})

echo "auth-api container identified: $CID $CONNAME"

echo "Continue? [y,n]"
read CON
if [[ $CON != y ]]; then
  echo "exiting..."
  exit
fi

URL=$1
echo "---Testing www.google.com/ This should succeed---"
docker exec -t $CID curl -v https://www.google.com
echo "---Testing https://untrusted-root.badssl.com/ This should fail---"
docker exec -t $CID curl -v https://untrusted-root.badssl.com/
echo "---Testing SAML URL---"
docker exec -t $CID curl -v $URL
