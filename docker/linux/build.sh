#!/bin/bash

set -ex

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

: "${BASE_IMAGE:=ubuntu:20.04}"
: "${CLEANUP:=1}"

VER="${BASE_IMAGE/:/-}"
BUILD_NAME="$USER-$VER"

prereq_csum()
{
    find "." -type f | sort | xargs -L1 cat | sha512sum | awk '{print $0}'
}

cd "$SCRIPT_DIR"

TMP="./$HOSTNAME-$USER.tmp"
mkdir -p "$TMP"
rsync -a "./prerequisites.sh" "./docker_startup.sh" "$TMP"

DOCKER_CMD=(
    docker build
    -t "$BUILD_NAME"
    -f "./Dockerfile"
    --build-arg "INT_TMP=$TMP"
    --build-arg HOST_HOME_DIR="$HOME"
    --build-arg BASE_IMAGE="$BASE_IMAGE"
    --label prereq-csum="$(prereq_csum)"
    --label build-host=$HOSTNAME
    --label build-user=$USER
    "$SCRIPT_DIR"
    "$@"
)
"${DOCKER_CMD[@]}"

if [ "$CLEANUP" -ne 0 ]; then
    rm -r "$TMP"
fi
