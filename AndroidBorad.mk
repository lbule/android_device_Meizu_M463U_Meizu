LOCAL_PATH := $(call my-dir)
#----------------------------------------------------------------------
# extra images
#----------------------------------------------------------------------
include build/core/generate_extra_images.mk

LOCAL_PATH := $(call my-dir)
include $(CLEAR_VARS)
LOCAL_SRC_FILES := mtk-kpd.kcm
LOCAL_MODULE_TAGS := user
include $(BUILD_KEY_CHAR_MAP)
##################################
$(call config-custom-folder,modem:modem)
##### SET MD OUTPUT POSITION #####
ifeq ($(strip $(MTK_CIP_SUPPORT)),yes)
ifneq ($(strip $(MTK_MD_SBP_CUSTOM_VALUE)),)
MTK_MODEM_OUT_ETC := $(TARGET_OUT_ETC)
else
MTK_MODEM_OUT_ETC := $(TARGET_CUSTOM_OUT)/etc
endif
else
MTK_MODEM_OUT_ETC := $(TARGET_OUT_ETC)
endif
MTK_MODEM_LOCAL_PATH := $(LOCAL_PATH)
MTK_MODEM_INSTALLED_MODULES :=
MTK_MODEM_SRC_FIRMWARE := modem*.img
ifeq ($(strip $(MTK_MDLOGGER_SUPPORT)),yes)
MTK_MODEM_SRC_FIRMWARE += catcher_filter*.bin
endif
MTK_MODEM_MAP_VALUE_TO_X := 1 2
MTK_MODEM_MAP_X_1_TO_YY := 2g wg tg lwg ltg sglte
MTK_MODEM_MAP_X_2_TO_YY := 2g
MTK_MODEM_SRC_FIRMWARE_1 := dsp*.bin
define mtk-install-modem
include $$(CLEAR_VARS)
LOCAL_MODULE := $$(notdir $(1))
LOCAL_MODULE_CLASS := ETC
LOCAL_MODULE_PATH := $(2)
LOCAL_SRC_FILES := $(1)
include $$(BUILD_PREBUILT)
MTK_MODEM_INSTALLED_MODULES += $$(LOCAL_INSTALLED_MODULE)
endef
##### INSTALL MODEM FIRMWARE #####
$(foreach x,$(MTK_MODEM_MAP_VALUE_TO_X),\
$(if $(filter yes,$(strip $(MTK_ENABLE_MD$(x)))),\
$(foreach yy,$(MTK_MODEM_MAP_X_$(x)_TO_YY),\
$(if $(wildcard $(MTK_MODEM_LOCAL_PATH)/modem/modem_$(x)_$(yy)_n.img),\
$(foreach src,$(MTK_MODEM_SRC_FIRMWARE) $(MTK_MODEM_SRC_FIRMWARE_$(x)),\
$(eval des := $(subst *,_$(x)_$(yy)_n,$(src)))\
$(eval $(call mtk-install-modem,modem/$(des),$(MTK_MODEM_OUT_ETC)/firmware))\
)\
)\
)\
)\
)
########INSTALL MODEM_DATABASE########
ifeq ($(strip $(MTK_INCLUDE_MODEM_DB_IN_IMAGE)),yes)
ifeq ($(filter generic banyan_addon banyan_addon_x86,$(PROJECT)),)
$(foreach x,$(MTK_MODEM_MAP_VALUE_TO_X),\
$(if $(filter yes,$(strip $(MTK_ENABLE_MD$(x)))),\
$(foreach yy,$(MTK_MODEM_MAP_X_$(x)_TO_YY),\
$(if $(wildcard $(MTK_MODEM_LOCAL_PATH)/modem/BPLGUInfoCustomAppSrcP_*_$(x)_$(yy)_n),\
$(eval MTK_MODEM_SRC_MDDB := $(wildcard $(MTK_MODEM_LOCAL_PATH)/modem/BPLGUInfoCustomAppSrcP_*_$(x)_$(yy)_n))\
,\
$(eval MTK_MODEM_SRC_MDDB := $(wildcard $(MTK_MODEM_LOCAL_PATH)/modem/BPLGUInfoCustomApp_*_$(x)_$(yy)_n))\
)\
$(if $(wildcard $(MTK_MODEM_LOCAL_PATH)/modem/DbgInfo_*_$(x)_$(yy)_n),\
$(eval MTK_MODEM_SRC_MDDB += $(wildcard $(MTK_MODEM_LOCAL_PATH)/modem/DbgInfo_*_$(x)_$(yy)_n))\
)\
$(foreach src,$(MTK_MODEM_SRC_MDDB),\
$(eval des := $(notdir $(src)))\
$(eval $(call mtk-install-modem,modem/$(des),$(MTK_MODEM_OUT_ETC)/mddb))\
)\
)\
)\
)
endif
endif
##################################
$(info MTK_MODEM_INSTALLED_MODULES = $(MTK_MODEM_INSTALLED_MODULES))

