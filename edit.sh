#!/usr/bin/bash

LIBGUESTFS_BACKEND=direct

DISK_IMAGE=${1:-"test.qcow2"}
MOUNT_POINT=${2:-"/mnt/opencore"}

IMG_TYPE=$(qemu-img info --output json ${DISK_IMAGE} | jq -r -e ."format" )

INT_DEV="/dev/sda"
INT_MNT_PT="/"
INT_MNT_OPTS="rw"
INT_FS_TYPE="vfat"


# Check Disk Format (QCow2 or RAW)
if [ ${IMG_TYPE} == "qcow2" ]; then
    QCOW2_METHOD=true
else
    QCOW2_METHOD=false
fi

### Load NBD Driver
modprobe nbd

### Open QCow2
if [ ${QCOW2_METHOD} = true ]; then
    # guestmount \
    #     --add ${DISK_IMAGE} \
    #     --mount ${INT_DEV}:${INT_MNT_PT}:${INT_MNT_OPTS}:${INT_FS_TYPE} \
    #     build
    echo "== Loading Image GPT"
    qemu-nbd -v --connect /dev/nbd0 ${DISK_IMAGE}
    
    echo "== Mounting Image Partition"
    mount /dev/nbd0p1 ${MOUNT_POINT}
    
    echo "== Do Work"
fi

### Open EFI Partiton

### Unmount QCow2
#     guestmount --add ${DISK_IMAGE} --mount ${INT_DEV}:${INT_MNT_PT}:${INT_MNT_OPTS}:${INT_FS_TYPE} ./build
# if [ ${QCOW2_METHOD} = true ]; then
#     echo "== Unmounting Image Partition"; umount /dev/nbd0p1
#     echo "== Unloading Image GPT"; qemu-nbd --disconnect /dev/nbd0
# fi

### Close NBD Driver
# modprobe -r nbd
