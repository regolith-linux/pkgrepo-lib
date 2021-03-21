# pkgrepo-lib

This contains a package model, shell functions, and a github action that can be used to generate Regolith packages for some target distribution/release.

## Status

Everything in this repo is in active development and subject to change.

# Package Model

Manifest and package generation use a package model as a primary source.  A package model is a JSON document with root objects `description` and `packages` as below:

```json
{
  "description": {
    "title": ...
  },
  "packages": {
    "some-package-name": {
      "source": "some-package-git-url",      
      "branch": "some-branch-name",
      "name": "some-distro-specific-name"
    },
    "another-package": {
      "upstreamTarball": "some-url-to-tar.gz",
      ...
    }
  }
}
```

## Model Fields

```
modelDescription: Description for package model (common for all packages in model file)
name: (Optional) Regolith name for a linux package. Default is Debian naming if exists.  May be overridden
          by specifying property 'name' in object.  If unspecifed object key is used.
source: SCM URL from which the package can be cloned.
branch: branch to pull source from to build
upstreamTarball: (optional) download a file and extract rather than clone git repo
```

## Overriding Values

This particular structure was chosen to allow for parent/child customization of a package model for a specific target environment.  For example, on some particular distribution a given package may be called something other than what it's called in Debian.  For that, a package diff file could be added to the distro-specific repo such that the final model file contains the distro-specific name.

Example:
```
tbd
```

# Script Summary

### build-common.sh

Some common functions for dealing with the package model.

### build-demo.sh

An example shell script that calls the common functions to process the package model.  This script simply prints out the model values.  The script is intended to be used as a starting point for other package build scripts.
### build-dep-repo.sh

Generates a Debian package repository.  Can be used as an example to call into other package manager tooling.

### build-manifest.sh

Generates a list of source package metadata: repo, branch, commit.  This list is used to determine when a package should be rebuilt.  The input to this script is a package model.

# Github Workflow

A sample [github workflow](blob/master/.github/workflows/ci-NAME_HERE.yml) file demonstrates the generation of a Debian repository.