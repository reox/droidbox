#!/usr/bin/env bash

# TODO check some stuff here...
# * 

# Settings
AVD=DroidBox
TIME=60
PIDFILE=emu.pid
PACKAGE=$(aapt dump badging $1 | egrep package | egrep -o "name.*" | cut -d "'" -f 2)

# automated screenshots every 10 seconds
# will not work for emulators > 2.1!
function screenshooter {
    while [ $(adb get-state) != "unknown" ]; do
        adb pull /dev/graphics/fb0 fb0
        ./565to888.py < fb0 > fb0.888
        convert -depth 8 -size 480x800 RGB:fb0.888 fb0_$(date +%F_%H%M%S).png
        rm fb0 fb0.888
        sleep 10
    done
}

# cleanup function
function cleanup {
	cat $PIDFILE | while read pid; do kill $pid; done
	rm $PIDFILE
	rm ${HOME}/.android/avd/${AVD}.avd/cache.img 

}

function report {
	# create analyses report
	FOLDER=report_$(date +%F_%H%M%S)
	mkdir analyses/$FOLDER

	mv droidbox.log analyses/$FOLDER
	mv *.png analyses/$FOLDER
	cp $1 analyses/$FOLDER/suspect.apk

	# call the reportbuilderscript to have a shiny html document
	./reportbuilder.sh analyses/$FOLDER > analyses/$FOLDER/index.html 
}

# use out intent caller to call some various intents and hope for the best (worst)
function intentCaller {
	for intent in $(./getAPKInformation.py -i -f $1); do
	    echo $intent
	    adb shell am broadcast $intent
	    sleep 5
	done
}

emulator -avd $AVD -system images/system.img -ramdisk images/ramdisk.img -kernel images/zImage -wipe-data -prop dalvik.vm.execution-mode=int:portable &
echo $! > $PIDFILE

# need to wait because we need a started emulator...
./wait.sh 100

# because droidbox will now terminate correctly, no need for killing after
./droidbox.sh $1 $TIME | tee droidbox.log
echo "droidbox time is over..:"

cleanup
report
