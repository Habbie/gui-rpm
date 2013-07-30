#!/bin/sh
cd /opt/pdnscontrol
bin/python manage.py assets --parse-templates build
su pdnscontrol -c 'cd /opt/pdnscontrol ; bin/python debug.py'
