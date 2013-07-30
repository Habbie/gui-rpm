#!/bin/sh -ex
rm -rf /opt/pdnscontrol
[ ! -d /opt/pdnscontrol ]
pushd /opt
git clone https://github.com/zeha/pdnscontrol.git pdnscontrol
virtualenv /opt/pdnscontrol
. /opt/pdnscontrol/bin/activate
#xargs -n1 pip install << __EOF__
#flask==0.9
#requests==0.14.2
#Flask-Assets==0.7
#webassets==0.7.1
#Flask-SQLAlchemy==0.16
#SQLAlchemy==0.7.9
#MySQL-python
#psycopg2
#__EOF__
pip install -r /opt/pdnscontrol/requirements.txt

mkdir /opt/pdnscontrol/var
ln -s ../instance /opt/pdnscontrol/var/pdnscontrol-instance

popd

chown -R pdnscontrol:pdnscontrol /opt/pdnscontrol
fpm -s dir -t rpm -n pdns-control -v $(date +%s) -d postgresql-libs --after-install postinst-pdnscontrol /opt/pdnscontrol/
