#!/bin/bash

VEID=100
TPLNAMEDIST=`vzctl exec ${VEID} lsb_release -ic | cut -d: -f2 | tr -s "\n\t " " " | sed -r 's#^ +| *$##g;s# #-#g'`
TPLNAMEVER=`vzctl exec ${VEID} lsb_release -r | cut -d: -f2 | tr -s "\n\t " " " | sed -r 's# +##g'`
TPLNAME=${TPLNAMEDIST}_${TPLNAMEVER}_amd64
TPLDIR=`grep "^TEMPLATE" /etc/vz/vz.conf | cut -d= -f2 | tail -n1`/cache
#TGTMASTERLISTD=''

rm -fv "${TPLDIR}/${TPLNAME}.tar.gz"

# clean the container's data
echo "Cleaning the container's data.."
vzctl exec ${VEID} apt-get clean # debian only! this string should be commented for non debian-like linux
vzctl exec ${VEID} find /var/log -type f -name '*.[0-9]*' -exec rm -fv '{}' \\\;
vzctl exec ${VEID} find /var/log -type f -regex '.*_[0-9]+$' -exec rm -fv '{}' \\\;
vzctl exec ${VEID} find /var/log -type f -exec truncate --size 0 '{}' \\\;
#
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
