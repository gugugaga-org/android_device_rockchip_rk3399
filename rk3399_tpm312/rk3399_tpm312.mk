# TPM312 product for LineageOS 21 (Android 14).
#
# Android TV GApps are selected through Lineage's standard WITH_GMS switch.
# The MindTheGapps tree is an external manifest project and remains outside
# this device repository.

PRODUCT_SHIPPING_API_LEVEL := 34
PRODUCT_DTBO_TEMPLATE := $(LOCAL_PATH)/dt-overlay.in
PRODUCT_BOOT_DEVICE := fe330000.sdhci

include device/rockchip/common/build/rockchip/DynamicPartitions.mk
include device/rockchip/rk3399/rk3399_tpm312/BoardConfig.mk
include device/rockchip/common/BoardConfig.mk

# The shared Android 14 Rockchip BoardConfig enables the HWC3 AIDL path, but
# RK3399's Android 14 graphics stack still supplies the legacy HWC2 service
# together with hwcomposer.rk30board.so.  There is no
# android.hardware.graphics.composer3-service.rockchip module in this source
# tree, so leave HWC3 disabled for TPM312 or SurfaceFlinger has no composer
# service to connect to and aborts during early boot.
TARGET_USES_HWC3_AIDL := false

# The common BoardConfig resets these vendor selectors to the Rockchip
# auto-HAL defaults, so keep the board-specific Realtek selection after it.
BOARD_WIFI_VENDOR := realtek
BOARD_WLAN_DEVICE := realtek
# RTL8821CU is an nl80211 USB driver.  The legacy Realtek private-command
# library is not needed by it and causes an Android 13 CFI indirect-call abort
# when the AIDL supplicant handles setCountryCode.
BOARD_WPA_SUPPLICANT_PRIVATE_LIB :=
BOARD_HOSTAPD_PRIVATE_LIB := lib_driver_cmd_rtl
# Prevent the common Rockchip product from copying its legacy HIDL
# init.connectivity.rc. The AIDL wpa_supplicant service rc below must be the
# only definition of the wpa_supplicant service name.
BOARD_CONNECTIVITY_VENDOR := RealTek
# The Android 13 wpa_supplicant binary is built with the AIDL service, while
# the common Rockchip init file still describes only the legacy HIDL entry.
# Ask the wpa_supplicant module to install its unified AIDL service rc so the
# framework can start the interface advertised by its VINTF fragment.
WIFI_HIDL_UNIFIED_SUPPLICANT_SERVICE_RC_ENTRY := true
# Keep the common Bluetooth/WiFi setup actions while replacing only its
# legacy HIDL wpa_supplicant service definition with the AIDL service above.
PRODUCT_COPY_FILES += \
    device/rockchip/rk3399/rk3399_tpm312/init.connectivity.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/hw/init.connectivity.rc
# AIDL supplicant creates its persistent STA config from this vendor template.
# The legacy Rockchip Android.mk that generated this file is not part of the
# LineageOS 20 product graph, so install the upstream template explicitly.
PRODUCT_COPY_FILES += \
    external/wpa_supplicant_8/wpa_supplicant/wpa_supplicant_template.conf:$(TARGET_COPY_OUT_VENDOR)/etc/wifi/wpa_supplicant.conf
# The generic WiFi HAL must load the out-of-tree USB module explicitly.  The
# Realtek driver loads rtl8821c firmware itself, so suppress the Broadcom
# firmware-mode paths inherited from device/rockchip/common.
WIFI_DRIVER_MODULE_PATH := /vendor/lib/modules/8821cu.ko
WIFI_DRIVER_MODULE_NAME := 8821cu
WIFI_DRIVER_FW_PATH_STA := /dev/null
WIFI_DRIVER_FW_PATH_AP := /dev/null
WIFI_DRIVER_FW_PATH_P2P := /dev/null
WIFI_DRIVER_FW_PATH_PARAM := /dev/null
# Android 14 builds libwifi-hal-common from Android.bp. Export the two
# device-specific loader values through Soong without changing the generic
# WiFi framework defaults for other boards.
SOONG_CONFIG_NAMESPACES += tpm312Wifi
SOONG_CONFIG_tpm312Wifi += driver_module_path driver_module_name
SOONG_CONFIG_tpm312Wifi_driver_module_path := $(WIFI_DRIVER_MODULE_PATH)
SOONG_CONFIG_tpm312Wifi_driver_module_name := $(WIFI_DRIVER_MODULE_NAME)
PRODUCT_CFI_INCLUDE_PATHS := $(filter-out hardware/rockchip/wifi/wpa_supplicant_8_lib,$(PRODUCT_CFI_INCLUDE_PATHS))
# rktoolbox includes an Android 12 prebuilt dr-g with stale system-library
# dependencies; it is not required for the initial Android 13 bring-up.
BOARD_WITH_RKTOOLBOX := false

# LineageOS/AOSP 64-bit userspace with the 32-bit secondary ABI supplied by
# the RK3399 BoardConfig.
$(call inherit-product, device/google/atv/products/atv_base.mk)
# Keep this as the only product-level GApps switch. vendor/lineage's
# partner_gms.mk resolves WITH_GMS to vendor/gapps_tv for this manifest.
WITH_GMS ?= true
$(call inherit-product, vendor/lineage/config/common_full_tv.mk)

# KernelSU Manager is independent of GApps and has no second GApps switch.
# WITH_GMS only selects the MindTheGapps Android TV package above.
$(call inherit-product, vendor/mtgapps/mtgapps.mk)

# The stock Lineage TV wizard starts with Bluetooth accessory discovery.  TPM312
# has no bundled Bluetooth remote, so replace only the wizard script through a
# device overlay and begin with the normal welcome page.  The Bluetooth setup
# activity remains available from TV Settings after provisioning.
TPM312_SETUPWIZARD_OVERLAY := device/rockchip/rk3399/rk3399_tpm312/overlay
PRODUCT_PACKAGE_OVERLAYS += $(TPM312_SETUPWIZARD_OVERLAY)
PRODUCT_ENFORCE_RRO_EXCLUDED_OVERLAYS += $(TPM312_SETUPWIZARD_OVERLAY)

# Rockchip's Android 14 BSP projects are the hardware donor for this port.
# TPM312 compatibility fixes are kept in project-local commits.
$(call inherit-product, device/rockchip/rk3399/device.mk)
$(call inherit-product, device/rockchip/common/device.mk)

# The common Rockchip configuration unconditionally selects the Broadcom
# vendor library for its generic connectivity defaults.  TPM312 has a USB
# RTL8821CU; use the Realtek implementation as the HIDL default
# libbt-vendor.so and do not retain its differently-named staging module.
BOARD_HAVE_BLUETOOTH_BCM := false
BOARD_HAVE_BLUETOOTH_AIC :=
BOARD_HAVE_BLUETOOTH_SEEKWAVE :=

# Keep the RK3399 UART visible during the handoff from U-Boot to Linux.  This
# is board-local diagnostic configuration and makes early kernel failures
# distinguishable from an Android ramdisk failure.
BOARD_KERNEL_CMDLINE += earlycon=uart8250,mmio32,0xff1a0000

# The Android 14 WiFi stack uses AIDL hostapd/supplicant and HIDL WiFi 1.6.
# They are valid for this Android 12-origin device but are not listed in FCM 6,
# so declare them in a board-specific framework compatibility matrix.
DEVICE_FRAMEWORK_COMPATIBILITY_MATRIX_FILE += \
    device/rockchip/rk3399/rk3399_tpm312/compatibility_matrix.xml

PRODUCT_CHARACTERISTICS := tv

# The lineage_ prefix makes envsetup export LINEAGE_BUILD and enables the
# Lineage board/configuration hooks for this product.
PRODUCT_NAME := lineage_rk3399_tpm312
PRODUCT_DEVICE := rk3399_tpm312
PRODUCT_BRAND := rockchip
PRODUCT_MODEL := TPM312
PRODUCT_MANUFACTURER := rockchip
PRODUCT_AAPT_PREF_CONFIG := hdpi

# Get the long list of APNs when present in the Rockchip vendor project.
PRODUCT_COPY_FILES += \
    vendor/rockchip/common/phone/etc/apns-full-conf.xml:system/etc/apns-conf.xml \
    vendor/rockchip/common/phone/etc/spn-conf.xml:system/etc/spn-conf.xml

# RTL8821CU firmware (WiFi + BT share the same RTL8821C firmware files).
PRODUCT_COPY_FILES += \
    device/rockchip/rk3399/rk3399_tpm312/firmware/rtl8821c_fw:$(TARGET_COPY_OUT_VENDOR)/etc/firmware/rtl8821c_fw \
    device/rockchip/rk3399/rk3399_tpm312/firmware/rtl8821c_config:$(TARGET_COPY_OUT_VENDOR)/etc/firmware/rtl8821c_config \
    device/rockchip/rk3399/rk3399_tpm312/firmware/rtl8821c_fw:$(TARGET_COPY_OUT_VENDOR)/firmware/rtl8821c_fw \
    device/rockchip/rk3399/rk3399_tpm312/firmware/rtl8821c_config:$(TARGET_COPY_OUT_VENDOR)/firmware/rtl8821c_config

# The stock HAL stores the Bluetooth address under /data, which disappears
# after a userdata wipe. Keep the known board address in vendor instead so
# the HAL can initialize before userdata is populated.
PRODUCT_COPY_FILES += \
    device/rockchip/rk3399/rk3399_tpm312/bluetooth/bdaddr:$(TARGET_COPY_OUT_VENDOR)/etc/bluetooth/bdaddr
PRODUCT_VENDOR_PROPERTIES += ro.bt.bdaddr_path=/vendor/etc/bluetooth/bdaddr

# YICHIP (3151:3020) USB remote: map its OK key to DPAD_CENTER for Android TV.
PRODUCT_COPY_FILES += \
    device/rockchip/rk3399/rk3399_tpm312/remote_config/Vendor_3151_Product_3020.kl:$(TARGET_COPY_OUT_VENDOR)/usr/keylayout/Vendor_3151_Product_3020.kl

PRODUCT_PROPERTY_OVERRIDES += \
    ro.product.version=1.0.0 \
    ro.product.ota.host=192.168.1.1:8888 \
    ro.sf.lcd_density=240 \
    vendor.gralloc.no_afbc_for_fb_target_layer=1

# The common Rockchip property block is skipped for TPM312 by the overlay
# patch, so this remains the only screen-off assignment for the product.
PRODUCT_PROPERTY_OVERRIDES += ro.rk.screenoff_time=2147483647
