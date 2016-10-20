#!/bin/bash

VEID=91
TPLNAMEDIST=`vzctl exec ${VEID} lsb_release -ic | cut -d: -f2 | tr -s "\n\t " " " | sed -r 's#^ +| *$##g;s# #-#g'`
TPLNAMEVER=`vzctl exec ${VEID} lsb_release -r | cut -d: -f2 | tr -s "\n\t " " " | sed -r 's# +##g'`
TPLNAME=RHEL_${TPLNAMEVER}_amd64
#echo $TPLNAME
TPLDIR=`grep "^TEMPLATE" /etc/vz/vz.conf | cut -d= -f2 | tail -n1`/cache
#TGTMASTERLISTD=''

rm -fv "${TPLDIR}/${TPLNAME}.tar.gz"

# clean the container's data
echo "Cleaning the container's data.."
vzctl exec ${VEID} yum clean all # <- CentOS only! this string should be commented for non debian-like linux
vzctl exec ${VEID} rm -fv /var/lib/mysql/auto.cnf
vzctl exec ${VEID} find /var/log -type f -name '*.[0-9]*' -exec rm -fv '{}' \\\;
vzctl exec ${VEID} find /var/log -type f -regex '.*_[0-9]+$' -exec rm -fv '{}' \\\;
vzctl exec ${VEID} find /var/log -type f -exec truncate --size 0 '{}' \\\;
#
DIR="`dirname $0`"
pushd "${DIR}"
    DIR="`pwd`"
popd
"${DIR}/create-vz-template-from-CTID.sh" "${VEID}" "${TPLNAME}"
pushd /etc/vz/dists/
    ln -sv rhel.conf "${TPLNAME}.tar.gz.conf"
popd

