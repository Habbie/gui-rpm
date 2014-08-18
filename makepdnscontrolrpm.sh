#!/bin/sh -ex
rm -rf /opt/pdnscontrol
[ ! -d /opt/pdnscontrol ]
pushd /opt
git clone https://github.com/PowerDNS/pdnscontrol.git pdnscontrol
pushd pdnscontrol
GITVER=$(git describe --always --dirty=+)
popd
virtualenv /opt/pdnscontrol
. /opt/pdnscontrol/bin/activate
pip install --allow-external argparse -r /opt/pdnscontrol/requirements.txt

mkdir /opt/pdnscontrol/var
ln -s ../instance /opt/pdnscontrol/var/pdnscontrol-instance

popd

PDIR=$(mktemp -d)
mkdir -p ${PDIR}/opt
mkdir -p ${PDIR}/etc/init
rsync -a /opt/pdnscontrol/ ${PDIR}/opt/pdnscontrol/
cp pdnscontrol-init ${PDIR}/etc/init/pdnscontrol.conf
cp pdnsmgrd-init ${PDIR}/etc/init/pdnsmgrd.conf
cp pdns2graphite-init ${PDIR}/etc/init/pdns2graphite.conf
fpm -s dir -t rpm -C ${PDIR} -x opt/pdnscontrol/pdnsmgrd -x etc/init/pdnsmgrd.conf -n pdns-control -v $(date +%s)-${GITVER} -d postgresql-libs --after-install postinst-pdnscontrol .
fpm -s dir -t rpm -C ${PDIR} -n pdns-mgrd -v $(date +%s)-${GITVER} opt/pdnscontrol/pdnsmgrd etc/init/pdnsmgrd.conf
