#!/bin/bash
set -e

## isis master commit hash, using REST API that in this case requires no credentials
MASTER_SHA=`curl -s --request GET \
        --url https://api.github.com/repos/apache/isis/git/ref/heads/master \
        --header 'content-type: application/json' \
        | grep sha | cut -d\: -f2 | cut -d\" -f2`

## latest published revision: eg. 2.0.0-M2.20191113-0401-ce4b5827 
## grepping the maven-metadata.xml this way is fragile
PUBLISHED_REV=`curl -s GET \
        https://repo.incode.work/org/apache/isis/core/isis/maven-metadata.xml \
        | grep release | cut -d\> -f2 | cut -d\< -f1`
   

MASTER_SHA8=${MASTER_SHA: 0:8}        
PUBLISHED_SHA8=${PUBLISHED_REV: -8}  

REVISION=${BASELINE}.$(date +%Y%m%d-%H%M)-${MASTER_SHA8}

echo "MASTER_SHA:        ${MASTER_SHA}"
echo "PUBLISHED_REV:     ${PUBLISHED_REV}"
echo "-> MASTER_SHA8:    ${MASTER_SHA8}"
echo "-> PUBLISHED_SHA8: ${PUBLISHED_SHA8}"
echo "-> REVISION:       ${REVISION}"
echo ""

## either output a valid 'revision' to be used by consecutive workflow jobs
## or set 'revision=skip' in case the hashes are equal 
if [ "$MASTER_SHA8" = "$PUBLISHED_SHA8" ]; then
  echo "Skipping update, because (shortened) hashes are equal:"
  echo "- MASTER_SHA8:    ${MASTER_SHA8}"
  echo "- PUBLISHED_SHA8: ${PUBLISHED_SHA8}"
  echo "##[set-output name=revision;]skip"
else
  echo "##[set-output name=revision;]${REVISION}"
fi
  
