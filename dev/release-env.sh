#!/bin/sh -exu

export DEV_INITIALS=mk
export RELEASE_MAJOR_MINOR=7.9
export RELEASE_PATCH=0
export RELEASE_PRE='-RC.2' # e.g. '-RC.1'; or '' for stable release

export RELEASE_MAIN="$RELEASE_MAJOR_MINOR.$RELEASE_PATCH"
export RELEASE="$RELEASE_MAIN$RELEASE_PRE"
export RELEASE_NAME="$RELEASE"
export LEIHS_REPO=$(pwd)

echo "RELEASE_MAIN: $RELEASE_MAIN"
echo "RELEASE: $RELEASE"
echo "RELEASE_NAME: $RELEASE_NAME"
echo "LEIHS_REPO: $LEIHS_REPO" # should be the path to your cloned leihs repository

echo "PERSONAL-BRANCH: $DEV_INITIALS/v/$RELEASE_MAJOR_MINOR-staging"
