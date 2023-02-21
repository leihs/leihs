#!/bin/sh -exu

export DEV_INITIALS=uvb
export RELEASE_MAJOR_MINOR=6.9
export RELEASE_PATCH=0
export RELEASE_PRE='' # e.g. '-RC.1'; or '' for stable release
export VERSION_PREFIX='' # for madek its 'v' 

export RELEASE_MAIN="${RELEASE_MAJOR_MINOR}.${RELEASE_PATCH}"
export RELEASE="${RELEASE_MAIN}${RELEASE_PRE}"
export RELEASE_NAME="${VERSION_PREFIX}${RELEASE}"

echo $RELEASE_MAIN
echo $RELEASE
echo $RELEASE_NAME
