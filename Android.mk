LOCAL_PATH := $(call my-dir)

# Path is captured before all-makefiles-under runs: nested makefiles below
# overwrite the global LOCAL_PATH variable.
TPM312_VIPER_DIR := $(LOCAL_PATH)/rk3399_tpm312/viper

include $(call all-makefiles-under,$(LOCAL_PATH))

# ViPER4Android RE (non-AIDL / legacy HIDL effect path), v2.0.2.
# The driver .so is loaded by audioserver through /vendor/etc/audio_effects.xml,
# so it lives in the vendor soundfx directory. The official control app is
# installed as a product priv-app so it can hold MODIFY_AUDIO_ROUTING.
ifeq ($(TPM312_VIPER_PREBUILTS_INCLUDED),)
TPM312_VIPER_PREBUILTS_INCLUDED := true

include $(CLEAR_VARS)
LOCAL_PATH := $(TPM312_VIPER_DIR)
LOCAL_MODULE := libv4a_re
LOCAL_MODULE_CLASS := SHARED_LIBRARIES
LOCAL_MODULE_SUFFIX := .so
LOCAL_MODULE_RELATIVE_PATH := soundfx
LOCAL_VENDOR_MODULE := true
LOCAL_MULTILIB := both
LOCAL_SRC_FILES_arm := libv4a_re_armeabi-v7a.so
LOCAL_SRC_FILES_arm64 := libv4a_re_arm64-v8a.so
LOCAL_SHARED_LIBRARIES := liblog libc libdl libm
LOCAL_MODULE_TAGS := optional
include $(BUILD_PREBUILT)

include $(CLEAR_VARS)
LOCAL_PATH := $(TPM312_VIPER_DIR)
LOCAL_MODULE := ViPER4Android
LOCAL_MODULE_CLASS := APPS
LOCAL_MODULE_SUFFIX := $(COMMON_ANDROID_PACKAGE_SUFFIX)
LOCAL_SRC_FILES := ViPER4Android.apk
LOCAL_CERTIFICATE := PRESIGNED
LOCAL_PRIVILEGED_MODULE := true
LOCAL_PRODUCT_MODULE := true
LOCAL_DEX_PREOPT := false
LOCAL_MODULE_TAGS := optional
include $(BUILD_PREBUILT)
endif
