#!/bin/bash

find $2 -type f | while read file; do
	case $1 in
	"md5")
	hash=$(md5sum "$file" | cut -d ' ' -f 1)
	;;
	"sha256")
	hash=$(sha256sum "$file" | cut -d ' ' -f 1)
	;;
	esac
    if [ -f $3/$hash ]; then
        c=0
        while [ -f $3/$hash.$c ]; do
            c=$(($c + 1))
        done
        hash=
        hash="$hash.$c"
    fi
	mv "$file" $3/$hash
done
