#!/bin/sh -exu

export DEV_INITIALS=mk
export RELEASE_MAJOR_MINOR=6.6
export RELEASE_PATCH=0
export RELEASE_PRE='-RC.2' # or '' for stable release
export VERSION_PREFIX='' # for madek its 'v' 

export RELEASE_MAIN="${RELEASE_MAJOR_MINOR}.${RELEASE_PATCH}"
export RELEASE="${RELEASE_MAIN}${RELEASE_PRE}"
export RELEASE_NAME="${VERSION_PREFIX}${RELEASE}"

echo $RELEASE_MAIN
echo $RELEASE
echo $RELEASE_NAME