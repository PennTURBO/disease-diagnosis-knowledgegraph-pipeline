#!/bin/bash

CURRYEAR=$(date +"%Y") 
LASTYEAR=$(($CURRYEAR-1)) 
SUFFIX=12
DATESTRING=$LASTYEAR$SUFFIX

if [ -f "/data/snomed-icd9/RDF/ICD9CM_SNOMED_MAP_$DATESTRING.ttl" ]; then

	echo "ICD9CM_SNOMED_MAP_$DATESTRING.ttl already exists in /data/snomed-icd9/RDF/"

else

	echo "ICD9CM_SNOMED_MAP_$DATESTRING.ttl does not exist in /data/snomed-icd9/RDF/"
	echo "Constructing ICD9CM_SNOMED_MAP_$DATESTRING.ttl..."

	if [ -f "/data/snomed-icd9/ICD9CM_SNOMED_MAP_1TO1_$DATESTRING.txt" ] && [ -f "/data/snomed-icd9/ICD9CM_SNOMED_MAP_1TOM_$DATESTRING.txt" ]; then

		echo "ICD9CM_SNOMED_MAP_1TO1_$DATESTRING.txt and ICD9CM_SNOMED_MAP_1TOM_$DATESTRING.txt already exist in /data/snomed-icd9/"
		cp /data/snomed-icd9/ICD9CM_SNOMED_MAP_1TO1_$DATESTRING.txt ICD9CM_SNOMED_MAP_1TO1_$DATESTRING.txt
		cp /data/snomed-icd9/ICD9CM_SNOMED_MAP_1TOM_$DATESTRING.txt ICD9CM_SNOMED_MAP_1TOM_$DATESTRING.txt

	else

		echo "ICD9CM_SNOMED_MAP_1TO1_$DATESTRING.txt and/or ICD9CM_SNOMED_MAP_1TOM_$DATESTRING.txt do not exist in /data/snomed-icd9/"
		echo "Downloading from source..."

		rm -f "/data/snomed-icd9/ICD9CM_SNOMED_MAP_1TO1_$DATESTRING.txt"
		rm -f "/data/snomed-icd9/ICD9CM_SNOMED_MAP_1TOM_$DATESTRING.txt"

		# add umls credentials to curl-uts-download.sh
		USERNAMESTRING=$(sed -n '1p' /config/umls_credentials.yaml) 
		USERNAME=${USERNAMESTRING#*=}
		USERNAME=${USERNAME//[$'\t\r\n ']} 
		sed -i "s/export UTS_USERNAME=/export UTS_USERNAME=$USERNAME/g" curl-uts-download.sh
		PASSWORDSTRING=$(sed -n '2p' /config/umls_credentials.yaml) 
		PASSWORD=${PASSWORDSTRING#*=} 
		PASSWORD=${PASSWORD//[$'\t\r\n ']} 
		sed -i "s/export UTS_PASSWORD=/export UTS_PASSWORD=$PASSWORD/g" curl-uts-download.sh

		# run curl-uts-download.sh and unzip downloaded file
		ICD9TOSNOMEDURL=https://download.nlm.nih.gov/umls/kss/mappings/ICD9CM_TO_SNOMEDCT/ICD9CM_TO_SNOMEDCT_DIAGNOSIS_$LASTYEAR 
		SUFFIX=12.zip 
		FULLURL=$ICD9TOSNOMEDURL$SUFFIX 
		sh curl-uts-download.sh $FULLURL
		NEWFILEPREFIX=ICD9CM_TO_SNOMEDCT_DIAGNOSIS_
		NEWFILENAME=$NEWFILEPREFIX$LASTYEAR$SUFFIX
		unzip $NEWFILENAME

		# copy downloaded files to mounted /data directory
		cp ICD9CM_SNOMED_MAP_1TO1_$DATESTRING.txt /data/snomed-icd9/ICD9CM_SNOMED_MAP_1TO1_$DATESTRING.txt
		cp ICD9CM_SNOMED_MAP_1TOM_$DATESTRING.txt /data/snomed-icd9/ICD9CM_SNOMED_MAP_1TOM_$DATESTRING.txt
	
	fi

	# set up config file for R script
	sed -i "s@ICD9CM_SNOMED_MAP_1TO1.path: \"terminology_download_script/ICD9CM_SNOMED_MAP_1TO1_201812.txt\"@ICD9CM_SNOMED_MAP_1TO1.path: \"ICD9CM_SNOMED_MAP_1TO1_$DATESTRING.txt\"@g" /config/disease_diagnosis_config.yaml 
	sed -i "s@ICD9CM_SNOMED_MAP_1TOM.path: \"terminology_download_script/ICD9CM_SNOMED_MAP_1TOM_201812.txt\"@ICD9CM_SNOMED_MAP_1TOM.path: \"ICD9CM_SNOMED_MAP_1TOM_$DATESTRING.txt\"@g" /config/disease_diagnosis_config.yaml 
	sed -i "s@ICD9CM_SNOMED_MAP.filepath:  \"ICD9CM_SNOMED_MAP_201812.ttl\"@ICD9CM_SNOMED_MAP.filepath:  \"ICD9CM_SNOMED_MAP_$DATESTRING.ttl\"@g" /config/disease_diagnosis_config.yaml 
	sed -i "s@icd9_to_snomed.triples.file: 'ICD9CM_SNOMED_MAP_201812.ttl'@icd9_to_snomed.triples.file: \"ICD9CM_SNOMED_MAP_$DATESTRING.ttl\"@g" /config/disease_diagnosis_config.yaml

	# run Mark's R script to generate triples from downloaded file
	Rscript ICD9CM_SNOMED_MAP-to-RDF.R

	# head and tail output of triples file
	head ICD9CM_SNOMED_MAP_$DATESTRING.ttl 
	tail ICD9CM_SNOMED_MAP_$DATESTRING.ttl 
	ls -la

	# move generated file to mounted /data folder
	mv ICD9CM_SNOMED_MAP_$DATESTRING.ttl /data/snomed-icd9/RDF/ICD9CM_SNOMED_MAP_$DATESTRING.ttl

fi