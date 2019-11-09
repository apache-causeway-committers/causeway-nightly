#!/bin/bash
set -e

SITE_CONFIG=$1

#disable sitemap xml file generation
sed -i '/^  url.*$/s/^/#/' $SITE_CONFIG

# run antora
$(npm bin)/antora --stacktrace $SITE_CONFIG

# add a marker, tells github not to use jekyll on the github pages folder
touch ${PROJECT_ROOT_PATH}/antora/target/site/.nojekyll


