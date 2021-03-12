#!/bin/bash
set -e

DIRNAME=$(dirname $0)
APPLICATION=$1
BRANCH=$2

APP="isis-app-${APPLICATION}-${BRANCH}"
IMAGE="apacheisis/${APPLICATION}:${BRANCH}"
HOST="${APPLICATION}.${BRANCH}.isis.incode.work"
SECRET="isis-app-${APPLICATION}-tls-${BRANCH}"

echo "APP    : $APP"
echo "IMAGE  : $IMAGE"
echo "HOST   : $HOST"
echo "SECRET : $SECRET"

pushd $DIRNAME/$APPLICATION

echo "---"
yq eval ".metadata.name = \"$APP\"" 010-deployment.yaml -M -i
yq eval ".spec.selector.matchLabels.app = \"$APP\"" 010-deployment.yaml -M -i
yq eval ".spec.template.metadata.labels.app = \"$APP\"" 010-deployment.yaml -M -i
yq eval ".spec.template.spec.containers[0].image = \"$IMAGE\"" 010-deployment.yaml -M -i
yq eval ".spec.template.spec.containers[0].name = \"$APP\"" 010-deployment.yaml -M -i
cat k8s/simpleapp/010-deployment.yaml

echo "---"
yq eval ".metadata.name = \"$APP\"" 020-service.yaml -M -i
yq eval ".spec.selector.app = \"$APP\"" 020-service.yaml -M -i
cat k8s/simpleapp/020-service.yaml

echo "---"
yq eval ".metadata.name = \"$APP\"" 030-ingress.yaml -M -i
yq eval ".spec.tls[0].hosts[0] = \"$HOST\"" 030-ingress.yaml -M -i
yq eval ".spec.tls[0].secretName = \"$SECRET\"" 030-ingress.yaml -M -i
yq eval ".spec.rules[0].http.paths[0].backend.serviceName = \"$APP\"" 030-ingress.yaml -M -i
yq eval ".spec.rules[0].host = \"$HOST\"" 030-ingress.yaml -M -i
cat k8s/simpleapp/030-ingress.yaml
