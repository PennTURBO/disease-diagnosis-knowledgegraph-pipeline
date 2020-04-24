#!/bin/bash

cd /var/lib/mysql/umls-snomed/current_umls/RRF/

echo "    Initializing database ... `/bin/date`"
mysql_install_db --user=root
nohup /usr/sbin/mysqld -vvv -u root &

sleep 30
cat nohup.out