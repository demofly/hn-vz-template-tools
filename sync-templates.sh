#!/bin/bash

DIR="`dirname $0`"
pushd "${DIR}"
    DIR="`pwd`"
popd

if [ -t 1 ] # check if it is TTY run / manual
then
	OPTS="-auvP"
else
	OPTS="-auv"
fi

if [ ! -z "$2" ]
then
    echo "==== Syncing to $2 :"
    if [ -z "$1" ]
    then
	rsync ${OPTS} /var/lib/vz/template/cache/* "$2/"
    else
	rsync ${OPTS} "$1" "$2"
    fi
    HOST=`echo "$2" | cut -d':' -f1`
    TPLPATH=`echo "$2" | cut -d':' -f2`
    echo "  == Checking CentOS symlinks on ${HOST} :"
    ssh -n ${HOST} "cd '${TPLPATH}'; ls *[cC][eE][nN][tT][oO][sS]*.tar.gz | while read FL; do ln -sv /etc/vz/dists/centos.conf /etc/vz/dists/\${FL}.conf 2>/dev/null; done"
    echo
    exit
fi

grep -Pv '^[\t ]*#|^[\t ]*$' "${DIR}/vz-template-targets.conf" | while read DEST
do
    if [ -z "$DEST" ]
    then
	continue
    fi
    echo "==== Syncing to $DEST :"
    if [ -z "$1" ]
    then
	rsync ${OPTS} /var/lib/vz/template/cache/* "$DEST/"
    else
	rsync ${OPTS} "$1" "$DEST/"
    fi
    HOST=`echo "$DEST" | cut -d':' -f1`
    TPLPATH=`echo "$DEST" | cut -d':' -f2`
    echo "  == Checking CentOS symlinks on ${HOST} :"
    ssh -n ${HOST} "cd '${TPLPATH}'; ls *[cC][eE][nN][tT][oO][sS]*.tar.gz | while read FL; do ln -sv /etc/vz/dists/centos.conf /etc/vz/dists/\${FL}.conf 2>/dev/null; done"
    echo
done
