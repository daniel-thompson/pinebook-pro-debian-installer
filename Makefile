MMCBLK ?= /dev/mmcblk1

CHROOT = LANG=C sudo chroot $(PWD)/sysimage
SYSIMAGE = $(PWD)/sysimage
KERNELPKG = linux-image-5.4.0-20191129-1-tsys+_5.4.0-20191129-1-tsys+-1_arm64.deb
KERNELURL = https://github.com/daniel-thompson/linux/releases/download/v5.4.0-20191129-1-tsys%2B/$(KERNELPKG)
STEPS = prep partition u-boot mkfs mount debootstrap mount2 kernel firmware configure umount

all : $(STEPS)
.PHONY: $(STEPS)

prep :
	git submodule update --init
	sudo apt install debootstrap

#
# Use sfdisk to write a pre-prepared partition table.
#
# Currently the partition table is pre-configured for a 64GB device.
#
# TODO: Automatically choose the size of the last partition. Find the
#       dimensions of the disk using:
#       lsblk $(MMCBLK) --noheadings --bytes --output SIZE | head -1
#
partition :
	@printf '\n\n>>>> $@\n\n'
	sudo sfdisk $(MMCBLK) < gpt.sfdisk

#
# Write the system firmware to the required partitions.
#
u-boot :
	@printf '\n\n>>>> $@\n\n'
	sudo dd if=bootloader/pinebook/filesystem/idbloader.img \
		of=$(MMCBLK)p1 bs=4096
	sudo dd if=bootloader/pinebook/filesystem/uboot.img \
		of=$(MMCBLK)p1 bs=4096
	sudo dd if=bootloader/pinebook/filesystem/trust.img \
		of=$(MMCBLK)p1 bs=4096

#
# Create the three filesystems.
#
# Currently the EFI filesystem is unused but it included here since it
# will be useful in the future when we enable EFI support in u-boot.
#
mkfs :
	@printf '\n\n>>>> $@\n\n'
	sudo mkfs.vfat -n EFI -F 32 $(MMCBLK)p4
	sudo mkfs.ext4 -FL Boot $(MMCBLK)p5
	sudo mkfs.ext4 -FL RootFS $(MMCBLK)p6

mount :
	@printf '\n\n>>>> $@\n\n'
	mkdir -p $(SYSIMAGE)
	sudo mount $(MMCBLK)p6 $(SYSIMAGE)
	sudo mkdir -p $(SYSIMAGE)/boot
	sudo mount $(MMCBLK)p5 $(SYSIMAGE)/boot
	sudo mkdir -p $(SYSIMAGE)/boot/efi
	sudo mount $(MMCBLK)p4 $(SYSIMAGE)/boot/efi

#
# Construct a minimal Debian root image
# 
# Strictly speaking we are not fully minimal because we add some packages to
# handle keyboard mappings, networking (including remote login) and kernel
# updates.
#
debootstrap : debootstrap.tar.gz
	@printf '\n\n>>>> $@\n\n'
	sudo tar -C $(SYSIMAGE) -xf debootstrap.tar.gz
	sudo fallocate -l 2g $(SYSIMAGE)/swapfile
	sudo mkswap $(SYSIMAGE)/swapfile
	sudo install etc/fstab $(SYSIMAGE)/etc/fstab
	sudo install etc/tmpfiles.d/* $(SYSIMAGE)/etc/tmpfiles.d
	sudo install etc/apt/sources.list $(SYSIMAGE)/etc/apt/sources.list

debootstrap.tar.gz :
	sudo debootstrap \
		--include ca-certificates,console-setup,initramfs-tools,locales,keyboard-configuration,network-manager,sudo,u-boot-menu \
		bullseye $(SYSIMAGE)
	sudo tar -C $(SYSIMAGE) -cf - . | pigz -9c > $@

mount2 :
	@printf '\n\n>>>> $@\n\n'
	for i in dev proc sys; \
	do \
		sudo mkdir -p $(SYSIMAGE)/$$i; \
		sudo mount --bind /$$i $(SYSIMAGE)/$$i; \
	done

#
# We configure /etc/default/u-boot prior to installing the kernel since
# that means debian will automatically generate an extlinux.conf for us.
# 
# Note that we have to create a dummy DT file (rk3399-pinebook-pro.dtb) 
# since the u-boot integration will not include this in extlinux.conf 
# if it does not exist... and we don't have a real one until we have copied
# it from the kernel image.
# 
kernel : kernel/$(KERNELPKG)
	@printf '\n\n>>>> $@\n\n'
	cat etc/default/u-boot.append | sudo tee -a $(SYSIMAGE)/etc/default/u-boot > /dev/null
	cat etc/initramfs-tools/modules.append | sudo tee -a $(SYSIMAGE)/etc/initramfs-tools/modules > /dev/null
	sudo install etc/initramfs-tools/conf.d/* $(SYSIMAGE)/etc/initramfs-tools/conf.d/
	sudo cp kernel/$(KERNELPKG) $(SYSIMAGE)/root
	sudo touch $(SYSIMAGE)/boot/rk3399-pinebook-pro.dtb
	$(CHROOT) dpkg --add-architecture arm64
	$(CHROOT) apt install /root/$(KERNELPKG)
	sudo cp $(SYSIMAGE)/usr/lib/linux-image-*/rockchip/rk3399-pinebook-pro.dtb $(SYSIMAGE)/boot

kernel/$(KERNELPKG) :
	mkdir -p kernel/
	wget -O kernel/$(KERNELPKG) $(KERNELURL)

firmware :
	@printf '\n\n>>>> $@\n\n'
	sudo mkdir -p $(SYSIMAGE)/lib/firmware
	sudo cp -a firmware/brcm $(SYSIMAGE)/lib/firmware
	sudo mkdir -p $(SYSIMAGE)/lib/firmware

configure :
	@printf '\n\n>>>> $@\n\n'
	@read -p "About to create main user, please enter username: " NEWUSER; \
	    $(CHROOT) adduser --add_extra_groups $$NEWUSER; \
	    $(CHROOT) adduser $$NEWUSER sudo
	$(CHROOT) dpkg-reconfigure keyboard-configuration
	$(CHROOT) dpkg-reconfigure locales
	$(CHROOT) dpkg-reconfigure tzdata
	$(CHROOT) tasksel

umount :
	@printf '\n\n>>>> $@\n\n'
	-for i in boot/efi boot dev proc sys; \
	do \
		sudo umount $(SYSIMAGE)/$$i; \
	done
	sudo umount $(SYSIMAGE)

clean :
	$(RM) -r debootstrap.tar.gz kernel
