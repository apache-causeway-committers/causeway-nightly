#!/bin/bash
set -e

echo "Shared Vars File: ${SHARED_VARS_FILE}"

# import shared vars (non secret!)
source $SHARED_VARS_FILE && export $(cut -d= -f1 $SHARED_VARS_FILE)

sh $CI_SCRIPTS_PATH/print-environment.sh "nightly-build-mixins"

echo "\$GH_DEPLOY_ACTOR:   ${GH_DEPLOY_ACTOR}"
echo "\$GITHUB_REPOSITORY: ${GITHUB_REPOSITORY}"

cd $PROJECT_ROOT_PATH/mixins

# can't use flatten pom, so have to edit directly instead...
mvn versions:set -DnewVersion=$REVISION

# template Nr.1
##run: mvn deploy \
## -Dregistry=https://maven.pkg.github.com/apache-isis-committers \
## -Dtoken=${{ secrets.GITHUB_TOKEN }} 

# template Nr.2
##run: ./mvnw -B -s $NIGHTLY_ROOT_PATH/.m2/nightly-settings.xml \
## -Drepository.url=https://${GITHUB_ACTOR}:${{ secrets.GITHUB_TOKEN }}@github.com/${GITHUB_REPOSITORY}.git

mvn -s $NIGHTLY_ROOT_PATH/.m2/nightly-settings.xml \
    --batch-mode \
    $MVN_STAGES \
    -Dgithub-deploy.repositoryUrl=https://${GH_DEPLOY_ACTOR}:${GH_DEPLOY_TOKEN}@github.com/${GITHUB_REPOSITORY}.git \
    -Dregistry=https://maven.pkg.github.com/apache-isis-committers \ 
    -Dtoken=$GH_DEPLOY_TOKEN \
    -Drevision=$REVISION \
    -Dskip.mavenmixin-standard \
    -Dskip.mavenmixin-surefire \
    -Dskip.mavenmixin-datanucleus-enhance \
    $CORE_ADDITIONAL_OPTS

# revert the edits from earlier ...
mvn versions:revert

cd $PROJECT_ROOT_PATH


