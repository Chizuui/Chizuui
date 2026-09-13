#!/bin/bash
set -e

# Clean up
rm -rf device/xiaomi/gale
rm -rf hardware/xiaomi
rm -rf hardware/mediatek
rm -rf device/mediatek/sepolicy_vndr
rm -rf vendor/mediatek/ims
rm -rf vendor/xiaomi/gale
rm -rf kernel/xiaomi/gale
rm -rf vendor/lineage-priv/keys

# Init PixelOS source
repo init -u https://github.com/Chizui-Dump/pixelos_manifest.git \
    -b seventeen \
    --git-lfs \
    --depth=1

/opt/crave/resync.sh
    
# Build environment
. build/envsetup.sh

# Patch BPF
git -C packages/modules/Connectivity \
    -c commit.gpgSign=false am \
    "$PWD/device/xiaomi/gale/patches/android17-bpf/0004-connectivity-relax-5.10-requirement.patch" \
    "$PWD/device/xiaomi/gale/patches/android17-bpf/0005-connectivity-do-not-fatal-on-clat-bpf-context.patch"

# Maintainer
git -C vendor/custom \
    -c commit.gpgSign=false am \
    "$PWD/device/xiaomi/gale/patches/android17-maintainer/0001-vendor-custom-export-maintainer-property.patch"

git -C packages/apps/Settings \
    -c commit.gpgSign=false am \
    "$PWD/device/xiaomi/gale/patches/android17-maintainer/0002-settings-add-maintainer-device-info.patch" \
    "$PWD/device/xiaomi/gale/patches/android17-maintainer/0003-settings-add-maintainer-metadata.patch"

# NFC TMS
git -C packages/modules/Nfc \
    -c commit.gpgSign=false am \
    "$PWD/device/xiaomi/gale/patches/android17-nfc/0001-libnfc-nci-synthesize-post-init-for-tms.patch" \
    "$PWD/device/xiaomi/gale/patches/android17-nfc/0002-libnfc-nci-log-tms-post-init-state.patch" \
    "$PWD/device/xiaomi/gale/patches/android17-nfc/0003-libnfc-nci-log-tms-core-init-status.patch" \
    "$PWD/device/xiaomi/gale/patches/android17-nfc/0004-libnfc-nci-tolerate-thn31-core-init-status.patch"

export BUILD_USERNAME=chizui
export BUILD_HOSTNAME=akamiya_chizui
export SOONG_NINJA=ninja

# Build
breakfast gale userdebug

make installclean

m pixelos

# Upload
echo "Upload to GoFile will be started..."

if compgen -G "out/target/product/gale/PixelOS_*.zip" > /dev/null; then
    wget https://raw.githubusercontent.com/lordgaruda/GoFile-Upload/refs/heads/master/upload.sh

    chmod +x upload.sh

    ./upload.sh out/target/product/gale/PixelOS_*.zip

    echo "Upload Done!"
else
    echo "No zip found!"
    exit 1
fi
