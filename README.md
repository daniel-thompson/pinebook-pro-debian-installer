Pinebook Pro - Debian from Scratch
==================================

pinebook-pro-from-scratch is a simple Debian installer for the Pinebook
Pro.

It is called from-scratch because there is no downloadable image.
Instead it is a script to build a fresh image from scratch using
debootstrap and then runs a few interactive commands to help you 
customize your install.

No default passwords, no bundled software, minimal tuning, and pure
upstream debian with the exception of the vendor bootloaders and a
custom v5.4 kernel.

Just type `make`.

Quickstart
----------

The installer runs on the Pinebook Pro itself and should work on most
Debian or Ubuntu images (including the default vendor image).

1. Unmount any existing filesystems on the disk you want to install
   onto.
2. Run `make`. This will default to installing to `/dev/mmcblk1`, to
   change this try `make MMCBLK=/dev/mmcblk1` or
   `make MMCBLK=/dev/mmcblk2` as appropriate.

The installer is very incomplete at present. You may have to debug or
problem solve. `make umount` can be used to unmount the target media
after a failed attempt to install.

Limitations
-----------

 * The installer has received only minimal testing.
 * The `prep` rule may be incomplete (e.g. there may be other
   dependencies that are not automatically installed).
 * gpt.sfdisk may require hand editing to ensure the size the RootFS
   partition matches that of your eMMC or SD card.
 * Partition names cannot (yet) be customized so there might be problems
   if you use the tool to create a recovery SD card *and* install to
   eMMC (because we use partition labels to locate the rootfs).
 * No support for encrypted rootfs.
