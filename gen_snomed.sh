#!/bin/bash

DATESTRING=2019AB
SUFFIX="-full"
FILENAME=$DATESTRING$SUFFIX
FULLURI="https://download.nlm.nih.gov/umls/kss/$DATESTRING/umls-$FILENAME.zip"

if [ -d "/data/umls-snomed/$FILENAME" ]; then

	echo "$FILENAME already exists in /data/umls-snomed/"

else
	echo "$FILENAME does not exist in /data/umls-snomed/"

	# add umls credentials to curl-uts-download.sh
	USERNAMESTRING=$(sed -n '1p' /config/umls_credentials.yaml) 
	USERNAME=${USERNAMESTRING#*=}
	USERNAME=${USERNAME//[$'\t\r\n ']} 
	sed -i "s/export UTS_USERNAME=/export UTS_USERNAME=$USERNAME/g" curl-uts-download.sh
	PASSWORDSTRING=$(sed -n '2p' /config/umls_credentials.yaml) 
	PASSWORD=${PASSWORDSTRING#*=} 
	PASSWORD=${PASSWORD//[$'\t\r\n ']} 
	sed -i "s/export UTS_PASSWORD=/export UTS_PASSWORD=$PASSWORD/g" curl-uts-download.sh

	sh curl-uts-download.sh $FULLURI
	mv $FILENAME /data/umls-snomed/$FILENAME
	DOTZIP=".zip"
	unzip /data/umls-snomed/$FILENAME$DOTZIP
	unzip /data/umls-snomed/$FILENAME/mmsys.zip

fi

ls -la
pwd
cp metamorphosys_snomed_sample.prop metamorphosys_snomed.prop
cp metamorphosys_batch.sh.template metamorphosys_batch.sh

sed -i "s@METADIR=/data/umls-snomed/@METADIR=/data/umls-snomed/$FILENAME/@g" metamorphosys_batch.sh
sed -i "s@MMSYS_HOME=/data/umls-snomed/@MMSYS_HOME=/data/umls-snomed/$FILENAME/@g" metamorphosys_batch.sh

sed -i "s@release_version=2019AB@release_version=$DATESTRING@g" metamorphosys_snomed.prop
sed -i "s@gov.nih.nlm.umls.mmsys.io.RRFMetamorphoSysOutputStream.subset_dir=/Users/markampa/disease_to_diagnosis_code/terminology_download_script/2019AB-subset/terminology_download_script/2019AB/META@gov.nih.nlm.umls.mmsys.io.RRFMetamorphoSysOutputStream.subset_dir=/data/umls-snomed/$DATESTRING-subset/terminology_download_script/$DATESTRING/META@g" metamorphosys_snomed.prop
sed -i "s@meta_destination_uri=/Users/markampa/disease_to_diagnosis_code/terminology_download_script/2019AB-subset/terminology_download_script/2019AB/META@meta_destination_uri=/data/umls-snomed/$DATESTRING-subset/terminology_download_script/$DATESTRING/META@g" metamorphosys_snomed.prop
sed -i "s@default_subset_config_uri=/Users/markampa/disease_to_diagnosis_code/metamorphosys_snomed_sample.prop@default_subset_config_uri=./metamorphosys_snomed.prop@g" metamorphosys_sample.prop
sed -i "s@meta_source_uri=/Users/markampa/disease_to_diagnosis_code/terminology_download_script/2019AB-full@meta_source_uri=/data/umls-snomed/$FILENAME@g" metamorphosys_snomed.prop
sed -i "s@umls_destination_uri=/Users/markampa/disease_to_diagnosis_code/terminology_download_script/2019AB-subset/terminology_download_script@umls_destination_uri=/data/umls-snomed/$DATESTRING-subset/terminology_download_script@g" metamorphosys_snomed.prop
sed -i "s@gov.nih.nlm.umls.mmsys.io.NLMFileMetamorphoSysInputStream.meta_source_uri=/Users/markampa/disease_to_diagnosis_code/terminology_download_script/2019AB-full@gov.nih.nlm.umls.mmsys.io.NLMFileMetamorphoSysInputStream.meta_source_uri=/data/umls-snomed/$FILENAME@g" metamorphosys_snomed.prop

./metamorphosys_batch.sh