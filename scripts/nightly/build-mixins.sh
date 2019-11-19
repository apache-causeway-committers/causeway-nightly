#!/bin/bash
set -e

echo "Shared Vars File: ${SHARED_VARS_FILE}"

# import shared vars (non secret!)
source $SHARED_VARS_FILE && export $(cut -d= -f1 $SHARED_VARS_FILE)

sh $CI_SCRIPTS_PATH/print-environment.sh "nightly-build-mixins"

cd $PROJECT_ROOT_PATH/mixins

# temporarily set version
mvn versions:set -DnewVersion=$REVISION

# setting 'github-deploy.repositoryUrl' activates the 'github-deploy' maven profile as defined in the pom.xml
# the 'github-deploy' profile is mapped to the server setting as declared in '.m2/nightly-settings.xml'  
mvn -s $NIGHTLY_ROOT_PATH/.m2/nightly-settings.xml \
    --batch-mode \
    $MVN_STAGES \
    -Dskip.mavenmixin-standard \
    -Dskip.mavenmixin-surefire \
    -Dskip.mavenmixin-datanucleus-enhance \
    $MVN_ADDITIONAL_OPTS

# revert the edits from earlier ...
mvn versions:revert

cd $PROJECT_ROOT_PATH


