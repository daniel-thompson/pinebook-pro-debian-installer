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
under construction will be left mounted. After performing any
problem solving you can use `make umount` to cleanly unmount the
target media.

Limitations
-----------

 * Partition names cannot (yet) be customized so there might be problems
   if you use the tool to create a recovery SD card *and* install to
   eMMC (because we use partition labels to locate the rootfs).

Hacks
-----

Mostly the installer tried to avoid hacks that cannot be replicated by a
real distro installer (e.g. one that is not tailored specifically for
Pinebook Pro). However some problems are so ackward for users the
following temporary hacks have been tolerated.

 * The ALSA state cache is pre-configured. This ensured that audio will
   work out-of-the-box. This is temporary until upstream ALSA UCM support
   for Pinebook Pro is added.
 * The kernel is booted with maxcpus=4 to ensure that is does not use
   the Cortex A72 cores during initialization. This works around a
   bootloader problem that hands these cores to the kernel with clock
   speed set so slow that it compromises boot times. The disabled cores
   will be re-enabled later in the boot process. Be warned that to make
   this work some kernel hardening must be disabled (ex:
   HARDEN_EL2_VECTORS).
 
Roadmap
-------

None... sure there will be the occasional bug fix when needed but this
installer is merely a stop gap. Once that are enough features in the
upstream kernel and the Pinebook Pro has a fully functional u-boot ready
to burn to SPI then one should expect the official Debian installer to
run unmodified. At that point this installer will be obsolete... and
good riddance!
