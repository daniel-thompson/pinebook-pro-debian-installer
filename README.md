Pinebook Pro - Debian from Scratch
==================================

pinebook-pro-debian-installer is an unofficial Debian installer for the
Pinebook Pro. It is not endorsed by either Debian or Pine Microsystems.

There is no downloadable image, instead it is a script that constructs
a fresh image from scratch using [debootstrap](https://wiki.debian.org/Debootstrap)
and then runs a few interactive commands to help you customize your install.

No default passwords, no bundled software, minimal tuning, and uses
pure upstream Debian (albeit with the exception of the vendor
bootloaders and a custom v5.4 kernel).

To install to the removable SD card slot, just run `./install-debian`.

Quickstart
----------

The installer runs on the Pinebook Pro itself using an already installed
operating system. It should work from most Debian or Ubuntu images
(including the default vendor image).

1. Unmount any existing filesystems on the disk you want to install
   onto.
2. Run `./install-debian`. This will default to installing to the SD card,
   to change this try `./install-debian BLKDEV=/dev/mmcblk0`, 
   `./install-debian BLKDEV=/dev/mmcblk2`
   or `./install-debian BLKDEV=/dev/sda` as appropriate.

Additional options
------------------

These options can be supplied on the command line or via the
environment.

 * `BLKDEV=<blkdev>` - Install to the specified block device (e.g.
   `/dev/mmcblk2`)
 * `BLKNAME=<name>` - Name to describe the install media (e.g. `eMMC`,
   `microSD`, `NVME`). This is used for the filesystem and partition labels
   and some file managers will use these to help you identify which
   volume is which. If not supplied defaults to the basename of
   `BLKDEV` (e.g.  `mmcblk1`).
 * `CRYPT=y` - Encrypt the filesystem (and swap space) using LUKS. This
   requires your kernel to support filesystem encryption. The original
   factory distro did not include this feature so it it not possible to
   install a LUKS filesystem from this distro. However you can make a
   temporary unencrypted install with this installer and then use the
   temporary OS to perform a full encypted install.
 * `DRYRUN=y` - Show the commands the installer would "like" to run but
   do not execute any of them.
 * `MMCBLK=<blkdev>` - (deprecated) alias for `BLKDEV=`

Support
-------

 * For support and general discussion use the
   [Pine64 forum](https://forum.pine64.org/showthread.php?tid=8487).
 * Check out the Pine64 wiki for [feature status, known issues and 
   workarounds](https://wiki.pine64.org/index.php/Pinebook_Pro_Debian_Installer).
   Please contribute to the wiki and help keep it up to date! If you already
   have a forum login then this can also be used to update the wiki.
 * Please only use the github Issue tracker for bugs in the installer
   and the custom kernel. Problems that originate with upstream Debian
   packages should be reported to the upstream instead. If in doubt
   then ask on the forum!

Roadmap
-------

None... sure there will be the occasional bug fix when needed but this
installer is merely a stop gap. Once that are enough features in the
upstream kernel and the Pinebook Pro has a fully functional u-boot ready
to burn to SPI then one should expect the official Debian installer to
run unmodified. At that point this installer will be obsolete... and
good riddance!

Hacks
-----

Mostly the installer tried to avoid hacks that cannot be replicated by a
real distro installer (e.g. one that is not tailored specifically for
Pinebook Pro). However some problems are so ackward for users the
following temporary hacks have been tolerated.

* The ALSA state cache is [pre-configured](var/lib/alsa/asound.state).
  This ensured that audio will work out-of-the-box. This is temporary
  until upstream ALSA UCM support for Pinebook Pro is added.
* The kernel is booted with `maxcpus=4` to ensure that is does not use
  the Cortex A72 cores during initialization. This works around a
  bootloader problem that hands these cores to the kernel with clock
  speed set so slow that it compromises boot times. The disabled cores
  will be re-enabled later in the boot process. Warning: 
  *To make the `maxcpus=4` hack work, some optional kernel hardening
  features must be disabled (ex:
  [`HARDEN_EL2_VECTORS`](https://lists.cs.columbia.edu/pipermail/kvmarm/2018-March/030321.html))*
