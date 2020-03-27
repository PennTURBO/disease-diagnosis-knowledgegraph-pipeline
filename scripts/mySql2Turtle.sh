#!/bin/bash

cd /scripts

if [ -d "umls2rdf" ]; then
	echo "Directory umls2rdf already cloned in /data/umls-snomed/current-umls/RRF"
else
	echo "Directory umls2rdf not found in /data/umls-snomed/current-umls/RRF. Cloning into repo..."
	git clone https://github.com/ncbo/umls2rdf.git
fi 

rm -rf /data/umls-snomed/current_umls/umls2rdf
cp -r /scripts/umls2rdf /data/umls-snomed/current_umls/umls2rdf
cd /data/umls-snomed/current_umls

rm -rf RDF
mkdir RDF

rm -rf umls.conf
touch umls.conf
echo "SNOMEDCT_US;SNOMEDCT,SNOMEDCT.ttl,load_on_codes" >> umls.conf

cd umls2rdf
rm -rf conf.py
cp conf_sample.py conf.py 

sed -i 's@OUTPUT_FOLDER = "output"@OUTPUT_FOLDER = "/data/umls-snomed/current_umls/RDF"@g' conf.py
sed -i 's@DB_HOST = "your-host"@DB_HOST = "mysql"@g' conf.py
sed -i 's@DB_NAME = "umls2015ab"@DB_NAME = "umls_db"@g' conf.py
sed -i "s@DB_USER = \"your db user\"@DB_USER = \"$MYSQLUSERNAME\"@g" conf.py
sed -i "s@DB_PASS = \"your db pass\"@DB_PASS = \"$MYSQLPASSWORD\"@g" conf.py
sed -i "s@UMLS_VERSION = \"2015ab\"@UMLS_VERSION = \"$DATESTRING\"@g" conf.py
sed -i 's@INCLUDE_SEMANTIC_TYPES = True@INCLUDE_SEMANTIC_TYPES = False@g' conf.py

python umls2rdf.py
echo "finished umls2rdf script"

# copy files to graphdb-import directory and rename to be date-specific
cp /data/umls-snomed/current_umls/RDF/SNOMEDCT.ttl /data/graphdb-import/SNOMEDCT_$DATESTRING.ttl

cd /scripts