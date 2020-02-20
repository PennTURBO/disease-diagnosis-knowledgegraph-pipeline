FROM r-base:3.6.2


# import R packages
RUN Rscript -e 'install.packages(c("config", "httr", "igraph", "SPARQL"))'

# add source files
COPY disease_diagnosis_dev.R /appsrc/

# set up configuration files
WORKDIR /config
COPY config/disease-repo-config-se.ttl config
COPY dd_on_pmacs.yaml.template config