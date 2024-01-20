# Parse SemVer 2 versions

Use this action to parse an input string as a SemVer version.  Internally, this uses [`pcre2grep`](https://www.pcre.org/current/doc/html/pcre2grep.html) and [the official SemVer.org RegEx](https://semver.org/#is-there-a-suggested-regular-expression-regex-to-check-a-semver-string) to match values.

## SemVer Version

In this document, any reference to "SemVer" should be assumed to reference [SemVer v2.0.0](https://semver.org/spec/v2.0.0.html).

## Relaxed "major.minor" detection

In some cases it can be useful to detect a "major.minor" format version in the input, even if the input doesn't have a valid SemVer version.  Imagine a scenario where you may want to use the branch `release/v2.2` during development of an upcoming release.  The detected "major.minor" version "2.2" is not a SemVer version but can be used by the consuming job to construct a valid SemVer version for pre-release testing and deployment to non-production environments.  Given a GitHub run ID of 7522504873 you could construct a NuGet package "`MyProject.2.2.7522504873-prerelease.nupkg`".

Note that this functionality will detect _any_ "number.number" form.  Given this, `major_minor_version` should only be used to inform **non-production** products.  Production products should use a conforming SemVer version.

## Outputs

- These outputs provide a value whether the input value contains a valid SemVer version or not:
  - `has_semver_version` - "true" if the input contains a SemVer version, otherwise "false"
- These outputs provide a value as long as the input value contains a "major.minor" version:
  - `major_version` - The major version
  - `minor_version` - The minor version
  - `major_minor_version` - Convenience value containing the "major.minor" version in that form
- The remaining outputs provide values only if the input contains a valid SemVer version:
  - `semver_version` - The full SemVer version
  - `patch_version` - The patch version
  - `pre_release_version` - The pre-release version
  - `build_metadata` - The build metadata

### Input/Output Examples

| Input Value           | `has_semver_version` | `semver_version`            | `major_version` | `minor_version` | `major_minor_version` | `patch_version` | `pre_release_version` | `build_metadata` | `is_pre_release` |
| ---                   | ---         | ---                 | ---            | ---            | ---              | ---            | ---                 | ---             | ---            |
| "`1.2.3`"             | `true`      | `1.2.3`             | `1`            | `2`            | `1.2`            | `3`            | _<EMPTY>_           | _<EMPTY>_       | `false`        |
| "`5.12.23-alpha+001`" | `true`      | `5.12.23-alpha+001` | `5`            | `12`           | `5.12`           | `23`           | `alpha`             | `001`           | `true`         |
| "`v2.3`"              | `false`     | _<EMPTY>_           | `2`            | `3`            | `2.3`            | _<EMPTY>_      | _<EMPTY>_           | _<EMPTY>_`      | `false`        |
| "`v7`"                | `false`     | _<EMPTY>_           | _<EMPTY>_      | _<EMPTY>_      | _<EMPTY>_        | _<EMPTY>_      | _<EMPTY>_           | _<EMPTY>_`      | `false`        |

## Usage Examples

``` yml
name: Simplistic Example

on: [push]

jobs:
  some-job:
    runs-on: ubuntu-latest
    name: Some job that uses this action
    steps:
      - name: SemVer parse
        id: parse
        uses: NetChris/parse-semver@v1
        with:
          value_to_parse: 'v1.2.3'
      - name: Output full match
        run: echo ${{ steps.parse.outputs.semver_version }}
      - name: Output major
        run: echo ${{ steps.parse.outputs.major_version }}
      - name: Output minor
        run: echo ${{ steps.parse.outputs.minor_version }}
      - name: Output patch
        run: echo ${{ steps.parse.outputs.patch_version }}
      - name: Output prerelease
        run: echo ${{ steps.parse.outputs.pre_release_version }}
      - name: Output buildmetadata
        run: echo ${{ steps.parse.outputs.build_metadata }}
      - name: Output major_minor_version
        run: echo ${{ steps.parse.outputs.major_minor_version }}
```