#!/usr/bin/env bash

FOLDER=$1
ANDROGUARD=/home/reox/tools/androguard/

cat << 'EOH'
<html>
	<head>
EOH

echo "<title>Automated Report - Generated $(date +%F-%H:%M:%S) by $(whoami)</title>"
cat << 'EOH'
	</head>
	<body>
	<h1>Analyzed File</h1>
	was <a href="suspect.apk">Suspect APK (Plain APK File, watch out!)</a>
	<ul>
EOH
	echo "<li>MD5: $(md5sum $FOLDER/suspect.apk)</li>"
	echo "<li>SHA512: $(sha512sum $FOLDER/suspect.apk)</li>"
#	echo "<li>CRC32: $(crc32 $FOLDER/suspect.apk)</li>"
cat << 'EOH'
	</ul>
	<h1>Report Details by DroidBox</h1>
	<pre>
EOH
cat $FOLDER/droidbox.log | sed '1,8 d' | sed '$ d'
cat << 'EOH'
	</pre>
	<h1>Graphs by DroidBox</h1>
	<img src="behaviorgraph.png">

	<h1>Screenshots while running emulator</h1>
EOH

for img in $FOLDER/fb0*-0.png; do
	echo '<img src="'$(basename $img)'">'
done

cat << 'EOH'
	<h1>Other Tools</h1>
	<h2>Androsign</h2>
	<pre>
EOH
export PYTHONPATH=$ANDROGUARD:$PYTHONPATH
# $ANDROGUARD/androsign.py -b $ANDROGUARD/signatures/dbandroguard -c $ANDROGUARD/signatures/dbconfig -i $FOLDER/suspect.apk
cat << 'EOH'
	</pre>
	<h2>Intents / Receivers / Providers</h2>
	Intents
	<pre>
EOH
./getAPKInformation.py -i -f $FOLDER/suspect.apk
echo '</pre>Receivers<pre>'
./getAPKInformation.py -r -f $FOLDER/suspect.apk
echo '</pre>Providers<pre>'
./getAPKInformation.py -p -f $FOLDER/suspect.apk
cat << 'EOH'
	</pre>
	</body>
</html>
EOH
