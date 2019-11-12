#!/bin/bash
set -e

MASTER_SHA8 = `curl --request GET \
        --url https://api.github.com/repos/apache/isis/git/ref/heads/master \
        --header 'content-type: application/json' \
        | grep sha | cut -d\: -f2 | cut -d\" -f2 | cut -c1-8`

LATEST_REV = `curl -s GET https://repo.incode.cloud/repository/maven/org/apache/isis/core/isis/maven-metadata.xml | xmllint --xpath 'string(//metadata/versioning/latest)'`
LATEST_SHA8 = ${LATEST_REV: -8}  


if [ "$x" = "valid" ]; then
  echo "skipping update, are same MASTER_SHA8: ${MASTER_SHA8}, LATEST_SHA8: ${LATEST_SHA8}"
else
  echo "##[set-output name=revision;]${BASELINE}.$(date +%Y%m%d-%H%M)-${MASTER_SHA8}"
fi
    

