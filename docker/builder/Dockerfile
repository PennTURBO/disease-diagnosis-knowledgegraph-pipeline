# Run interactively with docker-compose run builder /bin/bash

FROM r-base:3.6.2

# switch to bash from dash
RUN ln -s bash /bin/sh.bash
RUN mv /bin/sh.bash /bin/sh

# import R packages and system libraries
RUN apt-get update; apt-get -y install curl pkg-config libxml2-dev libcurl4-gnutls-dev libssl-dev librasqal3-dev libraptor2-dev librdf0-dev libv8-dev dos2unix
RUN Rscript -e 'install.packages(c("config", "httr", "igraph", "SPARQL", "rdflib", "tibble", "uuid", "config"))'

ADD http://download.nlm.nih.gov/rxnorm/terminology_download_script.zip .

RUN apt-get update; apt-get -y install git \
	    build-essential \
    	ca-certificates \
    	gcc \
    	libpq-dev \
    	make \
    	python-pip \
    	python2.7 \
    	python2.7-dev \
    	ssh \
    	default-libmysqlclient-dev \
    	&& apt-get autoremove \
        && apt-get clean

RUN pip install -U "setuptools==3.4.1"
RUN pip install -U "pip==1.5.4"
RUN pip install -U "Mercurial==2.9.1"
RUN pip install -U "virtualenv==1.11.4"
#RUN pip install -U "urllib"
RUN pip install -U "mysqlclient"