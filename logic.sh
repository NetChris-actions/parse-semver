#!/bin/sh -l

run_id="$1"
run_number="$2"
run_attempt="$3"
value_to_parse="$4"

echo "run_id=$run_id"
echo "run_number=$run_number"
echo "run_attempt=$run_attempt"
echo "value_to_parse=$value_to_parse"

if [ -z "$run_id" ]
then
  echo "No run_id"
  exit 1
fi

if [ -z "$run_number" ]
then
  echo "No run_number"
  exit 1
fi

if [ -z "$run_attempt" ]
then
  echo "No run_attempt"
  exit 1
fi

if [ -z "$value_to_parse" ]
then
  echo "No value to parse"
  exit 1
fi

# Detect a "relaxed" major.minor version from the input
MajorMinorRegEx="((0|[1-9]\d*)\.(0|[1-9]\d*))"
major_minor_version=$(echo $value_to_parse | pcre2grep -o1 $MajorMinorRegEx)
majorMinorOnlyMajor=$(echo $value_to_parse | pcre2grep -o2 $MajorMinorRegEx)
majorMinorOnlyMinor=$(echo $value_to_parse | pcre2grep -o3 $MajorMinorRegEx)

# https://semver.org/#is-there-a-suggested-regular-expression-regex-to-check-a-semver-string
# - Modifications from official RegEx: 
#   - Relaxed from the published RegEx to find it the first time in a line, not requiring that the input be a pure SemVer (i.e. not bookended by beginning and end of line)
#   - Extract the version only, "trimming off" anything preceding or following it
SemVer2RegEx="((0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)(?:-((?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*)(?:\.(?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*))*))?(?:\+([0-9a-zA-Z-]+(?:\.[0-9a-zA-Z-]+)*))?)"

semver_version=$(echo $value_to_parse | pcre2grep -o1 $SemVer2RegEx)
major_version=$(echo $value_to_parse | pcre2grep -o2 $SemVer2RegEx)
minor_version=$(echo $value_to_parse | pcre2grep -o3 $SemVer2RegEx)
patch_version=$(echo $value_to_parse | pcre2grep -o4 $SemVer2RegEx)
pre_release_version=$(echo $value_to_parse | pcre2grep -o5 $SemVer2RegEx)
build_metadata=$(echo $value_to_parse | pcre2grep -o6 $SemVer2RegEx)

if [ -z "$semver_version" ]
then
  # If not an official SemVer value, use majorMinorOnlyMajor and majorMinorOnlyMinor for major_version and minor_version respectively
  major_version=$majorMinorOnlyMajor
  minor_version=$majorMinorOnlyMinor

  _fallback_prerelease="fallback-$run_number-$run_attempt"

  # Low-priority WARNING: dotnet_assembly_version and nuget_version will stop working after run_number exceeds 65534
  # REALLY Low-priority WARNING: The same holds true for run_attempt
  # https://learn.microsoft.com/en-us/dotnet/api/system.reflection.assemblyversionattribute
  # https://stackoverflow.com/a/44680001/208990
  _fallback_microsoft_version_suffix="$run_attempt.$run_number"
  _fallback_nuget_version_suffix="$run_attempt.$run_number-$_fallback_prerelease"

  if [ -z "$major_minor_version" ]
  then
    fallback_version="0.0.$run_id-$_fallback_prerelease"
    dotnet_assembly_version="0.0.$_fallback_microsoft_version_suffix"
    nuget_version="0.0.$_fallback_nuget_version_suffix"
  else
    fallback_version="$major_minor_version.$run_id-$_fallback_prerelease"
    dotnet_assembly_version="$major_minor_version.$_fallback_microsoft_version_suffix"
    nuget_version="$major_minor_version.$_fallback_nuget_version_suffix"
  fi

else
  fallback_version=$semver_version
  dotnet_assembly_version="$major_version.$minor_version.0.$patch_version"
  nuget_version="$major_version.$minor_version.$patch_version"

  if [ ! -z "$pre_release_version" ]
  then
    nuget_version="$nuget_version-$pre_release_version"
  fi
fi

echo "value_to_parse=$value_to_parse"
echo "semver_version=$semver_version"
echo "major_minor_version=$major_minor_version"
echo "major_version=$major_version"
echo "minor_version=$minor_version"
echo "patch_version=$patch_version"
echo "pre_release_version=$pre_release_version"
echo "build_metadata=$build_metadata"
echo "fallback_version=$fallback_version"
echo "dotnet_assembly_version=$dotnet_assembly_version"
echo "nuget_version=$nuget_version"
