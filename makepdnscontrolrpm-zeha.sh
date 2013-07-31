#!/bin/bash -ex
rm -rf /opt/pdnscontrol
[ ! -d /opt/pdnscontrol ]
pushd /opt
git clone https://github.com/zeha/pdnscontrol.git pdnscontrol
virtualenv /opt/pdnscontrol
. /opt/pdnscontrol/bin/activate
#xargs -n1 pip install << __EOF__
#Flask==0.10.1
#Flask-Assets==0.8
#Flask-SQLAlchemy==0.16
#Flask-Security==1.6.7
#requests==1.2.3
#MySQL-python
#psycopg2
#__EOF__

# for MySQL-python on Debian
pip install 'distribute>=0.6.28'
pip install -r /opt/pdnscontrol/requirements.txt

mkdir /opt/pdnscontrol/var
ln -s ../instance /opt/pdnscontrol/var/pdnscontrol-instance

popd

IS_DEBIAN=$(lsb_release -a 2>/dev/null | egrep -c '(Debian|Ubuntu)' && true)
OUTPUT_FORMAT="rpm"
DEPS="postgresql-libs"
EXTRA=""
if [ $IS_DEBIAN ]; then
  OUTPUT_FORMAT="deb"
  DEPS="libpq5 libmysqlclient18 libc6 zlib1g python2.7"
  EXTRA="--deb-recommends libapache2-mod-wsgi"
fi

DEPS_OPTS=""
for d in $DEPS; do
  DEPS_OPTS="$DEPS_OPTS -d $d"
done

fpm -s dir -t $OUTPUT_FORMAT -n pdns-control -v $(date +%s) $DEPS_OPTS --after-install postinst-pdnscontrol $EXTRA /opt/pdnscontrol/
