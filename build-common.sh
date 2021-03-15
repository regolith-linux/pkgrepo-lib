#!/bin/bash
# Common functions for build scripts

print_banner() {
    echo "***********************************************************"
    echo "** $1"
    echo "***********************************************************"
}

# Checkout
checkout() {
    repo_url=${packageModel[gitRepoUrl]}
    repo_path=${repo_url##*/}
    repo_name=${repo_path%%.*}
    
    if [ -d "$BUILD_DIR/$repo_name" ]; then
        echo "Deleting existing repo, $repo_name"
        rm -Rfv "$BUILD_DIR/$repo_name"
    fi

    print_banner "Checking out ${packageModel[gitRepoUrl]}"

    cd $BUILD_DIR
    git clone --recursive ${packageModel[gitRepoUrl]} -b ${packageModel[packageBranch]}
    
    cd - > /dev/null 2>&1
}

sanitize_git() {
    if [ -d  ".github" ]; then 
        rm -Rf .github 
        echo "Removed $(pwd).github directory before building to appease debuild."
    fi
    if [ -d  ".git" ]; then 
        rm -Rf .git
        echo "Removed $(pwd).git directory before building to appease debuild."
    fi
}

# Stage package source in prep to build 
stage_source() {
    print_banner "Preparing source for ${packageModel[packageName]}"
    cd $BUILD_DIR/${packageModel[buildPath]}
    full_version=$(dpkg-parsechangelog --show-field Version)
    debian_version="${full_version%-*}"
    cd $BUILD_DIR
    
    if [ "${packageModel[upstreamTarball]}" != "" ]; then
        echo "Downloading source from ${packageModel[upstreamTarball]}..."
        wget ${packageModel[upstreamTarball]} -O ${packageModel[buildPath]}/../${packageModel[packageName]}\_$debian_version.orig.tar.gz
    else
        echo "Generating source tarball from git repo."
        tar cfzv ${packageModel[packageName]}\_${debian_version}.orig.tar.gz --exclude .git\* --exclude debian ${packageModel[buildPath]}/../${packageModel[packageName]}
    fi
}

# Build
build_src_package() {
    print_banner "Building source package ${packageModel[packageName]}"
    cd $BUILD_DIR/${packageModel[buildPath]}
    
    sanitize_git    
    sudo apt build-dep -y .
    debuild -S -sa
    cd $BUILD_DIR
}

build_bin_package() {
    print_banner "Building binary package ${packageModel[packageName]}"
    cd $BUILD_DIR/${packageModel[buildPath]}
    
    sanitize_git
    debuild -sa -b
    cd $BUILD_DIR
}
