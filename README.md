# Walnut OS
<p align="center">
  <img alt="Walnut Logo" src="assets/img/WalnutComplete.svg">
</p>

This is Walnut OS's bootloader

Requires a `kmain` function in the OS, and should be linked in at compile time.

# Usage

To build to an archive, simply run:
```bash
make
```

To run the bootloader alone in QEMU (Builds to a bootable binary):
```bash
make run
```


## TODOs
- [ ] Move `link.ld` to walnut since we dont want to do any linker if we dont have a kernel, we just want to produce an object file to link w/ kernel THEN link.

## Structure

`scripts` contains a script to run the bootloader in QEMU, via creating an ISO with `grub-mkrescue` and `xorriso`.
`src` contains the source code.
`assets` images, unrelated to functionality.

