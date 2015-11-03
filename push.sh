#!/bin/bash

DEVDIR=''

if [ "$1" != "" ]
then
	source $1.cfg
fi

# error checking
if [ "$DEVDIR" == "" ]
then
	echo Improper site defined, exiting.
	exit
fi

cp -R -f -u $DEVDIR/* $TEMPDIR

if [ $COMPRESSION ]
then
	rm -R -f "$TEMPDIR/user-content/"
	rmdir "$TEMPDIR/user-content/"
else
	find $DEVDIR -type f | egrep '\.(css|js)$' | while read line; do
		if [[ $line != *"jquery"* ]]
		then
			echo $line
			newline=$TEMPDIR${line#$DEVDIR}
			cat $line | sed -e "s|/\*\(\\\\\)\?\*/|/~\1~/|g" -e "s|/\*[^*]*\*\+\([^/][^*]*\*\+\)*/||g" -e "s|\([^:/]\)//.*$|\1|" -e "s|^//.*$||" | tr '\n' ' ' | sed -e "s|/\*[^*]*\*\+\([^/][^*]*\*\+\)*/||g" -e "s|/\~\(\\\\\)\?\~/|/*\1*/|g" -e "s|\s\+| |g" -e "s| \([{;:,]\)|\1|g" -e "s|\([{;:,]\) |\1|g" > $newline	
		else
			echo found jquery
		fi
	done
fi

rsync -avrz $TEMPDIR/* $PUBDIR
