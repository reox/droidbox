#!/bin/bash

[[ -d output ]] || mkdir output

find $1 -type f | while read file; do
	# test if we have a zip file here...
	type=$(file "$file" --mime-type | cut -d : -f 2 | grep -o 'zip')
	echo "$file $type"

	if [ "foo$type" = "foozip" ]; then
		unzip "$file" classes.dex
		if [ -f classes.dex ]; then
			hash=$(md5sum classes.dex | cut -d ' ' -f 1)
			mv classes.dex output/$hash
		fi
	else
		isDex=$(file $file | grep -o dex)
		if [ "foo$isDex" = "foodex" ]; then
			hash=$(md5sum $file | cut -d ' ' -f 1)
			mv $file output/$hash
		fi
	fi

done
	
