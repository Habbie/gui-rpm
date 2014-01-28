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
gunicorn
django-tagging
requests
__EOF__

pushd /opt/graphite/conf
cp carbon.conf.example carbon.conf
cp storage-schemas.conf.example storage-schemas.conf
cp graphite.wsgi.example graphite_wsgi.py
rm /opt/graphite/lib/python2.6/no-global-site-packages.txt

popd

PDIR=$(mktemp -d)
mkdir -p ${PDIR}/opt
mkdir -p ${PDIR}/etc/init
rsync -a /opt/graphite/ ${PDIR}/opt/graphite/
cp graphite-carbon-cache-init ${PDIR}/etc/init/graphite-carbon-cache.conf
cp graphite-web-init ${PDIR}/etc/init/graphite-web.conf

fpm -s dir -t rpm -C ${PDIR} -n pdns-graphite -v $(date +%s) -d pycairo -d bitmap-fonts --after-install postinst-graphite .
