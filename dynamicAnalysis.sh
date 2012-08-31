#!/usr/bin/env bash

# TODO check some stuff here...
# * 

# Settings
AVD=Analyse
TIME=60
PIDFILE=emu.pid

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

# report <repacked apk> <orginal apk>
function report {
	# create analyses report
	FOLDER=analyses/report_$(date +%F_%H%M%S)
	mkdir $FOLDER

	mv adb_logcat.log $FOLDER
	mv droidbox.log $FOLDER
	mv *.png $FOLDER
	cp $1 $FOLDER/suspect_repack.apk
 	cp $2 $FOLDER/suspect.apk

	# call the reportbuilderscript to have a shiny html document
	./reportbuilder.sh $FOLDER > $FOLDER/index.html 
}

# use out intent caller to call some various intents and hope for the best (worst)
function intentCaller {
	for intent in $(./getAPKInformation.py -i -f $1); do
	    echo $intent
	    adb shell am broadcast $intent
	    sleep 5
	done
}

emulator -avd $AVD -no-snapshot-save -snapshot original_state -no-audio &
echo $! >> $PIDFILE

# need to wait because we need a started emulator...
./wait.sh 30

# now we repackage the apk file
./APIMonitor/apimonitor.py $1 | tee .tmpapimon

NEWAPP=$(grep "NEW APK:" .tmpapimon | cut -d ':' -f 2) 
rm .tmpapimon

# the repackaged apk can now be installed and droidbox will analyse the log...
# TODO wait for fixed droidbox version...
adb logcat -c
adb logcat DroidBox:V *:S > adb_logcat.log &
echo $! >> $PIDFILE 

# install the package
adb install $NEWAPP

# now start the main activity
adb shell "am start -a android.intent.action.MAIN -n $(./getAPKInformation.py -ap -ma -f $NEWAPP | xargs | tr ' ' /)"
# Now wait and gather logs...
./wait.sh $TIME

cat $PIDFILE | while read pid; do kill $pid; done
rm $PIDFILE
# report $NEWAPP $1
