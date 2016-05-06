#!/bin/bash

# Written by demofly

SRCID="$1"
TGTID="$2"
DT=`date +'%y.%m.%d at %H:%M:%S'`

TEMPLDIR=`grep "^TEMPLATE" /etc/vz/vz.conf | cut -d= -f2`
SRCVZVECONF="/etc/vz/conf/${SRCID}.conf"
SRCVZVEMNT="/etc/vz/conf/${SRCID}.mount"
test -f "${SRCVZVECONF}" || exit 1
SRCROOT=`grep "^VE_ROOT" "${SRCVZVECONF}" | cut -d= -f2 | cut -d\" -f2 | sed -e "s#\\$VEID#${SRCID}#g"`
SRCPRIVATE=`grep "^VE_PRIVATE" "${SRCVZVECONF}" | cut -d= -f2 | cut -d\" -f2 | sed -e "s#\\$VEID#${SRCID}#g"`

TGTROOT=`echo "${SRCROOT}" | sed "s#${SRCID}#${TGTID}#"`
TGTPRIVATE=`echo "${SRCPRIVATE}" | sed "s#${SRCID}#${TGTID}#"`

VARROOT=`echo "${SRCROOT}" | sed "s#${SRCID}#\\$VEID#"`
VARPRIVATE=`echo "${SRCPRIVATE}" | sed "s#${SRCID}#\\$VEID#"`

TGTVZVECONF=`echo "${SRCVZVECONF}" | sed "s#${SRCID}\.#${TGTID}\.#"`
TGTVZVEMNT=`echo "${SRCVZVEMNT}" | sed "s#${SRCID}\.#${TGTID}\.#"`

# DEBUG

#echo "${SRCROOT} -> ${TGTROOT} | ${SRCPRIVATE} -> ${TGTPRIVATE} | ${VARROOT} ${VARPRIVATE}"
#grep "^VE_ROOT" "${SRCVZVECONF}" | sed -r "s#(^VE_ROOT.*)${SRCROOT}#\1${VARROOT}#"
#grep "^VE_PRIVATE" "${SRCVZVECONF}" | sed -r "s#(^VE_PRIVATE.*)${SRCPRIVATE}#\1${VARPRIVATE}#"
#grep "^NETIF" "${SRCVZVECONF}" | sed -r "s#veth${SRCID}\.#veth${TGTID}\.#"
#exit 0

# Main changes

echo "## Started on ${DT}"

# prepare

ALLOWSTART=`vzctl status ${SRCID} | grep running | wc -l`
vzctl stop ${SRCID}
vzquota drop ${SRCID}

# move data dirs

echo "## Moving data dirs:"

mv -v "${SRCROOT}" "${TGTROOT}"
mv -v "${SRCPRIVATE}" "${TGTPRIVATE}"

echo "## Fork the VE config to ${TGTVZVECONF}:"

cp -v "${SRCVZVECONF}" "${TGTVZVECONF}"
test -f "${SRCVZVEMNT}" && cp -v "${SRCVZVEMNT}" "${TGTVZVEMNT}"

# edit the VE config:

echo "## Editing ${TGTVZVECONF} .."

sed -r "s#(^VE_ROOT.*)${SRCROOT}#\1${VARROOT}#"                 -i "${TGTVZVECONF}"
sed -r "s#(^VE_PRIVATE.*)${SRCPRIVATE}#\1${VARPRIVATE}#"        -i "${TGTVZVECONF}"
sed -r "s#veth${SRCID}\.#veth${TGTID}\.#g"                      -i "${TGTVZVECONF}"

# Saving the source VE config to ${SRCVZVECONF}.destroy

echo "## Saving the source VE config to ${SRCVZVECONF}.destroy"
mv -fv "${SRCVZVECONF}" "${SRCVZVECONF}.destroy"
test -f "${SRCVZVEMNT}" && mv -vf "${SRCVZVEMNT}" "${SRCVZVEMNT}.destroy"

# The last accord:

if [[ "${ALLOWSTART}" == "1" ]]
then
    echo "## Starting CTID ${TGTID}:"
    vzctl start ${TGTID}
fi

echo "## Ended on `date +'%y.%m.%d at %H:%M:%S'`"
