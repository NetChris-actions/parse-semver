#!/bin/sh -l

InputValue="$1"

# Detect a "relaxed" major.minor version from the input
MajorMinorRegEx="((0|[1-9]\d*)\.(0|[1-9]\d*))"
majorMinorOnlyMajor=$(echo $InputValue | pcre2grep -o2 $MajorMinorRegEx)
majorMinorOnlyMinor=$(echo $InputValue | pcre2grep -o3 $MajorMinorRegEx)

# https://semver.org/#is-there-a-suggested-regular-expression-regex-to-check-a-semver-string
# - Modifications from official RegEx: 
#   - Relaxed from the published RegEx to find it the first time in a line, not requiring that the input be a pure SemVer (i.e. not bookended by beginning and end of line)
#   - Extract the version only, "trimming off" anything preceding or following it
SemVer2RegEx="((0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)(?:-((?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*)(?:\.(?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*))*))?(?:\+([0-9a-zA-Z-]+(?:\.[0-9a-zA-Z-]+)*))?)"

semVer=$(echo $InputValue | pcre2grep -o1 $SemVer2RegEx)
majorVersion=$(echo $InputValue | pcre2grep -o2 $SemVer2RegEx)
minorVersion=$(echo $InputValue | pcre2grep -o3 $SemVer2RegEx)
patchVersion=$(echo $InputValue | pcre2grep -o4 $SemVer2RegEx)
preReleaseVersion=$(echo $InputValue | pcre2grep -o5 $SemVer2RegEx)
buildMetadata=$(echo $InputValue | pcre2grep -o6 $SemVer2RegEx)

hasSemVer=false
isPreRelease=false

if [ ! -z "$semVer" ]
then
  hasSemVer=true

  if [ ! -z "$preReleaseVersion" ]
  then
    isPreRelease=true
  fi

else
  # If not an official SemVer value, use majorMinorOnlyMajor and majorMinorOnlyMinor for majorVersion and minorVersion respectively
  majorVersion=$majorMinorOnlyMajor
  minorVersion=$majorMinorOnlyMinor
fi

# Convenience construction
majorMinorOnly="$majorVersion.$minorVersion"

echo "inputValue=$InputValue" >> $GITHUB_OUTPUT
echo "hasSemVer=$hasSemVer" >> $GITHUB_OUTPUT
echo "semVer=$semVer" >> $GITHUB_OUTPUT
echo "majorMinorOnly=$majorMinorOnly" >> $GITHUB_OUTPUT
echo "majorVersion=$majorVersion" >> $GITHUB_OUTPUT
echo "minorVersion=$minorVersion" >> $GITHUB_OUTPUT
echo "patchVersion=$patchVersion" >> $GITHUB_OUTPUT
echo "preReleaseVersion=$preReleaseVersion" >> $GITHUB_OUTPUT
echo "buildMetadata=$buildMetadata" >> $GITHUB_OUTPUT
echo "isPreRelease=$isPreRelease" >> $GITHUB_OUTPUT
