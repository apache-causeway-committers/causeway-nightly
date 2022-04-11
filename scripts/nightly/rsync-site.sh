#!/bin/bash
set -e

# copy merged mvn-snapshots folder from DEST to SOURCE, so rsync (below) can safely ignore it
cp $NIGHTLY_ROOT_PATH/docs/mvn-snapshots $PROJECT_ROOT_PATH/antora/target/site/  

# rsync verbose, recursive and skip based on checksum
# note: rsync's delete option does not work with wildcards eg antora/target/site/*
rsync -avc --delete --exclude ".git" $PROJECT_ROOT_PATH/antora/target/site/ $NIGHTLY_ROOT_PATH/docs
