#!/usr/bin/env bash

# Check whether a specific version of the Scala 3 compiler is published to Maven Central
#
# Usage:
#   is-version-published.sh <version_string>
# e.g.
#   ./is-version-published.sh 3.0.1-RC1-bin-20210411-b44cafa-NIGHTLY
#
# Exit status:
#   zero      if the specified version is published on Maven Central
#   non-zero  otherwise

ver=$1
if [[ -z "$ver" ]]; then
  echo "error: missing version parameter"
  echo "usage: $0 <version_string>"
  exit 2
fi

set -eu

major=${ver%%-bin-*}
maven_url=https://repo1.maven.org/maven2/org/scala-lang/scala3-compiler_$major/maven-metadata.xml

echo "Checking whether $ver is published"
echo "at $maven_url"
echo ""

published=$(curl -s --fail --show-error -L "$maven_url" | sed -ne '/<version>/ s!<version>\(.*\)</version>!\1! p')
if [[ -n "$published" ]]; then
  echo "Found published versions:"
  echo "$published" | xargs -n1
  echo ""

  for p in $published ; do
    if [[ "$p" == "$ver" ]]; then
      echo "Version $ver is already published."
      exit 0
    fi
  done
  echo "Version $ver is not yet published."
  exit 10
else
  echo "Unable to determine published versions."
  exit 20
fi
