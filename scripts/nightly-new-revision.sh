#!/bin/bash
set -e

## isis master commit hash
MASTER_SHA=`curl -s --request GET \
        --url https://api.github.com/repos/apache/isis/git/ref/heads/master \
        --header 'content-type: application/json' \
        | grep sha | cut -d\: -f2 | cut -d\" -f2`

## latest published commit hash: grepping the maven-metadata.xml this way is fragile
PUBLISHED_SHA=`curl -s GET \
        https://repo.incode.work/org/apache/isis/core/isis/maven-metadata.xml \
        | grep release | cut -d\> -f2 | cut -d\< -f1`
   

MASTER_SHA8=${MASTER_SHA: -8}        
PUBLISHED_SHA8=${PUBLISHED_SHA: -8}  

## debug
echo "MASTER_SHA:    ${MASTER_SHA}"
echo "PUBLISHED_SHA: ${PUBLISHED_SHA}"

if [ "$MASTER_SHA8" = "$PUBLISHED_SHA8" ]; then
  echo "skipping update, because (shortened) hashes are equal:"
  echo "- MASTER_SHA8:    ${MASTER_SHA8}"
  echo "- PUBLISHED_SHA8: ${PUBLISHED_SHA8}"
else
  echo "##[set-output name=revision;]${BASELINE}.$(date +%Y%m%d-%H%M)-${MASTER_SHA8}"
fi
    

