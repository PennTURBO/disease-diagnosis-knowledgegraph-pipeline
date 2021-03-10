# Run interactively with docker-compose run mysql /bin/bash

#FROM mysql:8
FROM mariadb:5.5.64

RUN apt-get update; \
	apt-get -y install \
		dos2unix \
		mysql-client \
		less \
    && apt-get autoremove \
    && apt-get clean

RUN echo "[mysqld]" >> /etc/mysql/my.cnf
RUN echo "local_infile = 1" >> /etc/mysql/my.cnf
RUN sed -i 's@/var/lib/mysql@/var/lib/mysql/umls-snomed/mysql@g' /etc/mysql/my.cnf

RUN cat /etc/mysql/my.cnf

# switch to bash from dash
RUN ln -s bash /bin/sh.bash
RUN mv /bin/sh.bash /bin/sh