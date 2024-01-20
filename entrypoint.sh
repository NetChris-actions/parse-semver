#!/bin/sh -l

InputValue="$1"

if [ -z "$InputValue" ]
then
  echo "No input value"
  return -1
fi

# Detect a "relaxed" major.minor version from the input
MajorMinorRegEx="((0|[1-9]\d*)\.(0|[1-9]\d*))"
major_minor_version=$(echo $InputValue | pcre2grep -o1 $MajorMinorRegEx)
majorMinorOnlyMajor=$(echo $InputValue | pcre2grep -o2 $MajorMinorRegEx)
majorMinorOnlyMinor=$(echo $InputValue | pcre2grep -o3 $MajorMinorRegEx)

# https://semver.org/#is-there-a-suggested-regular-expression-regex-to-check-a-semver-string
# - Modifications from official RegEx: 
#   - Relaxed from the published RegEx to find it the first time in a line, not requiring that the input be a pure SemVer (i.e. not bookended by beginning and end of line)
#   - Extract the version only, "trimming off" anything preceding or following it
SemVer2RegEx="((0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)(?:-((?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*)(?:\.(?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*))*))?(?:\+([0-9a-zA-Z-]+(?:\.[0-9a-zA-Z-]+)*))?)"

semver_version=$(echo $InputValue | pcre2grep -o1 $SemVer2RegEx)
major_version=$(echo $InputValue | pcre2grep -o2 $SemVer2RegEx)
minor_version=$(echo $InputValue | pcre2grep -o3 $SemVer2RegEx)
patch_version=$(echo $InputValue | pcre2grep -o4 $SemVer2RegEx)
pre_release_version=$(echo $InputValue | pcre2grep -o5 $SemVer2RegEx)
build_metadata=$(echo $InputValue | pcre2grep -o6 $SemVer2RegEx)

has_semver_version=false
is_pre_release=false

if [ ! -z "$semver_version" ]
then
  has_semver_version=true

  if [ ! -z "$pre_release_version" ]
  then
    is_pre_release=true
  fi

else
  # If not an official SemVer value, use majorMinorOnlyMajor and majorMinorOnlyMinor for major_version and minor_version respectively
  major_version=$majorMinorOnlyMajor
  minor_version=$majorMinorOnlyMinor
fi

echo "has_semver_version=$has_semver_version" >> $GITHUB_OUTPUT
echo "semver_version=$semver_version" >> $GITHUB_OUTPUT
echo "major_minor_version=$major_minor_version" >> $GITHUB_OUTPUT
echo "major_version=$major_version" >> $GITHUB_OUTPUT
echo "minor_version=$minor_version" >> $GITHUB_OUTPUT
echo "patch_version=$patch_version" >> $GITHUB_OUTPUT
echo "pre_release_version=$pre_release_version" >> $GITHUB_OUTPUT
echo "build_metadata=$build_metadata" >> $GITHUB_OUTPUT
echo "is_pre_release=$is_pre_release" >> $GITHUB_OUTPUT
