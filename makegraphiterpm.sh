#!/bin/bash -ex
rm -rf /opt/graphite
[ ! -d /opt/graphite ]
virtualenv /opt/graphite
. /opt/graphite/bin/activate
xargs -n1 pip install << __EOF__
Django==1.3
Flask==0.9
graphite-web
carbon
whisper
uwsgi
django-tagging
requests
__EOF__

pushd /opt/graphite/conf
cp carbon.conf.example carbon.conf
cp storage-schemas.conf.example storage-schemas.conf
rm /opt/graphite/lib/python2.*/no-global-site-packages.txt

popd

IS_DEBIAN=$(lsb_release -a 2>/dev/null | egrep -c '(Debian|Ubuntu)' && true)
OUTPUT_FORMAT="rpm"
DEPS="bitmap-fonts pycairo"
EXTRA=""
if [ $IS_DEBIAN ]; then
  OUTPUT_FORMAT="deb"
  DEPS="python-cairo python"
fi

DEPS_OPTS=""
for d in $DEPS; do
  DEPS_OPTS="$DEPS_OPTS -d $d"
done

fpm -s dir -t $OUTPUT_FORMAT -n pdns-graphite -v $(date +%s) $DEPS_OPTS --after-install postinst-graphite /opt/graphite/
