#!/bin/bash
# This script can be used to generate Debian packages and add them to a local debian repository.

# Input Parameters
if [ "$#" -lt 3 ]; then
    echo "This script prints a manifest from package repos.  It uses a package model file that describes each package."
    echo "If no package name is specified from the model, all packages are built."
    echo "Usage: build-manifest.sh <package model> <manifest file> <temp build dir> [package]"
    exit 1
fi

# Load common functions
if [ -f pkgrepo-lib/build-common.sh ]; then
    source pkgrepo-lib/build-common.sh
elif [ -f build-common.sh ]; then
    source build-common.sh
else
    echo "Unable to find build-common.sh, aborting."
    exit 1
fi

# shellcheck disable=SC2034
PACKAGE_MODEL_FILE=$(realpath "$1")
MANIFEST_FILE=$(realpath "$2")
BUILD_DIR=$3
# shellcheck disable=SC2034
PACKAGE_FILTER=$4

# Print manifest
append_manifest() {    
    cd $BUILD_DIR/${packageModel[name]}
    REPO_NAME=${packageModel[name]}
    BRANCH_NAME=$(git rev-parse --abbrev-ref HEAD)
    COMMIT_HASH=$(git rev-parse --short HEAD)

    echo "$REPO_NAME $BRANCH_NAME $COMMIT_HASH" >> "$MANIFEST_FILE"
}

# Verify execution environment
env_check() {
    hash git 2>/dev/null || { echo >&2 "Required command git is not found on this system. Please install it. Aborting."; exit 1; }
}

handle_package() {
    checkout
    append_manifest
}

# Main
set -e

env_check
if [ ! -d $BUILD_DIR ]; then
    mkdir -p $BUILD_DIR
fi

print_banner "Generating package manifest $MANIFEST_FILE"

typeset -A packageModel

read_package_model