#!/usr/bin/env bash

adb logcat -c | adb logcat dalvikvm:W OSNetworkSystem:W *:S | tee adb_logcat.log |python scripts/droidbox.py $1 $2
