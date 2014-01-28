#!/bin/sh -ex
ntpdate ntp.xs4all.nl
iptables -F INPUT
yum install -y pycairo postgresql-server postgresql-libs screen bitmap-fonts mod_wsgi
rpm -i --nodeps *.rpm
service postgresql initdb
service postgresql start

useradd --system pdns

su postgres -c 'createuser -D -R -S pdns'
su postgres -c 'createdb -O pdns pdns'
su pdns -c 'psql pdns' < schema.sql
su pdns -c 'psql pdns' << __EOF__
INSERT INTO domains (id, name, type) VALUES(1, 'example.com', 'NATIVE');
INSERT INTO records (domain_id, name, type, content) VALUES(1, 'example.com', 'SOA', 'ns.example.com hostmaster.example.com 1 3600 3600 3600 3600');
INSERT INTO records (domain_id, name, type, content) VALUES(1, 'www.example.com', 'A', '1.2.3.4');
__EOF__
su postgres -c 'createuser -D -R -S pdnscontrol'
su postgres -c 'createdb -O pdnscontrol pdnscontrol'

cat > /opt/pdnscontrol/instance/pdnscontrol.conf << __EOF__
DATABASE_URI = 'postgresql://pdnscontrol@/pdnscontrol'
GRAPHITE_SERVER = 'http://172.16.68.167:8085/render/'
SECRET_KEY = $(python -c 'import os; print repr(os.urandom(24));')

serverlist_url = 'http://127.0.0.1:5000/servers.json'
pdnscontrol_user = 'graphite@example.org'
pdnscontrol_pass = 'notsecure'
__EOF__

cat > /etc/powerdns/pdns.conf << __EOF__
webserver=yes
webserver-password=web
experimental-json-interface=yes
launch=gpgsql
gpgsql-dbname=pdns
gpgsql-user=pdns
gpgsql-host=
setuid=pdns
__EOF__

cat > /etc/powerdns/recursor.conf << __EOF__
local-port=54
setuid=pdns
experimental-json-interface=yes
__EOF__

cat >> /etc/httpd/conf.d/wsgi.conf << __EOF__

WSGIPythonHome /opt/pdnscontrol
WSGIDaemonProcess pdnscontrol user=pdnscontrol group=pdnscontrol processes=2 threads=5
WSGIScriptAlias / /opt/pdnscontrol/instance/pdnscontrol.wsgi
WSGISocketPrefix /tmp
<Directory /opt/pdnscontrol>
        WSGIProcessGroup pdnscontrol
        WSGIApplicationGroup %{GLOBAL}
        Order deny,allow
        Allow from all
</Directory>

__EOF__

chown -R pdnscontrol /opt/pdnscontrol/pdnscontrol/static

su pdnscontrol -c '. /opt/pdnscontrol/bin/activate ; cd /opt/pdnscontrol/instance ; python install.py'
su pdnscontrol -c 'psql pdnscontrol' << __EOF__
INSERT INTO servers (name, daemon_type, stats_url, manager_url) VALUES('localhost-auth','Authoritative','http://x:web@127.0.0.1:8081/','http://x:web@127.0.0.1:8081/');
INSERT INTO servers (name, daemon_type, stats_url, manager_url) VALUES('localhost-rec','Recursor','http://127.0.0.1:8082/','http://127.0.0.1:8082/');
__EOF__

su graphite -c '. /opt/graphite/bin/activate ; cd /opt/graphite ; python webapp/graphite/manage.py syncdb'
