PRODUCT_BRAND ?= oneUI

ifneq ($(TARGET_SCREEN_WIDTH) $(TARGET_SCREEN_HEIGHT),$(space))
# determine the smaller dimension
TARGET_BOOTANIMATION_SIZE := $(shell \
  if [ $(TARGET_SCREEN_WIDTH) -lt $(TARGET_SCREEN_HEIGHT) ]; then \
    echo $(TARGET_SCREEN_WIDTH); \
  else \
    echo $(TARGET_SCREEN_HEIGHT); \
  fi )

# get a sorted list of the sizes
bootanimation_sizes := $(subst .zip,, $(shell ls vendor/one/prebuilt/common/bootanimation))
bootanimation_sizes := $(shell echo -e $(subst $(space),'\n',$(bootanimation_sizes)) | sort -rn)

# find the appropriate size and set
define check_and_set_bootanimation
$(eval TARGET_BOOTANIMATION_NAME := $(shell \
  if [ -z "$(TARGET_BOOTANIMATION_NAME)" ]; then
    if [ $(1) -le $(TARGET_BOOTANIMATION_SIZE) ]; then \
      echo $(1); \
      exit 0; \
    fi;
  fi;
  echo $(TARGET_BOOTANIMATION_NAME); ))
endef
$(foreach size,$(bootanimation_sizes), $(call check_and_set_bootanimation,$(size)))

ifeq ($(TARGET_BOOTANIMATION_HALF_RES),true)
PRODUCT_BOOTANIMATION := vendor/one/prebuilt/common/bootanimation/halfres/$(TARGET_BOOTANIMATION_NAME).zip
else
PRODUCT_BOOTANIMATION := vendor/one/prebuilt/common/bootanimation/$(TARGET_BOOTANIMATION_NAME).zip
endif
endif

PRODUCT_BUILD_PROP_OVERRIDES += BUILD_UTC_DATE=0

ifeq ($(PRODUCT_GMS_CLIENTID_BASE),)
PRODUCT_PROPERTY_OVERRIDES += \
    ro.com.google.clientidbase=android-google
else
PRODUCT_PROPERTY_OVERRIDES += \
    ro.com.google.clientidbase=$(PRODUCT_GMS_CLIENTID_BASE)
endif

PRODUCT_PROPERTY_OVERRIDES += \
    keyguard.no_require_sim=true \
    ro.url.legal=http://www.google.com/intl/%s/mobile/android/basic/phone-legal.html \
    ro.url.legal.android_privacy=http://www.google.com/intl/%s/mobile/android/basic/privacy.html \
    ro.com.android.wifi-watchlist=GoogleGuest \
    ro.setupwizard.enterprise_mode=1 \
    ro.com.android.dateformat=MM-dd-yyyy \
    ro.com.android.dataroaming=false

PRODUCT_PROPERTY_OVERRIDES += \
    ro.build.selinux=1

# Thank you, please drive thru!
PRODUCT_PROPERTY_OVERRIDES += persist.sys.dun.override=0

ifneq ($(TARGET_BUILD_VARIANT),eng)
# Enable ADB authentication
ADDITIONAL_DEFAULT_PROPERTIES += ro.adb.secure=1
endif

# Copy over the changelog and translator to the device
PRODUCT_COPY_FILES += \
    vendor/one/CHANGELOG.mkdn:system/etc/CHANGELOG-ONE.txt

# Backup Tool
ifneq ($(WITH_GMS),true)
PRODUCT_COPY_FILES += \
    vendor/one/prebuilt/common/bin/backuptool.sh:system/bin/backuptool.sh \
    vendor/one/prebuilt/common/bin/backuptool.functions:system/bin/backuptool.functions \
    vendor/one/prebuilt/common/bin/50-one.sh:system/addon.d/50-one.sh \
    vendor/one/prebuilt/common/bin/blacklist:system/addon.d/blacklist
endif

# Signature compatibility validation
PRODUCT_COPY_FILES += \
    vendor/one/prebuilt/common/bin/otasigcheck.sh:system/bin/otasigcheck.sh

# init.d support
PRODUCT_COPY_FILES += \
    vendor/one/prebuilt/common/etc/init.d/00banner:system/etc/init.d/00banner \
    vendor/one/prebuilt/common/bin/sysinit:system/bin/sysinit

# userinit support
PRODUCT_COPY_FILES += \
    vendor/one/prebuilt/common/etc/init.d/90userinit:system/etc/init.d/90userinit

# One prebuilt
PRODUCT_COPY_FILES += \
    vendor/one/prebuilt/common/etc/init.d/88preinstall:system/etc/init.d/88preinstall

# One PhoneLoc Database
PRODUCT_COPY_FILES +=  \
    vendor/one/prebuilt/common/media/one-phoneloc.dat:system/media/one-phoneloc.dat

# One-specific init file
PRODUCT_COPY_FILES += \
    vendor/one/prebuilt/common/etc/init.local.rc:root/init.one.rc

# Use all prebuilt lib files
PRODUCT_COPY_FILES += $(shell test -d vendor/one/prebuilt/common/lib && \
    find vendor/one/prebuilt/common/lib -name '*.so' \
    -printf '%p:system/lib/%f ')

# Use all developers-party apk
PRODUCT_COPY_FILES += $(shell test -d vendor/one/prebuilt/$(DEVELOPER_MAINTAINER)/app && \
    find vendor/one/prebuilt/$(DEVELOPER_MAINTAINER)/app -name '*.apk' \
    -printf '%p:system/third-app/%f ')

# Use all third-party apk
PRODUCT_COPY_FILES += $(shell test -d vendor/one/prebuilt/third/app && \
    find vendor/one/prebuilt/third/app -name '*.apk' \
    -printf '%p:system/third-app/%f ')

PRODUCT_COPY_FILES += \
    vendor/one/prebuilt/One/app/OneServer/OneServer.apk:system/app/OneServer/OneServer.apk \
    vendor/one/prebuilt/One/app/iFlyIME/iFlyIME.apk:system/app/iFlyIME/iFlyIME.apk \

# Google IME
ifneq ($(TARGET_EXCLUDE_GOOGLE_IME),true)
PRODUCT_COPY_FILES += \
    vendor/one/prebuilt/google/app/GoogleIME/GoogleIME.apk:system/app/GoogleIME/GoogleIME.apk \
    vendor/one/prebuilt/google/app/GoogleIME/lib/arm/libjni_unbundled_latinimegoogle.so:system/app/GoogleIME/lib/arm/libjni_unbundled_latinimegoogle.so
endif

# Bring in camera effects
PRODUCT_COPY_FILES +=  \
    vendor/one/prebuilt/common/media/LMprec_508.emd:system/media/LMprec_508.emd \
    vendor/one/prebuilt/common/media/PFFprec_600.emd:system/media/PFFprec_600.emd

# Enable SIP+VoIP on all targets
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.software.sip.voip.xml:system/etc/permissions/android.software.sip.voip.xml

# Enable wireless Xbox 360 controller support
PRODUCT_COPY_FILES += \
    frameworks/base/data/keyboards/Vendor_045e_Product_028e.kl:system/usr/keylayout/Vendor_045e_Product_0719.kl

# This is one!
PRODUCT_COPY_FILES += \
    vendor/one/config/permissions/com.one.android.xml:system/etc/permissions/com.one.android.xml

# T-Mobile theme engine
include vendor/one/config/themes_common.mk

# Required one packages
PRODUCT_PACKAGES += \
    Development \
    BluetoothExt

# Optional one packages
PRODUCT_PACKAGES += \
    VoicePlus \
    Basic \
    libemoji \
    Terminal

PRODUCT_PROPERTY_OVERRIDES += \
    persist.radio.ipcall.enabled=true

PRODUCT_PACKAGES += \
    Launcher3 \
    Trebuchet \
    AudioFX \
    CMFileManager \
    Eleven \
    LockClock \
    CMHome \
#    SystemUpdate

# Cyanogenmod Hardware Abstraction Framework
PRODUCT_PACKAGES += \
    org.cyanogenmod.hardware \
    org.cyanogenmod.hardware.xml

# Extra tools in one
PRODUCT_PACKAGES += \
    libsepol \
    e2fsck \
    mke2fs \
    tune2fs \
    bash \
    nano \
    htop \
    powertop \
    lsof \
    mount.exfat \
    fsck.exfat \
    mkfs.exfat \
    mkfs.f2fs \
    fsck.f2fs \
    fibmap.f2fs \
    ntfsfix \
    ntfs-3g \
    gdbserver \
    micro_bench \
    oprofiled \
    sqlite3 \
    strace

# Openssh
PRODUCT_PACKAGES += \
    scp \
    sftp \
    ssh \
    sshd \
    sshd_config \
    ssh-keygen \
    start-ssh

# rsync
PRODUCT_PACKAGES += \
    rsync

# Stagefright FFMPEG plugin
PRODUCT_PACKAGES += \
    libstagefright_soft_ffmpegadec \
    libstagefright_soft_ffmpegvdec \
    libFFmpegExtractor \
    libnamparser

# These packages are excluded from user builds
ifneq ($(TARGET_BUILD_VARIANT),user)

PRODUCT_PACKAGES += \
    procmem \
    procrank \
    su

PRODUCT_PROPERTY_OVERRIDES += \
    persist.sys.root_access=1
else

PRODUCT_PROPERTY_OVERRIDES += \
    persist.sys.root_access=0

endif

# Chromium Prebuilt
ifeq ($(PRODUCT_PREBUILT_WEBVIEWCHROMIUM),yes)
-include prebuilts/chromium/$(ONE_BUILD)/chromium_prebuilt.mk
endif

PRODUCT_PACKAGE_OVERLAYS += vendor/one/overlay/common

PRODUCT_VERSION_MAJOR = 50
PRODUCT_VERSION_MINOR = 2
PRODUCT_VERSION_MAINTENANCE = 0
ONE_BUILDTYPE := OFFICIAL
ONE_VERSION := ONE$(PRODUCT_VERSION_MAJOR).$(PRODUCT_VERSION_MINOR)-$(ONE_BUILD)-$(shell date +%Y%m%d%H%M)-$(ONE_BUILDTYPE)

PRODUCT_PROPERTY_OVERRIDES += \
  ro.one.version=$(ONE_VERSION) \
  ro.modversion=$(ONE_VERSION)

-include $(WORKSPACE)/build-env/image-auto-bits.mk

$(call prepend-product-if-exists, vendor/extra/product.mk)
