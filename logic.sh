#!/bin/sh -l

InputValue="$1"

# Detect a "relaxed" major.minor version from the input
MajorMinorRegEx="((0|[1-9]\d*)\.(0|[1-9]\d*))"
majorMinorOnly=$(echo $InputValue | pcre2grep -o1 $MajorMinorRegEx)
majorMinorOnlyMajor=$(echo $InputValue | pcre2grep -o2 $MajorMinorRegEx)
majorMinorOnlyMinor=$(echo $InputValue | pcre2grep -o3 $MajorMinorRegEx)

# https://semver.org/#is-there-a-suggested-regular-expression-regex-to-check-a-semver-string
# - Modifications from official RegEx: 
#   - Relaxed from the published RegEx to find it the first time in a line, not requiring that the input be a pure SemVer (i.e. not bookended by beginning and end of line)
#   - Extract the version only, "trimming off" anything preceding or following it
SemVer2RegEx="((0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)(?:-((?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*)(?:\.(?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*))*))?(?:\+([0-9a-zA-Z-]+(?:\.[0-9a-zA-Z-]+)*))?)"

semVer=$(echo $InputValue | pcre2grep -o1 $SemVer2RegEx)
semVerMajor=$(echo $InputValue | pcre2grep -o2 $SemVer2RegEx)
semVerMinor=$(echo $InputValue | pcre2grep -o3 $SemVer2RegEx)
semVerPatch=$(echo $InputValue | pcre2grep -o4 $SemVer2RegEx)
semVerPreRelease=$(echo $InputValue | pcre2grep -o5 $SemVer2RegEx)
semVerBuildMetadata=$(echo $InputValue | pcre2grep -o6 $SemVer2RegEx)

hasSemVer=false
isPreRelease=false

if [ ! -z "$semVer" ]
then
  hasSemVer=true

  if [ ! -z "$semVerPreRelease" ]
  then
    isPreRelease=true
  fi
else
  # If not an official SemVer value, use majorMinorOnlyMajor and majorMinorOnlyMinor for semVerMajor and semVerMinor respectively
  semVerMajor=$majorMinorOnlyMajor
  semVerMinor=$majorMinorOnlyMinor
fi

echo "hasSemVer=$hasSemVer"
echo "semVer=$semVer"
echo "semVerMajor=$semVerMajor"
echo "semVerMinor=$semVerMinor"
echo "semVerPatch=$semVerPatch"
echo "semVerPreRelease=$semVerPreRelease"
echo "semVerBuildMetadata=$semVerBuildMetadata"
echo "majorMinorOnly=$majorMinorOnly"
echo "majorMinorOnlyMajor=$majorMinorOnlyMajor"
echo "majorMinorOnlyMinor=$majorMinorOnlyMinor"
echo "isPreRelease=$isPreRelease"
