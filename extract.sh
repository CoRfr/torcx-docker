#!/bin/bash

set -xe
set -o pipefail

CONTAINER_IMG=${CONTAINER_IMG:-'coreos_developer_container.bin.bz2'}
TMP_DIR=${TMP_DIR:-$(mktemp --directory --tmpdir=$(pwd))}
COREOS_RELEASE=${COREOS_RELEASE:-'current'}
CONTAINER_URL=${CONTAINER_URL:-"https://alpha.release.core-os.net/amd64-usr/${COREOS_RELEASE}/coreos_developer_container.bin.bz2"}
MOUNTPOINT=${MOUNTPOINT:-"$TMP_DIR/rootfs"}

mkdir -p $TMP_DIR

if [ -e "$CONTAINER_IMG" ]; then
    CONTAINER_IMG="$(readlink -f $CONTAINER_IMG)"
else
    CONTAINER_IMG="${TMP_DIR}/${CONTAINER_IMG}"

    echo "Downloading from ${CONTAINER_URL}"
    wget -q -O "${CONTAINER_IMG}" "${CONTAINER_URL}"
fi

echo "Using $CONTAINER_IMG"

CONTAINER_BIN="$TMP_DIR/coreos_developer_container.bin"

cleanup() {
    echo "Cleaning up"

    if grep -q "$MOUNTPOINT" /proc/mounts; then
        sudo umount "$MOUNTPOINT"
        sleep 5
    fi

    if [ -n "$CONTAINER_BIN" ]; then
        sudo kpartx -v -d "$CONTAINER_BIN"
    fi

    rm -rf $TMP_DIR
}

die() {
    cleanup
    exit 1
}

echo "Extracting ..."
BUNZIP2=bunzip2
if which lbunzip2; then
    BUNZIP2=lbunzip2
fi
$BUNZIP2 --keep --stdout "$CONTAINER_IMG" > "$CONTAINER_BIN" || die

export PATH="$PATH:/sbin"

echo "Mapping device to $CONTAINER_BIN"
sudo kpartx -v -a "$CONTAINER_BIN" | tee "${TMP_DIR}/kpartx-out" || die

LOOP_DEV=$(tail -1 "${TMP_DIR}/kpartx-out" | awk '{print $3}')

ROOTFS_PART="/dev/mapper/${LOOP_DEV}"

mkdir -p $MOUNTPOINT

sleep 5

echo "Mounting ..."
sudo mount -o loop $ROOTFS_PART $MOUNTPOINT || die

echo "Copying new version ..."
rsync -av "${MOUNTPOINT}/usr/share/torcx/store/" . || die

cleanup

echo "Success !"

