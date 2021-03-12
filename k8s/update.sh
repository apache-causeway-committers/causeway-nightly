#!/bin/bash
set -e

DIRNAME=$(dirname $0)
APPLICATION=$1
BRANCH=$2
BRANCH_LOWER=$(echo ${BRANCH} |  tr '[:upper:]' '[:lower:]' )

APPNAME="app-${APPLICATION}-${BRANCH_LOWER}"
IMAGE="apacheisis/${APPLICATION}:${BRANCH}"
HOST="${APPLICATION}.${BRANCH_LOWER}.isis.incode.work"
SECRET="app-${APPLICATION}-tls-${BRANCH_LOWER}"

echo "APPNAME : $APPNAME"
echo "IMAGE   : $IMAGE"
echo "HOST    : $HOST"
echo "SECRET  : $SECRET"

cd $DIRNAME/$APPLICATION

echo "---"
yq eval -M -i ".metadata.name = \"$APPNAME\"" 010-deployment.yaml
yq eval -M -i ".spec.selector.matchLabels.app = \"$APPNAME\"" 010-deployment.yaml
yq eval -M -i ".spec.template.metadata.labels.app = \"$APPNAME\"" 010-deployment.yaml
yq eval -M -i ".spec.template.spec.containers[0].image = \"$IMAGE\"" 010-deployment.yaml
yq eval -M -i ".spec.template.spec.containers[0].name = \"$APPNAME\"" 010-deployment.yaml
cat 010-deployment.yaml

echo "---"
yq eval -M -i ".metadata.name = \"$APPNAME\"" 020-service.yaml
yq eval -M -i ".spec.selector.app = \"$APPNAME\"" 020-service.yaml
cat 020-service.yaml

echo "---"
yq eval -M -i ".metadata.name = \"$APPNAME\"" 030-ingress.yaml
yq eval -M -i ".spec.tls[0].hosts[0] = \"$HOST\"" 030-ingress.yaml
yq eval -M -i ".spec.tls[0].secretName = \"$SECRET\"" 030-ingress.yaml
yq eval -M -i ".spec.rules[0].http.paths[0].backend.serviceName = \"$APPNAME\"" 030-ingress.yaml
yq eval -M -i ".spec.rules[0].host = \"$HOST\"" 030-ingress.yaml
cat 030-ingress.yaml
