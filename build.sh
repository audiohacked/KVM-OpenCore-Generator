#!/usr/bin/bash

PWD=$(pwd)
IMG="test.qcow2"
MNT="./build"

### Create Blank Disk
qemu-img create -f qcow2 ${IMG} 2G

### Mount QCow2 Disk as Device
# modprobe nbd
qemu-nbd -c /dev/nbd0 ${IMG}

### Create GPT Table
parted /dev/nbd0 mktable gpt

### Create EFI Partition
parted /dev/nbd0 mkpart ESP fat32 1MiB 1025MiB
parted /dev/nbd0 set 1 esp on

### Format EFI Partition
mkfs.vfat -F 32 /dev/nbd0p1

### Mount EFI Partition
mount /dev/nbd0p1 ${MNT}

### Build EFI Structure
mkdir -p ${MNT}/EFI/{BOOT,OC}

### Add OpenCore
cp -v src/OpenCorePkg/Docs/Sample.plist ${MNT}/EFI/OC/config.plist
cp -vf src/OpenCorePkg/Docs/SampleFull.plist ${MNT}/EFI/OC/

### Unmount EFI Partition
umount /dev/nbd0p1

### Unmount QCow2 Disk 
qemu-nbd --disconnect /dev/nbd0

### Convert Raw to QCow2
#qemu-img convert -f raw OpenCore.img -O qcow2 OpenCore.qcow2
