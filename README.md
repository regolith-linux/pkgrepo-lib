# pkgrepo-lib

This contains a set of shell scripts and a tweakable github action that can be used to generate Regolith packages for some target distribution/release.

## Package Model

Manifest and package generation use a package model as a primary source.  A package model is a JSON document with a root property "packages" of a list of objects as below:

```json
{
    "packages": [
        {
            "gitRepoUrl": "https://github.com/something-something.git",
            "packageName": ?,
            "buildPath": ?,
            "upstreamTarball": ?,
            "packageBranch": ?
        },
        ...
    ],
    ...
}
```

## Script Summary

### build-common.sh

Some common functions for dealing with the package model.

### build-dep-repo.sh

Generates a Debian package repository.  Can be used as an example to call into other package manager tooling.

### build-manifest.sh

Generates a list of source package metadata: repo, branch, commit.  This list is used to determine when a package should be rebuilt.  The input to this script is a package model.

## Github Workflow

A sample github workflow file demonstrates the generation of a Debian repository.