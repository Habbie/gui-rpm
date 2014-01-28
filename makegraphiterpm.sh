#!/bin/sh -ex
rm -rf /opt/graphite
[ ! -d /opt/graphite ]
virtualenv /opt/graphite
. /opt/graphite/bin/activate
xargs -n1 pip install << __EOF__
Django==1.3
Flask==0.9
Twisted<12.0
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
rm /opt/graphite/lib/python2.6/no-global-site-packages.txt

popd
fpm -s dir -t rpm -n pdns-graphite -v $(date +%s) -d pycairo -d bitmap-fonts --after-install postinst-graphite /opt/graphite/
