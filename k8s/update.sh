#!/bin/bash
set -e

DIRNAME=$(dirname $0)
APPLICATION=$1
BRANCH=$2
BRANCH_LOWER=$(echo ${BRANCH} |  tr '[:upper:]' '[:lower:]' )

APPNAME="isis-app-${APPLICATION}-${BRANCH_LOWER}"
IMAGE="apacheisis/${APPLICATION}:${BRANCH}"
HOST="${APPLICATION}.${BRANCH_LOWER}.isis.incode.work"
SECRET="isis-app-${APPLICATION}-tls-${BRANCH_LOWER}"

echo "APPNAME : $APPNAME"
echo "IMAGE   : $IMAGE"
echo "HOST    : $HOST"
echo "SECRET  : $SECRET"

cd $DIRNAME/$APPLICATION

echo "---"
yq eval -i ".metadata.name = \"$APPNAME\"" 010-deployment.yaml -i
yq eval ".spec.selector.matchLabels.app = \"$APPNAME\"" 010-deployment.yaml -M -i
yq eval ".spec.template.metadata.labels.app = \"$APPNAME\"" 010-deployment.yaml -M -i
yq eval ".spec.template.spec.containers[0].image = \"$IMAGE\"" 010-deployment.yaml -M -i
yq eval ".spec.template.spec.containers[0].name = \"$APPNAME\"" 010-deployment.yaml -M -i
cat 010-deployment.yaml

echo "---"
yq eval ".metadata.name = \"$APPNAME\"" 020-service.yaml -M -i
yq eval ".spec.selector.app = \"$APPNAME\"" 020-service.yaml -M -i
cat 020-service.yaml

echo "---"
yq eval ".metadata.name = \"$APPNAME\"" 030-ingress.yaml -M -i
yq eval ".spec.tls[0].hosts[0] = \"$HOST\"" 030-ingress.yaml -M -i
yq eval ".spec.tls[0].secretName = \"$SECRET\"" 030-ingress.yaml -M -i
yq eval ".spec.rules[0].http.paths[0].backend.serviceName = \"$APPNAME\"" 030-ingress.yaml -M -i
yq eval ".spec.rules[0].host = \"$HOST\"" 030-ingress.yaml -M -i
cat 030-ingress.yaml
