#!/bin/bash

CURRYEAR=$(date +"%Y") 
LASTYEAR=$(($CURRYEAR-1)) 
CURRMONTH=$(date +"%m")
AA="AA"
AB="AB"

if [ $CURRMONTH -lt 6 ]; then DATESTRING=$LASTYEAR$AB;
else DATESTRING=$CURRYEAR$AA ;
fi

if [ -f "/var/lib/mysql/graphdb-import/SNOMEDCT_$DATESTRING.ttl" ]; then

	echo "File SNOMEDCT_$DATESTRING.ttl already exists in /data/graphdb-import"

else

	# wait for master_builder.sh to signal RRF files are ready
	while [ ! -f /var/lib/mysql/umls-snomed/current_umls/RRF/mySqlGo.txt ]
	do
	  sleep 60
	  echo "mysql is awaiting completion of the RRF generation process. Checking again in 60 seconds..."
	done

	echo "mysql found go signal; initializing database..."
	# init mysql database
	. /scripts/init_maria_db.sh

	cd /var/lib/mysql/umls-snomed/current_umls/RRF
	rm mySqlGo.txt

	cp /scripts/populate_mysql.sh.template /var/lib/mysql/umls-snomed/current_umls/RRF/populate_mysql.sh
	dos2unix populate_mysql.sh
	dos2unix mysql_tables.sql
	dos2unix mysql_indexes.sql

	# change mysql_tables.sql to use linux line endings
	sed -i "s@lines terminated by '\\\r\\\n'@lines terminated by '\\\n'@g" mysql_tables.sql

	USERNAMESTRING=$(grep '^MySQLusername=' /config/disease_diagnosis_credentials.yaml) 
	MYSQLUSERNAME=${USERNAMESTRING#*=}
	MYSQLUSERNAME=${MYSQLUSERNAME//[$'\t\r\n ']} 
	PASSWORDSTRING=$(grep '^MySQLpassword=' /config/disease_diagnosis_credentials.yaml) 
	MYSQLPASSWORD=${PASSWORDSTRING#*=} 
	MYSQLPASSWORD=${MYSQLPASSWORD//[$'\t\r\n ']}

	sed -i "s@MYSQL_HOME=<path to MYSQL_HOME>@MYSQL_HOME=/usr@g" populate_mysql.sh
	sed -i "s@user=<username>@user=$MYSQLUSERNAME@g" populate_mysql.sh
	sed -i "s@password=<password>@password=$MYSQLPASSWORD@g" populate_mysql.sh
	sed -i "s@db_name=<db_name>@db_name=umls_db@g" populate_mysql.sh

	echo "starting populate mysql script"
	sh populate_mysql.sh
	echo "finished populate mysql script"
	rm populate_mysql.sh
	pwd
	ls -la

	touch /var/lib/mysql/umls-snomed/current_umls/RRF/masterBuildGo.txt

	while [ ! -f /var/lib/mysql/umls-snomed/current_umls/RRF/mySqlQuit.txt ]
	do
	  sleep 5
	done
	echo "MySql received shutdown signal"
fi