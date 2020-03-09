FROM r-base:3.6.2


# import R packages
RUN Rscript -e 'install.packages(c("config", "httr", "igraph", "SPARQL"))'

# add source files
COPY disease_diagnosis_dev.R /appsrc/

# set up configuration files
WORKDIR /config
COPY config/disease-repo-config-se.ttl config
COPY disease_diagnosis_template.yaml config

#Hayden starting work here
WORKDIR /appsrc
RUN yum install unzip
COPY http://download.nlm.nih.gov/rxnorm/terminology_download_script.zip appsrc
RUN unzip terminology_download_script.zip
