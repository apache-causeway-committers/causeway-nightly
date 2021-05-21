#!/bin/bash
set -e

DIRNAME=$(dirname $0)
APPLICATION=$1
VARIANT=$2
VARIANT_LOWER=$(echo ${VARIANT} |  tr '[:upper:]' '[:lower:]' )
VARIANT_USAGE=$3

APPNAME="app-${APPLICATION}-${VARIANT_LOWER}"
if [[ "$VARIANT_USAGE" = 'VARIANT_IN_IMAGE_NAME' ]]; then
  IMAGE="apacheisis/${APPLICATION}-${VARIANT}:latest"
else
  IMAGE="apacheisis/${APPLICATION}:${VARIANT}"
fi
HOST="${APPLICATION}.${VARIANT_LOWER}.isis.incode.work"
SECRET="app-${APPLICATION}-tls-${VARIANT_LOWER}"

echo "APPNAME : $APPNAME"
echo "IMAGE   : $IMAGE"
echo "HOST    : $HOST"
echo "SECRET  : $SECRET"

cd $DIRNAME/$APPLICATION

echo "---"
cp deployment.yaml deployment.yaml.BAK

# all subdocuments
yq eval -M -i ".metadata.name = \"$APPNAME\"" deployment.yaml

# deployment
yq eval -M -i "select(di == 0).spec.selector.matchLabels.app = \"$APPNAME\"" deployment.yaml
yq eval -M -i "select(di == 0).spec.template.metadata.labels.app = \"$APPNAME\"" deployment.yaml
yq eval -M -i "select(di == 0).spec.template.spec.containers[0].image = \"$IMAGE\"" deployment.yaml
yq eval -M -i "select(di == 0).spec.template.spec.containers[0].name = \"$APPNAME\"" deployment.yaml

# service
yq eval -M -i "select(di == 1).spec.selector.app = \"$APPNAME\"" deployment.yaml

# ingress
yq eval -M -i "select(di==2).spec.tls[0].hosts[0] = \"$HOST\"" deployment.yaml
yq eval -M -i "select(di==2).spec.tls[0].secretName = \"$SECRET\"" deployment.yaml
yq eval -M -i "select(di==2).spec.rules[0].http.paths[0].backend.serviceName = \"$APPNAME\"" deployment.yaml
yq eval -M -i "select(di==2).spec.rules[0].host = \"$HOST\"" deployment.yaml

echo "---"
cat deployment.yaml

