#!/bin/bash

# set up configuration file
cp /config/disease_diagnosis_config.yaml.template /config/disease_diagnosis_config.yaml

# unzip curl script to scripts directory
rm -rf /scripts/terminology_download_script
mkdir /scripts/terminology_download_script
unzip terminology_download_script.zip -d /scripts/terminology_download_script

cd /scripts

# get date info
CURRYEAR=$(date +"%Y")
LASTYEAR=$(($CURRYEAR-1)) 
CURRMONTH=$(date +"%m")
AA="AA"
AB="AB"
SUFFIX=12
ICDTOSNOMEDDATESTRING=$LASTYEAR$SUFFIX
if [ $CURRMONTH -lt 6 ]; then SNOMEDDATESTRING=$LASTYEAR$AB;
else SNOMEDDATESTRING=$CURRYEAR$AA ;
fi

# dos2unix /scripts and /R directories
find /scripts -type f -exec dos2unix -k -s -o {} ';'
find /R -type f -exec dos2unix -k -s -o {} ';'

# get usernames/passwords
cp /config/disease_diagnosis_credentials.yaml.template /config/disease_diagnosis_credentials.yaml

USERNAMESTRING=$(grep '^UMLSusername=' /config/disease_diagnosis_credentials.yaml) 
UMLSUSERNAME=${USERNAMESTRING#*=}
UMLSUSERNAME=${UMLSUSERNAME//[$'\t\r\n ']} 
PASSWORDSTRING=$(grep '^UMLSpassword=' /config/disease_diagnosis_credentials.yaml) 
UMLSPASSWORD=${PASSWORDSTRING#*=} 
UMLSPASSWORD=${UMLSPASSWORD//[$'\t\r\n ']}

USERNAMESTRING=$(grep '^MySQLusername=' /config/disease_diagnosis_credentials.yaml) 
MYSQLUSERNAME=${USERNAMESTRING#*=}
MYSQLUSERNAME=${MYSQLUSERNAME//[$'\t\r\n ']} 
PASSWORDSTRING=$(grep '^MySQLpassword=' /config/disease_diagnosis_credentials.yaml) 
MYSQLPASSWORD=${PASSWORDSTRING#*=} 
MYSQLPASSWORD=${MYSQLPASSWORD//[$'\t\r\n ']}

# add umls credentials to curl-uts-download.sh
sed -i "s/export UTS_USERNAME=/export UTS_USERNAME=$UMLSUSERNAME/g" terminology_download_script/curl-uts-download.sh
sed -i "s/export UTS_PASSWORD=/export UTS_PASSWORD=$UMLSPASSWORD/g" terminology_download_script/curl-uts-download.sh

# check if snomed->icd9 mapping file exists, if not build the file
if [ -f "/data/graphdb-import/ICD9CM_SNOMED_MAP_$ICDTOSNOMEDDATESTRING.ttl" ]; then

	echo "ICD9CM_SNOMED_MAP_$ICDTOSNOMEDDATESTRING.ttl already exists in /data/graphdb-import"

else

	echo "ICD9CM_SNOMED_MAP_$ICDTOSNOMEDDATESTRING.ttl does not exist in /data/graphdb-import"
	echo "Constructing ICD9CM_SNOMED_MAP_$ICDTOSNOMEDDATESTRING.ttl..."
	. ./gen_icd9tosnomed.sh

fi

# check if SNOMED file exists, if not build the file

if [ -f "/data/graphdb-import/SNOMEDCT_$SNOMEDDATESTRING.ttl" ]; then

	echo "SNOMEDCT_$SNOMEDDATESTRING.ttl already exists in /data/graphdb-import"

else

	echo "SNOMEDCT_$SNOMEDDATESTRING.ttl does not exist in /data/graphdb-import"
	echo "Constructing SNOMEDCT_$SNOMEDDATESTRING.ttl (this will take several hours)..."
	. ./genRRF.sh

	# Signal to MySQL db that RRF files are ready
	touch /data/umls-snomed/current_umls/RRF/mySqlGo.txt

	# Wait for MySQL to signal it is finished
	while [ ! -f /data/umls-snomed/current_umls/RRF/masterBuildGo.txt ]
	do
	  sleep 60
	  echo "builder is awaiting completion of the mysql process. Checking again in 60 seconds..."
	done

	#echo "builder found go signal"
	rm /data/umls-snomed/current_umls/RRF/masterBuildGo.txt

	# generate Turtle file from MySQL db using Python script
	sleep 30
	. ./mySql2Turtle.sh

	# tell mysql container to shutdown
	touch /data/umls-snomed/current_umls/RRF/mySqlQuit.txt
	sleep 10
	rm /data/umls-snomed/current_umls/RRF/mySqlQuit.txt

fi

# load GraphDb with files in import directory and additional ontologies
if [ -f "/data/graphdb-import/ICD9CM_SNOMED_MAP_$ICDTOSNOMEDDATESTRING.ttl" ] && [ -f "/data/graphdb-import/SNOMEDCT_$SNOMEDDATESTRING.ttl" ]; then
	. ./loadGraphDb.sh
else echo "Did not find ICD9CM_SNOMED_MAP_$ICDTOSNOMEDDATESTRING.ttl and SNOMEDCT_$SNOMEDDATESTRING.ttl in /data/graphdb-import; something went wrong!"
fi
echo "Pipeline complete"
