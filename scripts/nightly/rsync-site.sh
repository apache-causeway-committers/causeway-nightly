#!/bin/bash
set -e

# rsync verbose, recursive and skip based on checksum
# note: rsync's delete option does not work with wildcards eg antora/target/site/*
rsync -avc --delete --exclude ".git" $FRAMEWORK_ROOT_PATH/antora/target/site/ $NIGHTLY_ROOT_PATH/docs
