FROM r-base:3.6.2

# switch to bash from dash
RUN ln -s bash /bin/sh.bash
RUN mv /bin/sh.bash /bin/sh

# import R packages and system libraries
RUN apt-get update; apt-get -y install curl pkg-config libxml2-dev libcurl4-gnutls-dev libssl-dev librasqal3-dev libraptor2-dev librdf0-dev libv8-dev dos2unix
RUN Rscript -e 'install.packages(c("config", "httr", "igraph", "SPARQL", "rdflib", "tibble", "uuid", "config"))'

# set up configuration files
WORKDIR /config
COPY config/umls_credentials.yaml .
COPY config/disease-repo-config-se.ttl .
COPY config/disease_diagnosis_config.yaml.template .
RUN cp /config/disease_diagnosis_config.yaml.template disease_diagnosis_config.yaml

# add source files
WORKDIR /appsrc
COPY disease_diagnosis_dev.R .
COPY ICD9CM_SNOMED_MAP-to-RDF.R .
COPY gen_icd9tosnomed.sh .
RUN dos2unix gen_icd9tosnomed.sh
ADD http://download.nlm.nih.gov/rxnorm/terminology_download_script.zip .