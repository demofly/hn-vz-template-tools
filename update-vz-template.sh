#!/bin/bash

TPLNAME=debian-base-squeeze_7.2_amd64
TPLDIR=`grep "^TEMPLATE" /etc/vz/vz.conf | cut -d= -f2 | tail -n1`/cache
#TGTMASTERLISTD=''
VEID=100

rm -fv "${TPLDIR}/${TPLNAME}.tar.gz"
vzctl exec ${VEID} apt-get clean # debian only! this string should be commented for non debian-like linux
DIR="`dirname $0`"
pushd "${DIR}"
    DIR="`pwd`"
popd
"${DIR}/create-vz-template-from-CTID.sh" "${VEID}" "${TPLNAME}"
#for HOST in $TGTMASTERLIST
#do
#    echo "==== Cloning $TPLNAME to $HOST:"
#    TGTTPLDIR=`ssh $HOST 'grep "^TEMPLATE" /etc/vz/vz.conf | cut -d= -f2 | tail -n1'`/cache
#    scp $TPLDIR/${TPLNAME}.tar.gz $HOST:$TGTTPLDIR/
#done
grep -Pv '^[\t ]*#|^[\t ]*$' "${DIR}/vz-template-targets.conf" | while read DEST
do
    if [ -z "$DEST" ]
    then
	continue
    fi
    scp "$TPLDIR/${TPLNAME}.tar.gz" "$DEST"
done
