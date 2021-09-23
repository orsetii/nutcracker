#!/bin/bash

DEFAULT_BIN_PATH="./walnut.bin"

BASE_DIR="$(dirname $0)/.."

if [ $# -eq 0 ]; then
  if [ ! -f DEFAULT_BIN_PATH ]; then
    echo "Please provide a binary name as an argument"
    exit 1
  else
    BIN_PATH=$DEFAULT_BIN_PATH
  fi
else
  BIN_PATH=$1
fi

if [ "$1" = "" ]; then
  BIN_PATH=$DEFAULT_BIN_PATH
fi

if grub-file --is-x86-multiboot $BIN_PATH; then
  echo multiboot confirmed
else
  echo the file is not multiboot. exiting...
  exit 1
fi


# Create ISO directory
BUILD_DIR="$BASE_DIR/build"
GRUB_DIR="$BUILD_DIR/isodir/boot/grub"
ISO_PATH="$BUILD_DIR/walnut.iso"

mkdir -p $GRUB_DIR

# Copy and create files
cp $BIN_PATH "$GRUB_DIR/../walnut.bin"
cp "$BASE_DIR/scripts/grub.cfg" "$GRUB_DIR/"
GRUB_DEFAULT=walnut grub-mkrescue $BUILD_DIR/isodir -o $ISO_PATH -d /usr/lib/grub/i386-pc > /dev/null 2>&1

# Destroy ISO folders after creating the ISO
rm -rf "BUILD_DIR/isodir"


echo "Running QEMU..."

# Preserve exit code before we pipe to sed 
# Then remove VT100 Escape Codes
# And remove QEMU UEFI output
set -o pipefail
qemu-system-x86_64 \
  -enable-kvm \
  -nodefaults \
  -vga std \
  -machine q35,accel=kvm:tcg \
  -m 1G \
  -cdrom $ISO_PATH \
  -device isa-debug-exit,iobase=0xf4,iosize=0x04 \
  -serial stdio \
  -smp 4 \
  #-nographic | \
  $2


# Check for the desired QEMU exit code, and exit with 0
# Else, exit with the original code
[ $? -eq 33 ] && exit 0 || exit $QEMU_EXITCODE 
