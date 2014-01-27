#!/bin/sh -ex
rm -rf /opt/pdnscontrol
[ ! -d /opt/pdnscontrol ]
pushd /opt
git clone https://github.com/PowerDNS/pdnscontrol.git pdnscontrol
virtualenv /opt/pdnscontrol
. /opt/pdnscontrol/bin/activate
pip install -r /opt/pdnscontrol/requirements.txt

mkdir /opt/pdnscontrol/var
ln -s ../instance /opt/pdnscontrol/var/pdnscontrol-instance

popd

chown -R pdnscontrol:pdnscontrol /opt/pdnscontrol
fpm -s dir -t rpm -n pdns-control -v $(date +%s) -d postgresql-libs --after-install postinst-pdnscontrol /opt/pdnscontrol/
