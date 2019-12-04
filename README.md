Pinebook Pro - Debian from Scratch
==================================

pinebook-pro-debian-installer is an unofficial Debian installer for the
Pinebook Pro. It is not endorsed by either Debian or Pine Microsystems.

There is no downloadable image, instead it is a script that constructs
a fresh image from scratch using debootstrap and then runs a few
interactive commands to help you customize your install.

No default passwords, no bundled software, minimal tuning, and uses
pure upstream debian (albeit with the exception of the vendor
bootloaders and a custom v5.4 kernel).

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

If the installer fails for any reason then the filesystem
underconstruction will be left mounted. After performing any
problem solving you can use `make umount` to cleanly unmount the
target media.

Limitations
-----------

 * The installer has received only minimal testing.
 * The `prep` rule may be incomplete (e.g. there may be other
   dependencies that are not automatically installed).
 * Partition names cannot (yet) be customized so there might be problems
   if you use the tool to create a recovery SD card *and* install to
   eMMC (because we use partition labels to locate the rootfs).
 * No support for encrypted rootfs.

Roadmap
-------

None... sure there will be the occasional bug fix when needed but this
installer is merely a stop gap. Once that are enough features in the
upstream kernel and the Pinebook Pro has a fully functional u-boot ready
to burn to SPI then one should expect the official Debian installer to
run unmodified. At that point this installer will be obsolete... and
good riddance!
