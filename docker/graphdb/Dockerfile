FROM "ontotext/graphdb:9.1.1-se"


ARG graphdb_license_path=config/myLicenseFile


# Copy the license
RUN mkdir -p /opt/graphdb/home/conf
##COPY ${graphdb_license_path} /opt/graphdb/home/conf 


# Create the repository
COPY config/disease-repo-config-se.ttl config

#RUN curl -X POST\
#    http://localhost:7200/rest/repositories\
#    -H 'Content-Type: multipart/form-data'\
#    -F "config=@/config/disease-repo-config-se.ttl"

