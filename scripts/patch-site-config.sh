#!/bin/bash
set -e

SITE_CONFIG=$1

# disable sitemap xml file generation by commenting out the url declaration, 
# that points to 'https://isis.apache.org'
sed -i '/^  url.*$/s/^/#/' $SITE_CONFIG
