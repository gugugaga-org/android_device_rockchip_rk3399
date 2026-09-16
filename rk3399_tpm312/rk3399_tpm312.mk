#
# Copyright 2014 The Android Open-Source Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# First lunching is S, api_level is 31
PRODUCT_SHIPPING_API_LEVEL := 31
PRODUCT_DTBO_TEMPLATE := $(LOCAL_PATH)/dt-overlay.in
PRODUCT_BOOT_DEVICE := fe330000.sdhci

# Strip the bundled Rockchip factory/media apps and the AOSP Music/Gallery2
# stubs from the image; the makefiles that add them check this switch.
TPM312_REMOVE_BUNDLED_APPS := true

include device/rockchip/common/build/rockchip/DynamicPartitions.mk
include device/rockchip/rk3399/rk3399_tpm312/BoardConfig.mk
include device/rockchip/common/BoardConfig.mk

# KernelSU is for the development/userdebug image only. Keep the production
# user build eligible for Google certification by omitting the root feature.
ifneq ($(TARGET_BUILD_VARIANT),user)
PRODUCT_KERNEL_CONFIG += tpm312_kernelsu.config
endif

$(call inherit-product, $(SRC_TARGET_DIR)/product/full_base.mk)
# Inherit from those products. Most specific first.
$(call inherit-product, device/rockchip/rk3399/device.mk)
$(call inherit-product, device/rockchip/common/device.mk)
$(call inherit-product, vendor/mtgapps/mtgapps.mk)

PRODUCT_CHARACTERISTICS := tv

PRODUCT_NAME := rk3399_tpm312
PRODUCT_DEVICE := rk3399_tpm312
PRODUCT_BRAND := rockchip
PRODUCT_MODEL := TPM312
PRODUCT_MANUFACTURER := rockchip
PRODUCT_AAPT_PREF_CONFIG := hdpi

# ViPER4Android RE (legacy HIDL effect): driver .so into /vendor/lib*/soundfx,
# official control app as product priv-app. audio_effects.xml carries the
# v4a_re library / v4a_standard_re effect entries.
PRODUCT_PACKAGES += \
    libv4a_re \
    ViPER4Android

# The official APK declares <uses-library-not-required> for androidx.window
# libraries that are optional at runtime. Relax the build-time uses-library
# verification (the app is dexpreopt-disabled, so this only silences the check).
PRODUCT_BROKEN_VERIFY_USES_LIBRARIES := true

PRODUCT_COPY_FILES += \
    device/rockchip/rk3399/rk3399_tpm312/viper/privapp-permissions-viper.xml:$(TARGET_COPY_OUT_PRODUCT)/etc/permissions/privapp-permissions-viper.xml

# Get the long list of APNs
PRODUCT_COPY_FILES += vendor/rockchip/common/phone/etc/apns-full-conf.xml:system/etc/apns-conf.xml
PRODUCT_COPY_FILES += vendor/rockchip/common/phone/etc/spn-conf.xml:system/etc/spn-conf.xml

# RTL8821CU firmware (WiFi + BT share the same RTL8821C firmware files):
#  - /vendor/etc/firmware: kernel WiFi driver (firmware_class.path)
#  - /vendor/firmware:     userspace Realtek BT vendor library
PRODUCT_COPY_FILES += \
    device/rockchip/rk3399/rk3399_tpm312/firmware/rtl8821c_fw:$(TARGET_COPY_OUT_VENDOR)/etc/firmware/rtl8821c_fw \
    device/rockchip/rk3399/rk3399_tpm312/firmware/rtl8821c_config:$(TARGET_COPY_OUT_VENDOR)/etc/firmware/rtl8821c_config \
    device/rockchip/rk3399/rk3399_tpm312/firmware/rtl8821c_fw:$(TARGET_COPY_OUT_VENDOR)/firmware/rtl8821c_fw \
    device/rockchip/rk3399/rk3399_tpm312/firmware/rtl8821c_config:$(TARGET_COPY_OUT_VENDOR)/firmware/rtl8821c_config

# YICHIP (3151:3020) USB remote: its OK key reports KEY_ENTER (28) but
# Android TV expects DPAD_CENTER (23) for select, so ship a per-device keylayout.
PRODUCT_COPY_FILES += \
    device/rockchip/rk3399/rk3399_tpm312/remote_config/Vendor_3151_Product_3020.kl:$(TARGET_COPY_OUT_VENDOR)/usr/keylayout/Vendor_3151_Product_3020.kl

PRODUCT_PROPERTY_OVERRIDES += \
    ro.product.version = 1.0.0 \
    ro.product.ota.host = 192.168.1.1:8888 \
    ro.sf.lcd_density=240 \
    vendor.gralloc.no_afbc_for_fb_target_layer=1 \
    vendor.hwc.device.primary=HDMI-A

# HDMI is the only output and is always the primary display. hw_output (the
# HDMI settings HIDL HAL) selects persist.vendor.resolution.main vs .aux from
# this property when vendor.ghwc.version is not HWC2; without it every mode
# selected in Settings was written to persist.vendor.resolution.aux while HWC1
# kept applying .main=Auto, so resolution changes never took effect.
