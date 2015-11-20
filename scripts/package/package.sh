#!/usr/bin/env bash
#
# Copyright (c) .NET Foundation and contributors. All rights reserved.
# Licensed under the MIT license. See LICENSE file in the project root for full license information.
#

SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
REPOROOT="$( cd -P "$DIR/../.." && pwd )"

source "$DIR/../_common.sh"

echo "Starting packaging"

[ ! -z "$DOTNETCLI_BUILD_VERSION" ] || die "Missing required environment variable DOTNETCLI_BUILD_VERSION"

COMMIT=$(git rev-parse HEAD)
echo $COMMIT > $STAGE2_DIR/.version
echo $DOTNETCLI_BUILD_VERSION >> $STAGE2_DIR/.version

# Create NuGet Packages
OUTPUT_DIR=$REPOROOT/artifacts/packages/nupkg $DIR/package-nupkg.sh

# Create Dnvm Package
$DIR/package-dnvm.sh

if [[ "$UNAME" == "Linux" ]]; then
    # Create Debian package
    $DIR/package-debian.sh
elif [[ "$UNAME" == "Darwin" ]]; then
    # Create OSX PKG
    $DIR/../../packaging/osx/package-osx.sh
fi

