## Disease Diagnosis Pipeline

I have had difficulty exporting some sources (like `MTHSPL`) despite multiple different attempts and request for help from NCBO and stackoverflow. 

One also needs to indicate whether the IRIs for UMLS terms should based on their native codes, or on the UMLS assigned CUIs. CUIs are a better choice for linking to other UMLS terms, but codes may be a better choice for connecting to OMOP concepts. Some sources, however, do not have native codes.

Copy the resulting Turtle files into the `graphdb-import` folder on the GraphDB server where they disease to diagnosis repository is going to be constructed.

One good place to store files like these, and move them onto another location, is Amazon S3.

Also required in the `graphdb-import` folder: `www_nlm_nih_gov_research_umls_mapping_projects_icd9cm_to_snomedct.ttl`, or some equivalent files that contains a direct mapping of the two csv files in the zip archive downloadable from https://www.nlm.nih.gov/research/umls/mapping_projects/icd9cm_to_snomedct.html

Next, run [https://github.com/PennTURBO/disease_to_diagnosis_code/blob/master/disease_diagnosis_dev.R](https://github.com/PennTURBO/disease_to_diagnosis_code/blob/master/disease_diagnosis_dev.R)

That R script is extensively commented.

