#!/bin/bash
set -e

## latest published revision: eg. 2.0.0-M2.20191113-0401-ce4b5827
## grepping the maven-metadata.xml this way is fragile
PUBLISHED_REV=`curl -s GET \
        https://raw.githubusercontent.com/apache-causeway-committers/causeway-nightly/master/mvn-snapshots/org/apache/causeway/causeway-bom/maven-metadata.xml \
        | grep release | cut -d\> -f2 | cut -d\< -f1`

echo "##[set-output name=revision;]${PUBLISHED_REV}"


