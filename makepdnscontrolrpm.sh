#!/bin/sh -ex
rm -rf /opt/pdnscontrol
[ ! -d /opt/pdnscontrol ]
pushd /opt
git clone https://github.com/PowerDNS/pdnscontrol.git pdnscontrol
virtualenv /opt/pdnscontrol
. /opt/pdnscontrol/bin/activate
cat /opt/pdnscontrol/requirements.txt
pip install --allow-external argparse -r /opt/pdnscontrol/requirements.txt

mkdir /opt/pdnscontrol/var
ln -s ../instance /opt/pdnscontrol/var/pdnscontrol-instance

popd

PDIR=$(mktemp -d)
mkdir -p ${PDIR}/opt
mkdir -p ${PDIR}/etc/init
rsync -a /opt/pdnscontrol/ ${PDIR}/opt/pdnscontrol/
cp pdnscontrol-init ${PDIR}/etc/init/pdnscontrol.conf
fpm -s dir -t rpm -C ${PDIR} -n pdns-control -v $(date +%s) -d postgresql-libs --after-install postinst-pdnscontrol .
