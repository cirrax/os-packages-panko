#!/bin/sh

DISTRI='stretch'
MAJREL=`head -1 debian/.release`
NUM=`tail -1 debian/.release`

if  [ `git rev-parse --abbrev-ref HEAD` != "debian/${DISTRI}-${MAJREL}" ]; then
       echo 'not on correct branch'
       exit 1
fi

# get upstream branch, update and update origin
git remote add upstream https://git.openstack.org/openstack/panko.git
git checkout origin/stable/${MAJREL} -b stable/${MAJREL}
git pull upstream stable/${MAJREL}
git push

git checkout debian/${DISTRI}-${MAJREL}

# now start merging
uscan -v --no-download

#get newest tag:
VER=`git tag|egrep "^$NUM\.[0-9]+\.[0-9]+$"|sort|tail -1`

git merge $VER --no-edit

