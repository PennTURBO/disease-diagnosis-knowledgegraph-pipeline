#!/bin/bash

cd /data/graphdb-import

# Update config file with connection details
sed -i "s@graphdb.address.port: 'http://localhost:7200'@graphdb.address.port: 'http://graphdb:7200'@g" /config/disease_diagnosis_config.yaml
sed -i "s@snomed.triples.file: 'SNOMEDCT_2019AB_codes.ttl'@snomed.triples.file: 'SNOMEDCT_$SNOMEDDATESTRING.ttl'@g" /config/disease_diagnosis_config.yaml
sed -i "s@icd9_to_snomed.triples.file: 'ICD9CM_SNOMED_MAP_201812.ttl'@icd9_to_snomed.triples.file: 'ICD9CM_SNOMED_MAP_$ICDTOSNOMEDDATESTRING.ttl'@g" /config/disease_diagnosis_config.yaml
sed -i "s@delete.isolated.flag: false@delete.isolated.flag: true@g" /config/disease_diagnosis_config.yaml

# Create the repository
curl -X POST\
    http://graphdb:7200/rest/repositories\
    -H 'Content-Type: multipart/form-data'\
    -F "config=@/config/disease-repo-config-se.ttl"

Rscript /R/disease_diagnosis_dev.R