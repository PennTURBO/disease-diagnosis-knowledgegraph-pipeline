#!/bin/bash

cd /data/snomed-icd9

if [ -f "/data/snomed-icd9/ICD9CM_SNOMED_MAP_1TO1_$ICDTOSNOMEDDATESTRING.txt" ] && [ -f "/data/snomed-icd9/ICD9CM_SNOMED_MAP_1TOM_$ICDTOSNOMEDDATESTRING.txt" ]; then

	echo "ICD9CM_SNOMED_MAP_1TO1_$ICDTOSNOMEDDATESTRING.txt and ICD9CM_SNOMED_MAP_1TOM_$ICDTOSNOMEDDATESTRING.txt already exist in /data/snomed-icd9/"

else

	echo "ICD9CM_SNOMED_MAP_1TO1_$ICDTOSNOMEDDATESTRING.txt and/or ICD9CM_SNOMED_MAP_1TOM_$ICDTOSNOMEDDATESTRING.txt do not exist in /data/snomed-icd9/"
	echo "Downloading from source..."

	rm -f "/data/snomed-icd9/ICD9CM_SNOMED_MAP_1TO1_$ICDTOSNOMEDDATESTRING.txt"
	rm -f "/data/snomed-icd9/ICD9CM_SNOMED_MAP_1TOM_$ICDTOSNOMEDDATESTRING.txt"

	# run curl-uts-download.sh and unzip downloaded file
	ICD9TOSNOMEDURL=https://download.nlm.nih.gov/umls/kss/mappings/ICD9CM_TO_SNOMEDCT/ICD9CM_TO_SNOMEDCT_DIAGNOSIS_$LASTYEAR 
	SUFFIX=12.zip 
	FULLURL=$ICD9TOSNOMEDURL$SUFFIX 
	sh /scripts/terminology_download_script/curl-uts-download.sh $FULLURL
	NEWFILEPREFIX=ICD9CM_TO_SNOMEDCT_DIAGNOSIS_
	NEWFILENAME=$NEWFILEPREFIX$LASTYEAR$SUFFIX
	unzip $NEWFILENAME

fi

# set up config file for R script
sed -i "s@ICD9CM_SNOMED_MAP_1TO1.path: \"terminology_download_script/ICD9CM_SNOMED_MAP_1TO1_201812.txt\"@ICD9CM_SNOMED_MAP_1TO1.path: \"ICD9CM_SNOMED_MAP_1TO1_$ICDTOSNOMEDDATESTRING.txt\"@g" /config/disease_diagnosis_config.yaml 
sed -i "s@ICD9CM_SNOMED_MAP_1TOM.path: \"terminology_download_script/ICD9CM_SNOMED_MAP_1TOM_201812.txt\"@ICD9CM_SNOMED_MAP_1TOM.path: \"ICD9CM_SNOMED_MAP_1TOM_$ICDTOSNOMEDDATESTRING.txt\"@g" /config/disease_diagnosis_config.yaml 
sed -i "s@ICD9CM_SNOMED_MAP.filepath:  \"ICD9CM_SNOMED_MAP_201812.ttl\"@ICD9CM_SNOMED_MAP.filepath:  \"ICD9CM_SNOMED_MAP_$ICDTOSNOMEDDATESTRING.ttl\"@g" /config/disease_diagnosis_config.yaml 
sed -i "s@icd9_to_snomed.triples.file: 'ICD9CM_SNOMED_MAP_201812.ttl'@icd9_to_snomed.triples.file: \"ICD9CM_SNOMED_MAP_$ICDTOSNOMEDDATESTRING.ttl\"@g" /config/disease_diagnosis_config.yaml

# run Mark's R script to generate triples from downloaded file
Rscript /R/ICD9CM_SNOMED_MAP-to-RDF.R

# head and tail output of triples file
head ICD9CM_SNOMED_MAP_$ICDTOSNOMEDDATESTRING.ttl 
tail ICD9CM_SNOMED_MAP_$ICDTOSNOMEDDATESTRING.ttl 
ls -la

# move generated file to mounted /data folder
mv ICD9CM_SNOMED_MAP_$ICDTOSNOMEDDATESTRING.ttl /data/snomed-icd9/RDF/ICD9CM_SNOMED_MAP_$ICDTOSNOMEDDATESTRING.ttl
# copy to graphdb-import directory
cp /data/snomed-icd9/RDF/ICD9CM_SNOMED_MAP_$ICDTOSNOMEDDATESTRING.ttl /data/graphdb-import/ICD9CM_SNOMED_MAP_$ICDTOSNOMEDDATESTRING.ttl

cd /scripts