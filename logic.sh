#!/bin/sh -l

InputValue="$1"

# https://semver.org/#is-there-a-suggested-regular-expression-regex-to-check-a-semver-string
# This is relaxed to find it the first time in a line
SemVer2RegEx="((0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)(?:-((?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*)(?:\.(?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*))*))?(?:\+([0-9a-zA-Z-]+(?:\.[0-9a-zA-Z-]+)*))?)"

Version=$(echo $InputValue | pcre2grep $SemVer2RegEx)

semVer=$(echo $Version | pcre2grep -o1 $SemVer2RegEx)
semVerMajor=$(echo $Version | pcre2grep -o2 $SemVer2RegEx)
semVerMinor=$(echo $Version | pcre2grep -o3 $SemVer2RegEx)
semVerPatch=$(echo $Version | pcre2grep -o4 $SemVer2RegEx)
semVerPreRelease=$(echo $Version | pcre2grep -o5 $SemVer2RegEx)
semVerBuildMetadata=$(echo $Version | pcre2grep -o6 $SemVer2RegEx)

MajorMinorRegEx="((0|[1-9]\d*)\.(0|[1-9]\d*))"
majorMinorOnly=$(echo $Version | pcre2grep -o1 $MajorMinorRegEx)

hasSemVer=false
isPreRelease=false

if [ ! -z "$semVer" ]
then
  hasSemVer=true

  if [ ! -z "$semVerPreRelease" ]
  then
    isPreRelease=true
  fi
fi

echo "hasSemVer=$hasSemVer"
echo "semVer=$semVer"
echo "semVerMajor=$semVerMajor"
echo "semVerMinor=$semVerMinor"
echo "semVerPatch=$semVerPatch"
echo "semVerPreRelease=$semVerPreRelease"
echo "semVerBuildMetadata=$semVerBuildMetadata"
echo "majorMinorOnly=$majorMinorOnly"
echo "isPreRelease=$isPreRelease"
