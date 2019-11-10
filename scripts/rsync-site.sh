#!/bin/bash
set -e

# rename the rsync source because rsync's delete option does not work with wildcards eg /antora/target/site/*  
mv $PROJECT_ROOT_PATH/antora/target/site $PROJECT_ROOT_PATH/antora/target/docs

# rsync verbose, recursive and skip based on checksum
rsync -avc --delete --exclude ".git" $PROJECT_ROOT_PATH/antora/target/docs $NIGHTLY_ROOT_PATH/docs
