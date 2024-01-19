# Parse SemVer versions

Use this action to parse an input string as a SemVer version.  Internally, this uses [`pcre2grep`](https://www.pcre.org/current/doc/html/pcre2grep.html) and [the official SemVer.org RegEx](https://semver.org/#is-there-a-suggested-regular-expression-regex-to-check-a-semver-string) to match values.

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
        run: echo ${{ steps.parse.outputs.semVerMajor }}
      - name: Output minor
        run: echo ${{ steps.parse.outputs.semVerMinor }}
      - name: Output patch
        run: echo ${{ steps.parse.outputs.semVerPatch }}
      - name: Output prerelease
        run: echo ${{ steps.parse.outputs.semVerPreRelease }}
      - name: Output buildmetadata
        run: echo ${{ steps.parse.outputs.semVerBuildMetadata }}
      - name: Output majorMinorOnly
        run: echo ${{ steps.parse.outputs.majorMinorOnly }}
```