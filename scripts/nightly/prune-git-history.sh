#!/bin/bash
set -e

git config --local user.email "action@github.com"
git config --local user.name "Apache Causeway Committers (Bot)"

# https://stackoverflow.com/a/61867023/9269480
NEW_ROOT=`git rev-parse --short HEAD`
NEXT=`echo 'Auto-pruned git history' | git commit-tree ${NEW_ROOT}^{tree}`

git rebase --onto $NEXT $NEW_ROOT

# not here
#git push -f
