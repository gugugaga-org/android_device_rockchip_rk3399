#
# TPM312 (RK3399) board config
#
# Product form: TV box (HDMI only), based on public Android 12 BSP
# (TinkerBoard-Android android12-rockchip, kernel 4.19.232).
#
# Must be set before including the SoC/common BoardConfig so that the
# Rockchip product-type detection does not default to "tablet".
TARGET_BOARD_PLATFORM_PRODUCT := box

include device/rockchip/rk3399/BoardConfig.mk
# Rockchip vendor policy owns the fuseblk label used by this BSP.
TARGET_HAS_FUSEBLK_SEPOLICY_ON_VENDOR := true
BOARD_SEPOLICY_M4DEFS += board_excludes_fuseblk_sepolicy=true

# TPM312 uses the public Realtek HAL for its RTL8821CU USB combo.
BOARD_WIFI_VENDOR := realtek

# Recovery: AOSP recovery (this BSP does not ship TWRP sources; the
# twrp.mk module only sets TW_* flags). TWRP can be integrated later by
# switching bootable/recovery to the TWRP android-12.1 branch.
BOARD_TWRP_ENABLE := false
TARGET_RECOVERY_FSTAB := device/rockchip/rk3399/rk3399_tpm312/recovery.fstab

# Kernel / U-Boot
DEVICE_MANIFEST_FILE := device/rockchip/rk3399/rk3399_tpm312/manifest.xml
# LineageOS builds the kernel from the repo-managed source checkout rather than
# consuming the Rockchip BSP's prebuilt kernel path.
# Use the Android 13 Rockchip Gralloc 4 path for RK3399's Midgard stack.
TARGET_RK_GRALLOC_VERSION := 4
TARGET_KERNEL_SOURCE := kernel/rockchip/rk3399
PRODUCT_KERNEL_PATH := kernel/rockchip/rk3399
TARGET_KERNEL_CONFIG := rockchip_defconfig
TARGET_KERNEL_DTB := rockchip/rk3399-tpm312.dtb
BOARD_KERNEL_IMAGE_NAME := Image

# device/rockchip/common/BoardConfig.mk uses ?= for the BSP prebuilt paths.
# Define them as empty here so the Lineage kernel task owns these outputs.
TARGET_PREBUILT_KERNEL :=
BOARD_PREBUILT_DTBIMAGE_DIR :=

# Keep the Rockchip build variables for its packaging scripts and fstab logic.
PRODUCT_KERNEL_DTS := rk3399-tpm312
PRODUCT_UBOOT_CONFIG := rk3399

# Keep the Rockchip resource image in the device tree. It carries the board
# DTB and charge logos required by the non-A/B header-v2 boot flow.
TARGET_PREBUILT_RESOURCE := device/rockchip/rk3399/rk3399_tpm312/resource.img

# Board has no touch panel / sensors / camera
BOARD_SENSOR_ST := false
BOARD_SENSOR_COMPASS_AK8963-64 := false
BOARD_SENSOR_MPU_PAD := false
BOARD_COMPASS_SENSOR_SUPPORT := false
BOARD_GYROSCOPE_SENSOR_SUPPORT := false
BOARD_CAMERA_SUPPORT := false
BOARD_CAMERA_SUPPORT_EXT := false
CAMERA_SUPPORT_AUTOFOCUS := false

# Non A/B, dynamic partitions (super)
BOARD_USES_AB_IMAGE := false
BOARD_ROCKCHIP_VIRTUAL_AB_ENABLE := false
BOARD_HAS_RK_4G_MODEM := false

# WiFi/BT: Realtek RTL8821CU (USB combo, RTL8821C WiFi + USB BT)
#
# Do not set BOARD_WLAN_DEVICE/BOARD_WIFI_VENDOR here: this BSP uses the
# generic "auto" WiFi HAL (libwifi-hal-auto), which selects the vendor HAL
# (libwifi-hal-rtk.so) at runtime from the USB/SDIO chip ID. RTL8821CU is
# recognized via the rk_wifi_ctrl.cpp patch.
BOARD_CONNECTIVITY_MODULE := rtl8821cu

# HDMI landscape
SF_PRIMARY_DISPLAY_ORIENTATION := 0

# No HDMI CEC on this box: keep the common device.mk from installing the
# CEC feature xml (HdmiControlService would NPE-crash system_server when
# FEATURE_HDMI_CEC is present without a working CEC HAL) and the Rockchip
# CEC HAL/service (no VINTF declaration, registers fail, init restart loop).
BOARD_HAVE_HDMI_CEC := false

# The common Rockchip connectivity defaults enable the Broadcom vendor
# library while setting up the generic Rockchip backend.  TPM312 has a USB
# RTL8821CU and uses hardware/realtek/rtkbt instead; disable Broadcom before
# legacy Android.mk modules are registered.
BOARD_HAVE_BLUETOOTH_BCM :=
