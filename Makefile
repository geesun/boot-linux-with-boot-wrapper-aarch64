DIR=`pwd`
CROSS_COMPILE=$(DIR)/gcc-arm-10.3-2021.07-x86_64-aarch64-none-linux-gnu/bin/aarch64-none-linux-gnu-
CC=$(CROSS_COMPILE)gcc 
LD=$(CROSS_COMPILE)ld

download.boot:
	git clone git://git.kernel.org/pub/scm/linux/kernel/git/mark/boot-wrapper-aarch64.git

download.linux:
	git clone git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git

download.fvp: 
	wget https://developer.arm.com/-/media/Files/downloads/ecosystem-models/FVP_Base_RevC-2xAEMvA_11.16_16.tgz
	tar -zxvf FVP_Base_RevC-2xAEMvA_11.16_16.tgz

download.gcc:
	wget https://developer.arm.com/-/media/Files/downloads/gnu-a/10.3-2021.07/binrel/gcc-arm-10.3-2021.07-x86_64-aarch64-none-linux-gnu.tar.xz
	tar -xvf gcc-arm-10.3-2021.07-x86_64-aarch64-none-linux-gnu.tar.xz

cfg.linux:
	make -C linux ARCH=arm64 defconfig CROSS_COMPILE=$(CROSS_COMPILE)

build.linux:linux
	make -C linux  ARCH=arm64 -j 24 Image CROSS_COMPILE=$(CROSS_COMPILE)  Image dtbs
	
cfg.boot:boot-wrapper-aarch64
	cd boot-wrapper-aarch64 &&  autoreconf -i

build.boot:boot-wrapper-aarch64
	cd boot-wrapper-aarch64 && ./configure --enable-psci --enable-gicv3 \
		--with-kernel-dir=../linux \
		--with-dtb=../linux/arch/arm64/boot/dts/arm/fvp-base-revc.dtb \
		--host=aarch64-none-linux-gnu  \
		--with-cmdline="console=ttyAMA0 earlycon=pl011,0x1c090000 root=/dev/vda1 rw ip=dhcp debug user_debug=31 loglevel=9"
	make -C boot-wrapper-aarch64 CC=$(CC) LD=$(LD)

build.rootfs:
	mkdir tmp -p && cd tmp  && tar -jxvf ../rootfs.tar.bz2 
	cd tmp && ../gen-rootfs
	rm -rf tmp 
	
run:
	Base_RevC_AEMvA_pkg/models/Linux64_GCC-6.4/FVP_Base_RevC-2xAEMvA \
		-C cluster0.NUM_CORES=4 -C cluster1.NUM_CORES=4  \
		-C cluster0.has_arm_v8-3=1 -C cluster1.has_arm_v8-3=1 \
		-C cluster0.has_arm_v8-5=1 -C cluster1.has_arm_v8-5=1 \
		-C cluster0.has_branch_target_exception=1 -C cluster1.has_branch_target_exception=1 \
		-C cache_state_modelled=0 \
		-C pctl.startup=0.0.0.0 \
		-C bp.secure_memory=false \
		-C bp.refcounter.non_arch_start_at_default=1 \
		boot-wrapper-aarch64/linux-system.axf \
		-C bp.ve_sysregs.mmbSiteDefault=0 \
		-C bp.ve_sysregs.exit_on_shutdown=1  \
		-C bp.virtioblockdevice.image_path=grub-busybox.img
