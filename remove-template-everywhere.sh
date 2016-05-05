#!/bin/bash

DIR="`dirname $0`"
pushd "${DIR}"
    DIR="`pwd`"
popd

grep -Pv '^[\t ]*#|^[\t ]*$' "${DIR}/vz-template-targets.conf" | while read DEST
do
    if [ -z "$DEST" ]
    then
	continue
    fi
    echo "==== Removing $DEST$1:"
    HOST=`echo "$DEST" | cut -d':' -f1`
    TPLPATH=`echo "$DEST" | cut -d':' -f2`
    ssh -n ${HOST} "cd '${TPLPATH}'; rm -vf $1 $1.tar.gz 2>/dev/null"
    echo
done
