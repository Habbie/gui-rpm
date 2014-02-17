#!/bin/sh -e -x
#rm -f pdns-control-*.rpm pdns-graphite-*.rpm
#scp pdnsdev.powerdns.com:gui-rpm/*.rpm .
ansible-playbook -i ansible-hosts deploy.yml