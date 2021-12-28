# boot-linux
Boot Linux Kernel with boot-wrapper-aarch64 with Arm FVP Base_RevC_AEMvA

## Download
### Download FVP 
```
make download.fvp    
```
### Download toolchain
```
make download.gcc     
```

### Download the Linux source
```
make download.linux   
```

### Download the boot-wrapper-aarch64 source
```
make download.boot    
```

## Configure
### Configure linux kernel 
```
make cfg.linux        
```

### Congigure boot-wrapper-aarch64
```
make cfg.boot         
```

## Build 
### Build Linux kernel 
```
make build.linux      
```

### Build boot-wrapper-aarch64
```
make build.boot       
```

### Build the rootfs 
```
make build.rootfs     
```

## Run FVP 
```
make run              
```
