FROM r-base:3.6.2

# switch to bash from dash
RUN ln -s bash /bin/sh.bash
RUN mv /bin/sh.bash /bin/sh

# import R packages
RUN apt-get update; apt-get -y install pkg-config libxml2-dev libcurl4-gnutls-dev libssl-dev librasqal3-dev libraptor2-dev librdf0-dev libv8-dev
RUN Rscript -e 'install.packages(c("config", "httr", "igraph", "SPARQL", "rdflib", "tibble", "uuid", "config"))'

# install curl
RUN apt-get update; apt-get -y install curl

# add source files
COPY disease_diagnosis_dev.R /appsrc/
COPY ICD9CM_SNOMED_MAP-to-RDF.R /appsrc/

# set up configuration files
WORKDIR /config
COPY config/umls_credentials.yaml .
COPY config/disease-repo-config-se.ttl .
COPY config/disease_diagnosis_config.yaml.template .
RUN cp disease_diagnosis_config.yaml.template disease_diagnosis_config.yaml

RUN CURRYEAR=$(date +"%Y") && LASTYEAR=$(($CURRYEAR-1)) && SUFFIX=12 && DATESTRING=$LASTYEAR$SUFFIX && sed -i "s@ICD9CM_SNOMED_MAP_1TO1.path: \"terminology_download_script/ICD9CM_SNOMED_MAP_1TO1_201812.txt\"@ICD9CM_SNOMED_MAP_1TO1.path: \"ICD9CM_SNOMED_MAP_1TO1_$DATESTRING.txt\"@g" disease_diagnosis_config.yaml && sed -i "s@ICD9CM_SNOMED_MAP_1TOM.path: \"terminology_download_script/ICD9CM_SNOMED_MAP_1TOM_201812.txt\"@ICD9CM_SNOMED_MAP_1TOM.path: \"ICD9CM_SNOMED_MAP_1TOM_$DATESTRING.txt\"@g" disease_diagnosis_config.yaml && sed -i "s@ICD9CM_SNOMED_MAP.filepath:  \"ICD9CM_SNOMED_MAP_201812.ttl\"@ICD9CM_SNOMED_MAP.filepath:  \"ICD9CM_SNOMED_MAP_$DATESTRING.ttl\"@g" disease_diagnosis_config.yaml

WORKDIR /appsrc
ADD http://download.nlm.nih.gov/rxnorm/terminology_download_script.zip .
RUN unzip terminology_download_script.zip
RUN USERNAMESTRING=$(sed -n '1p' /config/umls_credentials.yaml) && USERNAME=${USERNAMESTRING#*=} && USERNAME=${USERNAME//[$'\t\r\n ']} && sed -i "s/export UTS_USERNAME=/export UTS_USERNAME=$USERNAME/g" curl-uts-download.sh
RUN PASSWORDSTRING=$(sed -n '2p' /config/umls_credentials.yaml) && PASSWORD=${PASSWORDSTRING#*=} && PASSWORD=${PASSWORD//[$'\t\r\n ']} && sed -i "s/export UTS_PASSWORD=/export UTS_PASSWORD=$PASSWORD/g" curl-uts-download.sh

RUN CURRYEAR=$(date +"%Y") && LASTYEAR=$(($CURRYEAR-1)) && ICD9TOSNOMEDURL=https://download.nlm.nih.gov/umls/kss/mappings/ICD9CM_TO_SNOMEDCT/ICD9CM_TO_SNOMEDCT_DIAGNOSIS_$LASTYEAR && SUFFIX=12.zip && FULLURL=$ICD9TOSNOMEDURL$SUFFIX && sh curl-uts-download.sh $FULLURL && NEWFILEPREFIX=ICD9CM_TO_SNOMEDCT_DIAGNOSIS_ && NEWFILENAME=$NEWFILEPREFIX$LASTYEAR$SUFFIX && ls -la && unzip $NEWFILENAME

RUN Rscript ICD9CM_SNOMED_MAP-to-RDF.R

RUN CURRYEAR=$(date +"%Y") && LASTYEAR=$(($CURRYEAR-1)) && SUFFIX=12 && DATESTRING=$LASTYEAR$SUFFIX && tail ICD9CM_SNOMED_MAP_$DATESTRING.ttl