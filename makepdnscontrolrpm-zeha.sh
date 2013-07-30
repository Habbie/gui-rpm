#!/bin/sh -ex
rm -rf /opt/pdnscontrol
[ ! -d /opt/pdnscontrol ]
pushd /opt
git clone https://github.com/zeha/pdnscontrol.git pdnscontrol
virtualenv /opt/pdnscontrol
. /opt/pdnscontrol/bin/activate
xargs -n1 pip install << __EOF__
Flask==0.10.1
Flask-Assets==0.8
Flask-SQLAlchemy==0.16
Flask-Security==1.6.7
requests==1.2.3
MySQL-python
psycopg2
__EOF__

mkdir /opt/pdnscontrol/var
ln -s ../instance /opt/pdnscontrol/var/pdnscontrol-instance

popd

chown -R pdnscontrol:pdnscontrol /opt/pdnscontrol
fpm -s dir -t rpm -n pdns-control -v $(date +%s) -d postgresql-libs --after-install postinst-pdnscontrol /opt/pdnscontrol/
