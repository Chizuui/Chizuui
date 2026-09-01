#!/bin/bash

# init & sync
repo init -u https://github.com/sweet-bullet/pixelos_manifest.git -b seventeen --git-lfs --depth=1
/opt/crave/resync.sh

# device source
git clone https://github.com/Chizuui/device_xiaomi_gale.git -b dev/POS-17 device/xiaomi/gale

# Setup build
. build/envsetup.sh

export SOONG_NINJA=ninja
export BUILD_USERNAME=chizui
export BUILD_HOSTNAME=akamiya_chizui

# start build
breakfast earth userdebug 
m pixelos

# Upload
echo "upload to gofile..."
if [ -f out/target/product/earth/*202608*.zip ]; then
    wget https://raw.githubusercontent.com/lordgaruda/GoFile-Upload/refs/heads/master/upload.sh
    chmod +x upload.sh ; ./upload.sh out/target/product/earth/PixelOS_*.zip
    echo "upload done!"
else
    echo "no zip found at out/ dir..."
    exit 1
fi


