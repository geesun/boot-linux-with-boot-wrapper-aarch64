# boot-linux
Boot Linux Kernel with boot-wrapper-aarch64 with Arm FVP Base_RevC_AEMvA

## Download
make download.fvp     # Download FVP 
make download.gcc     # Download toolchain
make download.linux   # Download the Linux source
make download.boot    # Download the boot-wrapper-aarch64 source

## Configure 
make cfg.linux        # Configure linux kernel 
make cfg.boot         # Congigure boot-wrapper-aarch64

## Build 
make build.linux      # Build Linux kernel 
make build.boot       # Build boot-wrapper-aarch64
make build.rootfs     # Build the rootfs 

## Run FVP 
make run              # Run FVP 
