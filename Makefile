SRC_DIR 		:= $(shell pwd)/src
TOOLS_DIR 		:= $(shell pwd)/tools
CROSS_COMPILE 	:= $(TOOLS_DIR)/arm-gnu-toolchain-13.2.Rel1-x86_64-aarch64-none-linux-gnu/bin/aarch64-none-linux-gnu-
CC 				:= $(CROSS_COMPILE)gcc
LD 				:= $(CROSS_COMPILE)ld
FVP_BASE 	    := $(TOOLS_DIR)/Base_RevC_AEMvA_pkg/models/Linux64_GCC-9.3/FVP_Base_RevC-2xAEMvA
LINUX_AXF 		:= $(SRC_DIR)/boot-wrapper-aarch64/linux-system.axf
GRUB_BUSYBOX_IMG := $(shell pwd)/rootfs/grub-busybox.img

FVP_OPTIONS 	:= \
	-C cluster0.NUM_CORES=4 -C cluster1.NUM_CORES=4 \
	-C cluster0.has_arm_v8-3=1 -C cluster1.has_arm_v8-3=1 \
	-C cluster0.has_arm_v8-5=1 -C cluster1.has_arm_v8-5=1 \
	-C cluster0.has_branch_target_exception=1 -C cluster1.has_branch_target_exception=1 \
	-C cache_state_modelled=0 \
	-C pctl.startup=0.0.0.0 \
	-C bp.secure_memory=false \
	-C bp.refcounter.non_arch_start_at_default=1 \
	-C bp.ve_sysregs.mmbSiteDefault=0 \
	-C bp.ve_sysregs.exit_on_shutdown=1 \
	-C bp.terminal_3.terminal_command="tmux split-window -d telnet localhost %port" \
	-C bp.terminal_0.terminal_command="tmux split-window -h telnet localhost %port" \
	-C bp.virtioblockdevice.image_path=$(GRUB_BUSYBOX_IMG) \
	$(LINUX_AXF)

DEBUG_OPTIONS 	:= $(subst ",\",$(FVP_OPTIONS)) -I -p

.PHONY: all clone download config build run debug clean fs

all: clone download config build buildfs

clone:
	@ mkdir -p $(SRC_DIR)
	@ [ -d "$(SRC_DIR)/boot-wrapper-aarch64" ] || git clone git://git.kernel.org/pub/scm/linux/kernel/git/mark/boot-wrapper-aarch64.git $(SRC_DIR)/boot-wrapper-aarch64
	@ [ -d "$(SRC_DIR)/linux" ] || git clone git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git $(SRC_DIR)/linux

download:
	@ mkdir -p $(TOOLS_DIR)
	@ [ -f "$(TOOLS_DIR)/FVP_Base_RevC-2xAEMvA_11.25_15_Linux64.tgz" ] || wget -P $(TOOLS_DIR) https://armkeil.blob.core.windows.net/developer/Files/downloads/ecosystem-models/FM_11_25/FVP_Base_RevC-2xAEMvA_11.25_15_Linux64.tgz
	@ [ -f "$(TOOLS_DIR)/arm-gnu-toolchain-13.2.rel1-x86_64-aarch64-none-linux-gnu.tar.xz" ] || wget -P $(TOOLS_DIR) https://developer.arm.com/-/media/Files/downloads/gnu/13.2.rel1/binrel/arm-gnu-toolchain-13.2.rel1-x86_64-aarch64-none-linux-gnu.tar.xz
	@ [ -d "$(TOOLS_DIR)/Base_RevC_AEMvA_pkg" ] || tar -C $(TOOLS_DIR) -zxvf $(TOOLS_DIR)/FVP_Base_RevC-2xAEMvA_11.25_15_Linux64.tgz
	@ [ -d "$(TOOLS_DIR)/arm-gnu-toolchain-13.2.Rel1-x86_64-aarch64-none-linux-gnu" ] || tar -C $(TOOLS_DIR) -xvf $(TOOLS_DIR)/arm-gnu-toolchain-13.2.rel1-x86_64-aarch64-none-linux-gnu.tar.xz

config: clone download
	make -C $(SRC_DIR)/linux ARCH=arm64 defconfig CROSS_COMPILE=$(CROSS_COMPILE)
	cd $(SRC_DIR)/boot-wrapper-aarch64 && autoreconf -i 

build: config 
	make -C $(SRC_DIR)/linux ARCH=arm64 -j 24 Image CROSS_COMPILE=$(CROSS_COMPILE) Image dtbs
	cd $(SRC_DIR)/boot-wrapper-aarch64 && ./configure --enable-psci --enable-gicv3 \
		--with-kernel-dir=../linux \
		--with-dtb=../linux/arch/arm64/boot/dts/arm/fvp-base-revc.dtb \
		--host=aarch64-none-linux-gnu \
		--with-cmdline="console=ttyAMA0 earlycon=pl011,0x1c090000 root=/dev/vda1 rw ip=dhcp debug user_debug=31 loglevel=9"
	make -C $(SRC_DIR)/boot-wrapper-aarch64 CC=$(CC) LD=$(LD)

buildfs:
	mkdir -p rootfs/tmp -p && cd rootfs/tmp && tar -jxvf ../rootfs.tar.bz2
	cd rootfs/tmp && ../gen-rootfs
	rm -rf rootfs/tmp

run:
	$(FVP_BASE) $(FVP_OPTIONS)

debug:
	/opt/arm/developmentstudio_platinum-0.a/bin/armdbg \
		--cdb-entry="Imported::FVP_Base_RevC_2xAEMvA::Bare Metal Debug::Bare Metal Debug::ARM_AEM-A_MPx4 SMP Cluster 0" \
		--cdb-root ~/developmentstudio-workspace/RevC \
		-cdb-entry-param model_params="$(DEBUG_OPTIONS)" -s ap.ds --interactive

clean:
	rm -rf $(GRUB_BUSYBOX_IMG)
	make -C $(SRC_DIR)/linux ARCH=arm64 clean 
	make -C $(SRC_DIR)/boot-wrapper-aarch64 clean 

distclean:
	rm -rf $(SRC_DIR) $(TOOLS_DIR)


