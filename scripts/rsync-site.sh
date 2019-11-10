#!/bin/bash
set -e

touch $PROJECT_ROOT_PATH/antora/target/site/dummy.txt

# rsync verbose, recursive and skip based on checksum
rsync -avc --delete --exclude ".git" $PROJECT_ROOT_PATH/antora/target/site/* $NIGHTLY_ROOT_PATH/docs

ls -al $PROJECT_ROOT_PATH/antora/target/site
