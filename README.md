# Parse SemVer 2 versions

Use this action to derive a SemVer version from git ref or parse an input string as a SemVer version.  Internally, this uses [`pcre2grep`](https://www.pcre.org/current/doc/html/pcre2grep.html) and [the official SemVer.org RegEx](https://semver.org/#is-there-a-suggested-regular-expression-regex-to-check-a-semver-string) to match values.

## SemVer Version

In this document, any reference to "SemVer" should be assumed to reference [SemVer v2.0.0](https://semver.org/spec/v2.0.0.html).

## Relaxed "major.minor" detection

In some cases it can be useful to detect a "major.minor" format version in the input, even if the input doesn't have a valid SemVer version.  Imagine a scenario where you may want to use the branch `release/v2.2` during development of an upcoming release.  The detected "major.minor" version "2.2" is not a SemVer version but can be used by the consuming job to construct a valid SemVer version for pre-release testing and deployment to non-production environments.  Given a GitHub run ID of 7522504873 you could construct a NuGet package "`MyProject.2.2.7522504873-prerelease.nupkg`".

Note that this functionality will detect _any_ "number.number" form.  Given this, `major_minor_version` should only be used to inform **non-production** products.  Production products should use a conforming SemVer version.

## Input

For normal operations, there is a single input, `value_to_parse`.  It defaults to using `gitlab.ref` to automatically try to parse the branch or tag.

For debugging you can also input specific values for GitHub action metadata that would normally be defaulted from the in-progress action:

- `run_id`
- `run_number`
- `run_attempt`

## Outputs

- These outputs provide a value as long as the input value contains a "major.minor" version:
  - `major_version` - The major version
  - `minor_version` - The minor version
  - `major_minor_version` - Convenience value containing the "major.minor" version in that form
- These outputs provide values only if the input contains a valid SemVer version:
  - `semver_version` - The full SemVer version
  - `patch_version` - The patch version
  - `pre_release_version` - The pre-release version
  - `build_metadata` - The build metadata
- Remaining outputs provide values in all cases:
  - `fallback_version` provides a best-effort at a version, choosing the first possible value from:
    - If matched, `semver_version`
    - If `major_minor_version` is available, that value with a patch version from the GitHub `run_id` and a prerelease constructed from `run_number` and `run_attempt`
      -  (e.g. `1.2.123456789-fallback-2-3` assuming `major_minor_version` is `1.2`)
    - If all fails, assume major and minor version of `0` and the same patch and prerelease construction
      -  e.g. `0.0.123456789-fallback-2-3`
  - `value_to_parse` echoes back the `value_to_parse` input, useful for debugging the calling action

### Input/Output Examples

| Input Value           | `value_to_parse`    | `semver_version`            | `major_version` | `minor_version` | `major_minor_version` | `patch_version` | `pre_release_version` | `build_metadata` | `fallback_version`                                    |
| ---                   | ---                 | ---                         | ---             | ---             | ---                   | ---             | ---                   | ---              | ---                                                   |
| "`1.2.3`"             | `1.2.3`             | `1.2.3`                     | `1`             | `2`             | `1.2`                 | `3`             | _<EMPTY>_             | _<EMPTY>_        | `1.2.3`                                               |
| "`5.12.23-alpha+001`" | `5.12.23-alpha+001` | `5.12.23-alpha+001`         | `5`             | `12`            | `5.12`                | `23`            | `alpha`               | `001`            | `5.12.23-alpha+001`                                   |
| "`v2.3`"              | `v2.3`              | _<EMPTY>_                   | `2`             | `3`             | `2.3`                 | _<EMPTY>_       | _<EMPTY>_             | _<EMPTY>_`       | `2.3.123456789-fallback-2-3` (sample GH run metadata) |
| "`v7`"                | `v7`                | _<EMPTY>_                   | _<EMPTY>_       | _<EMPTY>_       | _<EMPTY>_             | _<EMPTY>_       | _<EMPTY>_             | _<EMPTY>_`       | `0.0.123456789-fallback-2-3` (sample GH run metadata) |

## Usage Examples

Allow the action to pull the value from `gitlab.ref` itself

``` yaml
name: parse-semver test - use default

on: [push]

jobs:
  test:
    runs-on: ubuntu-latest
    name: Parse GITHUB_REF_NAME for SemVer
    steps:
      - name: Output github.ref
        run: echo "${{ github.ref }}"
      - name: Parse GitHub ref
        id: parse
        uses: NetChris/parse-semver@v0
      - name: Output value_to_parse
        run: echo "${{ steps.parse.outputs.value_to_parse }}"
      - name: Has semver_version?
        if: ${{ steps.parse.outputs.semver_version != '' }}
        run: echo "${{ steps.parse.outputs.semver_version }}"
      - name: Major/Minor detected?
        if: ${{ steps.parse.outputs.major_minor_version != '' }}
        run: echo "${{ steps.parse.outputs.major_minor_version }}"
      - name: Output major version
        run: echo ${{ steps.parse.outputs.major_version }}
      - name: Output minor version
        run: echo ${{ steps.parse.outputs.minor_version }}
      - name: Output SemVer patch component
        run: echo ${{ steps.parse.outputs.patch_version }}
      - name: Output SemVer prerelease component
        run: echo ${{ steps.parse.outputs.pre_release_version }}
      - name: Output SemVer buildmetadata component
        run: echo ${{ steps.parse.outputs.build_metadata }}
```

Pass in a value to `value_to_parse`

``` yaml
name: parse-semver test - passed value "v1.2.3"

on: [push]

jobs:
  test:
    runs-on: ubuntu-latest
    name: Parse GITHUB_REF_NAME for SemVer
    steps:
      - name: Parse GitHub ref
        id: parse
        uses: NetChris/parse-semver@v0
        with:
          value_to_parse: 'v1.2.3'
      - name: Output value_to_parse
        run: echo "${{ steps.parse.outputs.value_to_parse }}"
      - name: Has semver_version?
        if: ${{ steps.parse.outputs.semver_version != '' }}
        run: echo "${{ steps.parse.outputs.semver_version }}"
      - name: Major/Minor detected?
        if: ${{ steps.parse.outputs.major_minor_version != '' }}
        run: echo "${{ steps.parse.outputs.major_minor_version }}"
      - name: Output major version
        run: echo ${{ steps.parse.outputs.major_version }}
      - name: Output minor version
        run: echo ${{ steps.parse.outputs.minor_version }}
      - name: Output SemVer patch component
        run: echo ${{ steps.parse.outputs.patch_version }}
      - name: Output SemVer prerelease component
        run: echo ${{ steps.parse.outputs.pre_release_version }}
      - name: Output SemVer buildmetadata component
        run: echo ${{ steps.parse.outputs.build_metadata }}
```