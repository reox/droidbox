#!/usr/bin/env bash

emulator -avd $1 -system images/system.img -ramdisk images/ramdisk.img -kernel images/zImage -wipe-data -prop dalvik.vm.execution-mode=int:portable &
