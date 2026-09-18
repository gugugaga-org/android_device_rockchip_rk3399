# TPM312 needs the Android 14 VNDK namespace for the Rockchip Mali DDK.

local_dir := $(dir $(lastword $(MAKEFILE_LIST)))
$(call declare-release-config, ap2a, $(local_dir)release/build_config/ap2a.scl)
local_dir :=
