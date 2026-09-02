#!/bin/bash

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

repo init -u https://github.com/aobuta-prjkt/pixelos_manifest.git -b seventeen --git-lfs --depth=1

/opt/crave/resync.sh

# Device source

git clone https://github.com/Chizuui/device_xiaomi_gale.git \
    -b dev/POS-17 \
    device/xiaomi/gale

# Build environment

. build/envsetup.sh

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
