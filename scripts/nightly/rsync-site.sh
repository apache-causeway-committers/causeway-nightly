#!/bin/bash
set -e

# move (already merged) mvn-snapshots folder from DEST to TMP, so rsync (below) can safely ignore it
mv $NIGHTLY_ROOT_PATH/docs/mvn-snapshots /tmp/  

# rsync verbose, recursive and skip based on checksum
# note: rsync's delete option does not work with wildcards eg antora/target/site/*
rsync -avc --delete --exclude ".git" $PROJECT_ROOT_PATH/antora/target/site/ $NIGHTLY_ROOT_PATH/docs

# revert above move
mv /tmp/mvn-snapshots $NIGHTLY_ROOT_PATH/docs/
