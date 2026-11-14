#!/bin/bash
set -e

echo "-- site sync script --"
echo "SITE_SOURCE: ${SITE_SOURCE}"
echo "SITE_DEST:   ${SITE_DEST}"
echo "----------------------"

# rsync verbose, recursive and skip based on checksum
# note: rsync's delete option does not work with wildcards eg antora/target/site/*
rsync -avc --delete --exclude ".git" ${SITE_SOURCE} ${SITE_DEST}
