#!/bin/bash
#sudo update-alternatives --config gcc
# !!!! to build NDK toolchain in ubuntu needs "gcc-4.6"
#the other newer ubuntu toolchain fail to build NDK toolchains

#backup original toolchains
#the new built toolchains will overwrite the origianl toolchains.


NDK_TOOLCHAINS=\
"arm-linux-androideabi-4.8 "\
"arm-linux-androideabi-4.9 "\
"aarch64-linux-android-4.9 "\
"mips64el-linux-android-4.9 "\
"mipsel-linux-android-4.8 "\
"mipsel-linux-android-4.9 "\
"x86-4.8 "\
"x86-4.9 "\
"x86_64-4.9"

LLVM_TOOLCHAINS=\
"llvm-3.5 "\
"llvm-3.6 "


NDK_TOOLCHAINS_CLANG=\
"arm-linux-androideabi-clang3.5 "\
"arm-linux-androideabi-clang3.6 "\
"aarch64-linux-android-clang3.5 "\
"aarch64-linux-android-clang3.6 "\
"mips64el-linux-android-clang3.5 "\
"mips64el-linux-android-clang3.6 "\
"mipsel-linux-android-clang3.5 "\
"mipsel-linux-android-clang3.6 "\
"x86_64-clang3.5 "\
"x86_64-clang3.6 "\
"x86-clang3.5 "\
"x86-clang3.6 "\
"renderscript "

OS_ARCH=`uname -p`
export ANDROID_NDK_ROOT=$HOME/NDK/android-ndk-r10e

function build_llvm() {
#llvm
for toolchain in $LLVM_TOOLCHAINS
do
	cd $ANDROID_NDK_ROOT
    #if [ -d toolchains/$toolchain/prebuilt ]
    #then
    #    echo "... $toolchain appears to be already present.. skipping"
    #else
        if [ $OS_ARCH == "x86_64" ]
        then
            ./build/tools/build-llvm.sh --try-64 --check --mclinker -j8 `pwd`/src `pwd` $toolchain
        else
            ./build/tools/build-llvm.sh --check --mclinker -j8 `pwd`/src `pwd`  $toolchain
        fi
    #fi
done
}

function build_ndk() {
#tool chain
for toolchain in $NDK_TOOLCHAINS
do
	cd $ANDROID_NDK_ROOT
    #if [ -d toolchains/$toolchain/prebuilt ]
    #then
    #    echo "... $toolchain appears to be already present.. skipping"
    #else
        if [ $OS_ARCH == "x86_64" ]
        then
            ./build/tools/build-gcc.sh --try-64 `pwd`/src `pwd` -j8 $toolchain
        else
            ./build/tools/build-gcc.sh `pwd`/src `pwd` -j8 $toolchain
        fi
    #fi
    # copy the config files from the included 4.9 compiler
    if [ -f toolchains/$toolchain/config.mk ]
    then
        echo "... toolchain config files already present.. skipping"
    else
        echo "... copying toolchain config files from 4.? compiler"
        cp toolchains.org/${toolchain}/config.mk toolchains/$toolchain/.
        cp toolchains.org/${toolchain}/setup.mk toolchains/$toolchain/.
	fi
	cd toolchains/$toolchain/prebuilt
	if [ -d linux-x86_64 ]
	then
		echo "... symlinking toolchain linux-x86_64 to linux-x86"
		if [ -L linux-x86 ]
		then
			echo "... symlink already exists.. skipping"
		else
			ln -s linux-x86_64 linux-x86
		fi
	fi
done
}
#
build_ndk $*
#
build_llvm $*
#TODO : cp llvm3.6 from origin and setup ld.mcld
if [ -d $ANDROID_NDK_ROOT/toolchains.org/llvm-3.6 ]; then
	if [ ! -d $ANDROID_NDK_ROOT/toolchains/llvm-3.6 ]; then
		cp -rf $ANDROID_NDK_ROOT/toolchains.org/llvm-3.6/ $ANDROID_NDK_ROOT/toolchains/
		./build/tools/deploy-host-mcld.sh
	fi
fi

