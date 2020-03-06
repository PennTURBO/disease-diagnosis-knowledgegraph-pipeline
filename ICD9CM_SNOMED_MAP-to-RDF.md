# Creating RDF SNOMED-ICD9 mappings

The National Library of Medicine generates a tabular ICD-9 to SNOMED mapping every year. This mapping provides links that appear in several of the TURBO disease to diagnosis paths. This document describes a mostly-automated method for converting the tabular mappings to RDF triples, which are required when creating a disease to diagnosis knowledge graph.

The portions of this workflow that are not completely automated yet include establishing a validated session against NLM's download site, determining the URL of the latest mapping file, downloading that file, and unzipping. Also, after running the RDF generation script, importing the triples into GraphDB.

Some other method could be used to load the tabular ICD-9 to SNOMED mapping into Neo4J or GraphDB, as long as the triples use the same type, predicates, `xsd:datatype`s, and graph context as the triples described here.

OntoRefine is no longer required to instantiate the tabular ICD-9 to SNOMED mapping, but [legacy instructions for interactively using OntoRefine are still available](old/OntoRefine_ICD9CM_SNOMED_mapping_to_RDF.md).

- Download the latest SNOMED-ICD9 mappings from the command line with `curl-uts-download.sh` 

- Obtain a UMLS license if you don't already have one. 
- get the UTS (ULMS terminology services download script 
  -  http://download.nlm.nih.gov/rxnorm/terminology_download_script.zip

- See the README.txt file

- There are lines in `curl-uts-download.sh` where the user can hard-code their UMLS credentials.
    - `export UTS_USERNAME=`
    - `export UTS_PASSWORD=`
    
- A safer practice _might_ be commenting out those lines and exporting the assignments in the shell, with history temporarily 
    - `export UTS_USERNAME=<SECRET>;history -d $(history 1)`
    - `export UTS_PASSWORD=<SECRET>;history -d $(history 1)`
    
- Browse to https://www.nlm.nih.gov/research/umls/mapping_projects/icd9cm_to_snomedct.html to determine the latest mapping file name, or write a script to scrape it. I don't believe you can even view the landing page without authenticating first. Perhaps the whole authentication, latest-file-identification and download process could be written into some TURBO/Drivetrain method.

`$ sh curl-uts-download.sh https://download.nlm.nih.gov/umls/kss/mappings/ICD9CM_TO_SNOMEDCT/ICD9CM_TO_SNOMEDCT_DIAGNOSIS_201812.zip`

- Even if the authentication and download were successful, the script will spew out some raw HTML that looks like there was some kind of failure. Something like...

> You have been successfully logged out of the UMLS Terminology Services.

...is expected. You can examine the HTML more closely if desired. If you get a roughly 1 MB zip file, your download was probably successful.

- Unzip the download to obtain two tab delimited data files like

 1. `ICD9CM_SNOMED_MAP_1TO1_<YYYYMM>.txt` (~1 MB)
 2. `ICD9CM_SNOMED_MAP_1TOM_<YYYYMM>.txt` (~6 MB)

- Configure `ICD9CM_SNOMED_MAP.yaml` to determine where the tabular mapping files will be found and where the resulting RDF file should be written
- Use `$ Rscript ICD9CM_SNOMED_MAP-to-RDF.R` to convert the two tab delimited data files to an RDF file. 
    - Some `NAs introduced by coercion` warnings are expected
    - The script will run for roughly 15 minutes without any progress indication.
- Finally, load the RDF file into the `https://www.nlm.nih.gov/research/umls/mapping_projects/icd9cm_to_snomedct.html` graph in the disease to diagnosis repository. 

`curl --data @ICD9CM_SNOMED_MAP.ttl http://server:port/repositories/disease_diagnosis_dev/rdf-graphs/service?graph=https://www.nlm.nih.gov/research/umls/mapping_projects/icd9cm_to_snomedct.html -H 'Content-Type:text/turtle'`
