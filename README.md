# Parse SemVer 2 versions

Use this action to parse an input string as a SemVer version.  Internally, this uses [`pcre2grep`](https://www.pcre.org/current/doc/html/pcre2grep.html) and [the official SemVer.org RegEx](https://semver.org/#is-there-a-suggested-regular-expression-regex-to-check-a-semver-string) to match values.

## SemVer Version

In this document, any reference to "SemVer" should be assumed to reference [SemVer v2.0.0](https://semver.org/spec/v2.0.0.html).

## Relaxed "major.minor" detection

In some cases it can be useful to detect a "major.minor" format version in the input, even if the input doesn't have a valid SemVer version.  Imagine a scenario where you may want to use the branch `release/v2.2` during development of an upcoming release.  The detected "major.minor" version "2.2" is not a SemVer version but can be used by the consuming job to construct a valid SemVer version for pre-release testing and deployment to non-production environments.  Given a GitHub run ID of 7522504873 you could construct a NuGet package "`MyProject.2.2.7522504873-prerelease.nupkg`".

Note that this functionality will detect _any_ "number.number" form.  Given this, `majorMinorOnly` should only be used to inform **non-production** products.  Production products should use a conforming SemVer version.

## Outputs

- These outputs provide a value whether the input value contains a valid SemVer version or not:
  - `hasSemVer` - "true" if the input contains a SemVer version, otherwise "false"
- These outputs provide a value as long as the input value contains a "major.minor" version:
  - `majorVersion` - The major version
  - `minorVersion` - The minor version
  - `majorMinorOnly` - Convenience value containing the "major.minor" version in that form
- The remaining outputs provide values only if the input contains a valid SemVer version:
  - `semVer` - The full SemVer version
  - `patchVersion` - The patch version
  - `preReleaseVersion` - The pre-release version
  - `buildMetadata` - The build metadata

### Input/Output Examples

| Input Value           | `hasSemVer` | `semVer`            | `majorVersion` | `minorVersion` | `majorMinorOnly` | `patchVersion` | `preReleaseVersion` | `buildMetadata` | `isPreRelease` |
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
          parseValue: 'v1.2.3'
      - name: Output full match
        run: echo ${{ steps.parse.outputs.semVer }}
      - name: Output major
        run: echo ${{ steps.parse.outputs.majorVersion }}
      - name: Output minor
        run: echo ${{ steps.parse.outputs.minorVersion }}
      - name: Output patch
        run: echo ${{ steps.parse.outputs.patchVersion }}
      - name: Output prerelease
        run: echo ${{ steps.parse.outputs.preReleaseVersion }}
      - name: Output buildmetadata
        run: echo ${{ steps.parse.outputs.buildMetadata }}
      - name: Output majorMinorOnly
        run: echo ${{ steps.parse.outputs.majorMinorOnly }}
```