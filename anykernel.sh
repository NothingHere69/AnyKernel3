### AnyKernel3 Ramdisk Mod Script
## osm0sis @ xda-developers

### AnyKernel setup
# global properties
properties() { '
kernel.string=BEAST KERNEL | POCO X3/NFC
do.devicecheck=1
do.modules=0
do.systemless=1
do.cleanup=1
do.cleanuponabort=1
device.name1=surya
device.name2=karna
supported.versions=11-16
'; } # end properties


### AnyKernel install
## boot files attributes
boot_attributes() {
set_perm_recursive 0 0 755 644 $RAMDISK/*;
set_perm_recursive 0 0 750 750 $RAMDISK/init* $RAMDISK/sbin;
} # end attributes

# begin passthrough patch
passthrough() {
if [ ! "$(getprop persist.sys.fuse.passthrough.enable)" ]; then
	ui_print "Remounting /system as rw..."
	$home/tools/busybox mount -o rw,remount /system
	ui_print "Patching system's build prop for FUSE Passthrough..."
	patch_prop /system/build.prop "persist.sys.fuse.passthrough.enable" "true"
fi
} # end passthrough patch

# boot shell variables
BLOCK=/dev/block/bootdevice/by-name/boot;
IS_SLOT_DEVICE=0;
RAMDISK_COMPRESSION=auto;
PATCH_VBMETA_FLAG=auto;

# import functions/variables and setup patching - see for reference (DO NOT REMOVE)
. tools/ak3-core.sh && passthrough;

# boot install
dump_boot; # use split_boot to skip ramdisk unpack, e.g. for devices with init_boot ramdisk

# handle legacy bootargs
sdk=$(getprop ro.build.version.sdk)
[ "$sdk" -lt 36 ] && patch_cmdline init.is_legacy_ebpf= init.is_legacy_ebpf=1
[ "$sdk" -lt 33 ] && patch_cmdline init.is_legacy_timestamp= init.is_legacy_timestamp=1

write_boot; # use flash_boot to skip ramdisk repack, e.g. for devices with init_boot ramdisk
## end boot install
