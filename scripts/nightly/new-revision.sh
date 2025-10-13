#!/bin/bash
set -e

OUTPUT_ID=$1
REF_HEAD=$2
BASELINE=$3
TOKEN=$4

echo "--------- revision calculator ----------"
echo "OUTPUT_ID: ${OUTPUT_ID}"
echo "REF_HEAD:  ${REF_HEAD}"
echo "BASELINE:  ${BASELINE}"
echo "----------------------------------------"

## causeway head commit hash, using REST API.  
## We used to use credentials to avoid rate limiting, but that seems to be broken now
## --header 'authorization: Bearer ${TOKEN}' \
HEAD_SHA=`curl -s --request GET \
        --header 'content-type: application/json' \
	--url https://api.github.com/repos/${REF_HEAD} \
        | grep sha | cut -d\: -f2 | cut -d\" -f2`

## latest published revision: eg. 2.0.0-M2.20191113-0401-ce4b5827
## grepping the maven-metadata.xml this way is fragile
PUBLISHED_REV=`curl -s GET \
		https://raw.githubusercontent.com/apache-causeway-committers/causeway-nightly/master/mvn-snapshots/org/apache/causeway/causeway-bom/maven-metadata.xml \
        | grep version | grep ${BASELINE} | tail -1 | cut -d\> -f2 | cut -d\< -f1`

#debug
#PUBLISHED_REV=2.0.0-M2.20191113-0401-ce4b5827

HEAD_SHA8=${HEAD_SHA: 0:8}
PUBLISHED_SHA8=${PUBLISHED_REV: -8}

REVISION=${BASELINE}.$(date +%Y%m%d-%H%M)-${HEAD_SHA8}

echo "PUBLISHED_REV:     ${PUBLISHED_REV}"
echo "-> HEAD_SHA:       ${HEAD_SHA}"
echo "-> PUBLISHED_SHA8: ${PUBLISHED_SHA8}"
echo "-> REVISION:       ${REVISION}"
echo "----------------------------------------"

## either output a valid 'revision' to be used by consecutive workflow jobs
## or set 'revision=skip' in case the hashes are equal
if [ "$HEAD_SHA8" = "$PUBLISHED_SHA8" ]; then
  echo "Skipping update, because (shortened) hashes are equal:"
  echo "- HEAD_SHA8:    ${HEAD_SHA8}"
  echo "- PUBLISHED_SHA8: ${PUBLISHED_SHA8}"
  echo "${OUTPUT_ID}=skip"
else
  echo "${OUTPUT_ID}=${REVISION}"
fi

