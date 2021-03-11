#!/bin/bash

cd /data/umls-snomed

SUFFIX="-full"
FILENAME=$SNOMEDDATESTRING$SUFFIX
FULLURI="https://download.nlm.nih.gov/umls/kss/$SNOMEDDATESTRING/umls-$FILENAME.zip"

rm -rf current_umls/

if [ -d "/data/umls-snomed/$FILENAME" ] && [ -d "/data/umls-snomed/$FILENAME/RRF" ]; then

	echo "Directory $FILENAME exists with RRF subdirectory in /data/umls-snomed"
	cp -r $FILENAME current_umls

else

	echo "Directory $FILENAME does not exist with RRF subdirectory in /data/umls-snomed"

	echo "Downloading large umls file"
	sh /scripts/build/curl-uts-downloads-apikey.sh $FULLURI
	echo "UMLS download complete"
	unzip umls-$FILENAME.zip

	mv $FILENAME current_umls
	cd current_umls/

	unzip mmsys.zip
	echo "Moved and unzipped files"

	chmod -R 777 /data/umls-snomed/current_umls

	mkdir /data/umls-snomed/current_umls/RRF/
	mkdir /data/umls-snomed/current_umls/RRF/META
	touch /data/umls-snomed/current_umls/RRF/META/mmsys.log

	cp /config/metamorphosys_snomed_sample.prop /config/metamorphosys_snomed.prop
	cp /scripts/metamorphosys_batch.sh.template /scripts/metamorphosys_batch.sh

	sed -i "s@METADIR=/data/umls-snomed/@METADIR=/data/umls-snomed/current_umls/@g" /scripts/metamorphosys_batch.sh
	sed -i "s@MMSYS_HOME=/data/umls-snomed/@MMSYS_HOME=/data/umls-snomed/current_umls/@g" /scripts/metamorphosys_batch.sh
	sed -i "s@release_version=2019AB@release_version=$SNOMEDDATESTRING@g" /config/metamorphosys_snomed.prop
	sed -i "s@gov.nih.nlm.umls.mmsys.io.RRFMetamorphoSysOutputStream.subset_dir=/Users/markampa/disease_to_diagnosis_code/terminology_download_script/2019AB-subset/terminology_download_script/2019AB/META@gov.nih.nlm.umls.mmsys.io.RRFMetamorphoSysOutputStream.subset_dir=/data/umls-snomed/current_umls/RRF@g" /config/metamorphosys_snomed.prop
	sed -i "s@meta_destination_uri=/Users/markampa/disease_to_diagnosis_code/terminology_download_script/2019AB-subset/terminology_download_script/2019AB/META@meta_destination_uri=/data/umls-snomed/current_umls/RRF/META@g" /config/metamorphosys_snomed.prop
	sed -i "s@default_subset_config_uri=/Users/markampa/disease_to_diagnosis_code/metamorphosys_snomed_sample.prop@default_subset_config_uri=/config/metamorphosys_snomed.prop@g" /config/metamorphosys_snomed.prop
	sed -i "s@meta_source_uri=/Users/markampa/disease_to_diagnosis_code/terminology_download_script/2019AB-full@meta_source_uri=/data/umls-snomed/current_umls@g" /config/metamorphosys_snomed.prop
	sed -i "s@umls_destination_uri=/Users/markampa/disease_to_diagnosis_code/terminology_download_script/2019AB-subset/terminology_download_script@umls_destination_uri=/data/umls-snomed/current_umls/RRF@g" /config/metamorphosys_snomed.prop
	sed -i "s@gov.nih.nlm.umls.mmsys.io.NLMFileMetamorphoSysInputStream.meta_source_uri=/Users/markampa/disease_to_diagnosis_code/terminology_download_script/2019AB-full@gov.nih.nlm.umls.mmsys.io.NLMFileMetamorphoSysInputStream.meta_source_uri=/data/umls-snomed/current_umls@g" /config/metamorphosys_snomed.prop

	echo "Running metamorphosys"
	sh /scripts/metamorphosys_batch.sh
	echo "Finished metamorphosys; RRF files generated"

	echo "Converting .RRF files to Unix format..."
	cd RRF/
	find . -type f -name "*.RRF" -print0 | xargs -0 dos2unix

	echo "Archiving RRF files for $FILENAME	instantiation"
	cp -r /data/umls-snomed/current_umls /data/umls-snomed/$FILENAME

	# cleanup
	rm /config/metamorphosys_snomed.prop
	rm /scripts/metamorphosys_batch.sh

fi

cd /scripts