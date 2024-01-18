#!/bin/sh -l

Version="$1"

PureRegEx="^v?(.*)$"

# https://semver.org/#is-there-a-suggested-regular-expression-regex-to-check-a-semver-string
SemVer2RegEx="^(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)(?:-((?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*)(?:\.(?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*))*))?(?:\+([0-9a-zA-Z-]+(?:\.[0-9a-zA-Z-]+)*))?$"

semVer=$(echo $Version | pcre2grep -o1 $PureRegEx)
semVerMajor=$(echo $semVer | pcre2grep -o1 $SemVer2RegEx)
semVerMinor=$(echo $semVer | pcre2grep -o2 $SemVer2RegEx)
semVerPatch=$(echo $semVer | pcre2grep -o3 $SemVer2RegEx)
semVerPreRelease=$(echo $semVer | pcre2grep -o4 $SemVer2RegEx)
semVerBuildMetadata=$(echo $semVer | pcre2grep -o5 $SemVer2RegEx)

echo "semVer=$semVer" >> $GITHUB_OUTPUT
echo "semVerMajor=$semVerMajor" >> $GITHUB_OUTPUT
echo "semVerMinor=$semVerMinor" >> $GITHUB_OUTPUT
echo "semVerPatch=$semVerPatch" >> $GITHUB_OUTPUT
echo "semVerPreRelease=$semVerPreRelease" >> $GITHUB_OUTPUT
echo "semVerBuildMetadata=$semVerBuildMetadata" >> $GITHUB_OUTPUT
