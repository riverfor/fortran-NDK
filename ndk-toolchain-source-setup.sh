#!/bin/bash
#setup local host as a git server, copy your local pub key to authorized_keys
#so you are now git server and client.
#~/.ssh$ cp id_rsa.pub authorized_keys

#download the toolchain
#mkdir -p toolchain.src
#cd toolchain.src
#repo init https://android.googlesource.com/toolchain/manifest.git
#repo sync

#checkout the master branch for every repo
#repo forall -p -c "git checkout -b master remotes/aosp/master"

#symbolic link so each folder has an alias name postfix ".git"
#for dir in `ls`
#do
#	ln -s `pwd`/$dir git/$dir.git
#done
OS_ARCH=`uname -p`
export ANDROID_NDK_ROOT=$HOME/NDK/android-ndk-r10e
echo $ANDROID_NDK_ROOT

#fast setup the toolchain from download source
#some repos should be checkout to the desired branches, like llvm, compiler-rt, yasm....
$ANDROID_NDK_ROOT/build/tools/download-toolchain-sources.sh --git-base=127.0.0.1:$HOME/NDK/toolchain.src/.repo/projects src