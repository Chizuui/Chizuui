#!/usr/bin/env bash

set -e
set -o pipefail

echo "====================================="
echo " PixelOS 17 Build - Redmi 13C Gale"
echo "====================================="

# =========================
# Init & Sync ROM
# =========================

repo init \
    -u https://github.com/sweet-bullet/pixelos_manifest.git \
    -b seventeen \
    --git-lfs \
    --depth=1

/opt/crave/resync.sh

# =========================
# Device Tree
# =========================

echo "Cloning Gale device tree..."

rm -rf device/xiaomi/gale

# Bersihkan folder rusak dari build CRLF sebelumnya, kalau masih ada
rm -rf $'device/xiaomi/gale\r'

git clone \
    --depth=1 \
    https://github.com/Chizuui/device_xiaomi_gale.git \
    -b dev/POS-17 \
    device/xiaomi/gale

# =========================
# Build Setup
# =========================

echo "Setting up build environment..."

source build/envsetup.sh

export SOONG_NINJA=ninja
export BUILD_USERNAME=chizui
export BUILD_HOSTNAME=akamiya_chizui

# =========================
# Select Device
# =========================

echo "Selecting gale..."

breakfast gale userdebug

# =========================
# Start Build
# =========================

echo "====================================="
echo " Starting PixelOS build"
echo "====================================="

m pixelos

# =========================
# Upload
# =========================

OUT_DIR="out/target/product/gale"

echo "Searching for PixelOS zip..."

ZIP="$(
    find "$OUT_DIR" \
        -maxdepth 1 \
        -type f \
        -name 'PixelOS_*.zip' \
        | sort \
        | tail -n 1
)"

if [ -n "$ZIP" ] && [ -f "$ZIP" ]; then
    echo "====================================="
    echo " ROM found:"
    echo " $ZIP"
    echo "====================================="

    echo "Uploading to GoFile..."

    wget -q \
        https://raw.githubusercontent.com/lordgaruda/GoFile-Upload/refs/heads/master/upload.sh

    chmod +x upload.sh
    ./upload.sh "$ZIP"

    echo "Upload done!"
else
    echo "No PixelOS zip found in $OUT_DIR"
    exit 1
fi
