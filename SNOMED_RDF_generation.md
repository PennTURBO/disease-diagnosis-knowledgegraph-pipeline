# SNOMED RDF Generation



A SNOMED RDF file is required in TURBO disease to diagnosis knowledge graphs. [IHTSD has their own SNOMED/OWL initiative](https://confluence.ihtsdotools.org/display/DOCOWL/SNOMED+CT+OWL+Guide), but TURBO knowledge graphs currently use the [NCBO's BioPortal style for the SNOMED triples](https://bioportal.bioontology.org/ontologies/SNOMEDCT). Unlike many other RDF knowledge assets at the BioPortal, the SNOMED triples are not available for download because they require end-users to agree to the SNOMED license. IHTSD does allow the NLM to redistribute [SNOMED in the Unified Medical Language System](https://www.nlm.nih.gov/research/umls/sourcereleasedocs/current/SNOMEDCT_US/index.html), since [accessing the UMLS requires obtaining a license](https://www.nlm.nih.gov/databases/umls.html#license_request).

The SNOMED CT International Edition is currently released twice a year on the 31st of January and the 31st of July. The UMLS, which includes a US-localized version of SNOMED, has a `AA` version which is released in May of each year and a `AB` version in November.

----

At a high level, the steps involved in creating a BioPortal-style SNOMED RDF file are:

- obtain a UMLS license if necessary
- download the UMLS distribution with a web browser or 
- unpack the UMLS archive into RRF "rich release format" files, and probably subset them with the bundled MetaMorhoSys Java application
- run a Bash script to load the RRF files into a MySQL database
- run the umls2rdf Python script to dump the MySQL contents to RDF



The detailed directions below are optimized for use on a Mac or a Linux computer with a graphical desktop. The same steps could be performed on a Windows PC or a command-line-only Linux environment with a few modifications. Some of the manual steps can even be automated with the [MetaMorphoSys Batch approach](https://www.nlm.nih.gov/research/umls/implementation_resources/community/mmsys/BatchMetaMorphoSys.html), although creating the required properties files in a plain text editor is complex.



## Downloading a UMLS full release archive

The bi-annual UMLS full release can be downloaded interactively from https://www.nlm.nih.gov/research/umls/licensedcontent/umlsknowledgesources.html, or from the command line with the UTS (ULMS terminology services) download script. The [UTS download script](http://download.nlm.nih.gov/rxnorm/terminology_download_script.zip) is publised as a zip archive which includes documentation. [Hints for using the UTS download scripts]() are avaiable as part of a seperate TURBO document. A typical invocation would look like this:

`$ sh curl-uts-download.sh https://download.nlm.nih.gov/umls/kss/2019AB/umls-2019AB-full.zip`

UMLS releases are roughly 5 GB and will take roughly 20 minutes to download even over a fast network connection.

- unzip the UMLS release file
- 

Each of those steps are somewhat complex in their own right. There is ample web documentation for the main phases

- Unpacking with MetaMorphoSys
  - GUI: https://www.ncbi.nlm.nih.gov/books/NBK9683/
  - command line: https://www.nlm.nih.gov/research/umls/implementation_resources/community/mmsys/BatchMetaMorphoSys.html
- Loading into MySQL: https://www.nlm.nih.gov/research/umls/implementation_resources/scripts/README_RRF_MySQL_Output_Stream.html
- Dumping to RDF with umls2rdf: https://github.com/ncbo/umls2rdf

But little of that documentation is complete or thoroughly up to date. For example, dependencies like installing MySQL or obtaining Python libraries are not addressed.

Building the SNOMED RDF takes lots of disk space and RAM (100 GB+).

More rough documentation for generating SNOMED RDF can be found at https://github.com/PennTURBO/disease_to_diagnosis_code/blob/master/disease_diagnosis_dev_inc_prep.md