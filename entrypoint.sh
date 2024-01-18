#!/bin/sh -l

Version="$1"

RegEx="^v?(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)(?:-((?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*)(?:\.(?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*))*))?(?:\+([0-9a-zA-Z-]+(?:\.[0-9a-zA-Z-]+)*))?$"

all=$(echo $Version | pcre2grep $RegEx)
major=$(echo $Version | pcre2grep -o1 $RegEx)
minor=$(echo $Version | pcre2grep -o2 $RegEx)
patch=$(echo $Version | pcre2grep -o3 $RegEx)
prerelease=$(echo $Version | pcre2grep -o4 $RegEx)
buildmetadata=$(echo $Version | pcre2grep -o5 $RegEx)

echo "all=$all" >> $GITHUB_OUTPUT
echo "major=$major" >> $GITHUB_OUTPUT
echo "minor=$minor" >> $GITHUB_OUTPUT
echo "patch=$patch" >> $GITHUB_OUTPUT
echo "prerelease=$prerelease" >> $GITHUB_OUTPUT
echo "buildmetadata=$buildmetadata" >> $GITHUB_OUTPUT
