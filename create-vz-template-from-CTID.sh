#/bin/bash

TEMPLDIR=`grep "^TEMPLATE" /etc/vz/vz.conf | cut -d= -f2`
VZVECONF="/etc/vz/conf/$1.conf"
test -f "${VZVECONF}" || VZVECONF="/etc/vz/conf/$1.conf"
VEDIR=`grep "^VE_PRIVATE" "${VZVECONF}" | cut -d= -f2 | cut -d\" -f2 | sed -e "s#\\$VEID#$1#g"`
vzctl stop $1
pushd $VEDIR
    echo "Archiving image with tar..."
    tar --numeric-owner --exclude "etc/ssh/ssh_host_*_key*" --exclude "var/log/*" --exclude "root/.ssh/id*" \
	 --exclude ".bash_history" --exclude "etc/puppet/ssl" --exclude "var/lib/puppet" \
	 --exclude "/var/lib/itim/monitoring/reboot" --exclude "/rest" -zcf $TEMPLDIR/cache/$2.tar.gz .
    echo "done.
popd
ls -lsh "$TEMPLDIR/cache/$2.tar.gz"
vzctl start $1
#grep -v "^IP_ADDRESS\|^HOSTNAME" /etc/vz/conf/$1.conf > /etc/vz/conf/ve-$2.conf-sample
