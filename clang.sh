#!/bin/bash
rm .version
# Bash Color
green='\033[01;32m'
red='\033[01;31m'
cyan='\033[01;36m'
blue='\033[01;34m'
blink_red='\033[05;31m'
restore='\033[0m'

# Resources
THREAD="-j$(grep -c ^processor /proc/cpuinfo)"
DEFCONFIG="land_defconfig"
KERNEL="Image.gz-dtb"

# Reloaded Kernel Details
BASE_VER="Reloaded™-"
VER="$(date +"%Y-%m-%d"-%H%M)"
K_VER="$BASE_VER$VER-land"

# Vars
export ARCH=arm64
export SUBARCH=arm64
export KBUILD_BUILD_USER="ritesh"
export KBUILD_BUILD_HOST="reloaded-server"
export TZ="Asia/Calcutta"

# Paths
KERNEL_DIR=`pwd`
ANYKERNEL_DIR="$KERNEL_DIR/build"
REPACK_DIR="$ANYKERNEL_DIR"
ZIP_MOVE="$KERNEL_DIR/out"
ZIMAGE_DIR="$KERNEL_DIR/arch/arm64/boot"


CCACHE=$(command -v ccache)
CROSS_COMPILE="aarch64-linux-android-"
TOOL_CHAIN_PATH="${KERNEL_DIR}/../gtc/bin"
CLANG_TCHAIN="${KERNEL_DIR}/../clang/clang-4556391/bin/clang"
CLANG_VERSION="$(${CLANG_TCHAIN} --version | head -n 1 | cut -d'(' -f1,4)"

export LD_LIBRARY_PATH="${TOOL_CHAIN_PATH}/../lib"
export PATH=$PATH:${TOOL_CHAIN_PATH}

# Functions
kmake() {
        make CC="${CCACHE} ${CLANG_TCHAIN}" \
             CLANG_TRIPLE=aarch64-linux-gnu- \
             CROSS_COMPILE=${TOOL_CHAIN_PATH}/${CROSS_COMPILE} \
             KBUILD_COMPILER_STRING="${CLANG_VERSION}" \
             HOSTCC="${CLANG_TCHAIN}" \
             $@
}

function make_kernel {
	kmake $DEFCONFIG $THREAD
        kmake $KERNEL $THREAD
        kmake dtbs $THREAD
	cp -vr $ZIMAGE_DIR/$KERNEL $REPACK_DIR/zImage
}

function make_zip {
	cd $REPACK_DIR
        zip -r `echo $K_VER`.zip *
        mkdir $ZIP_MOVE
	mv  `echo $K_VER`.zip $ZIP_MOVE
	cd $KERNEL_DIR
}

function clean {
	rm -rf $ZIP_MOVE/*
	cd $ANYKERNEL_DIR
	rm -rf zImage
        cd $KERNEL_DIR
	kmake clean && kmake mrproper
	echo "cleaned directory"
}

DATE_START=$(date +"%s")
echo -e "${restore}"
echo "Compiling Reloaded Kernel"
clean
make_kernel
make_zip

echo -e "${green}"
echo "out/"$K_VER.zip
echo "------------------------------------------"
echo -e "${restore}"

DATE_END=$(date +"%s")
DIFF=$(($DATE_END - $DATE_START))
echo "Time: $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds."
echo " "
cd $ZIP_MOVE
ls

