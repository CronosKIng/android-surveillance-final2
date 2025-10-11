#!/bin/bash

# Determine script location and resolve symlinks
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do
  DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE"
done
DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"

# Use local gradle distribution if available
if [ -d "$DIR/gradle-8.0" ]; then
    GRADLE_HOME="$DIR/gradle-8.0"
else
    GRADLE_HOME="$DIR/gradle/wrapper/dists/gradle-8.0-bin/*/gradle-8.0"
fi

# Execute gradle with the same arguments
exec "$GRADLE_HOME/bin/gradle" "$@"
