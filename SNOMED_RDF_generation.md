# SNOMED RDF Generation

## Background

A SNOMED RDF file is required in TURBO disease to diagnosis knowledge graphs. [IHTSD has their own SNOMED/OWL initiative](https://confluence.ihtsdotools.org/display/DOCOWL/SNOMED+CT+OWL+Guide), but TURBO knowledge graphs currently use the [NCBO's BioPortal style for the SNOMED triples](https://bioportal.bioontology.org/ontologies/SNOMEDCT). Unlike many other RDF knowledge assets at the BioPortal, the SNOMED triples are not available for download because they require end-users to agree to the SNOMED license. IHTSD does allow the NLM to redistribute [SNOMED in the Unified Medical Language System](https://www.nlm.nih.gov/research/umls/sourcereleasedocs/current/SNOMEDCT_US/index.html), since [accessing the UMLS requires obtaining a license](https://www.nlm.nih.gov/databases/umls.html#license_request).

The SNOMED CT International Edition is currently released twice a year on the 31st of January and the 31st of July. The UMLS, which includes a US-localized version of SNOMED, has a `AA` version which is released in May of each year and a `AB` version in November.

## Contents

- obtain a UMLS license if necessary
- download the UMLS distribution with a web browser or the UTS download script
- Unzip the UMLS archive to obtain
  - The UMLS content, in several binary `.nlm` files
  - A `README.txt` file, which is worth reading
  - A `mmsys.zip` archive containing NLM's MetaMorphoSys Java application
- Unzip `mmsys.zip`
- Enjoy yet another `README.txt`
- Use one of the shell/bash wrappers to launch MetaMorphoSys in [graphical/interactive mode](https://www.ncbi.nlm.nih.gov/books/NBK9683/) in order to convert the `.nlm` files into pipe-delimited `.RRF` (rich release format) files. *MetaMorphoSys has the capability to subset one or more knowledgebases out of UMLS. That capability should be used here to extract SNOMED alone, unless you know that you want to build RDF versions of other UMLS knowledgebases in the future.*
  - Alternatively use [MetaMorphoSys in a batch mode](batch_metamorphosys_notes.md), which requires creating some configuration files.
- Deploy and/or configure a MySQL server, which will be loaded with the UMLS `.RRF` files.
- run a Bash script to load the RRF files into a MySQL database
- Run the umls2rdf Python script to dump the MySQL contents to RDF

The detailed directions below are optimized for use on a Mac or a Linux computer with a graphical desktop. The same steps could be performed on a Windows PC or a command-line-only Linux environment with a few modifications. Some of the manual steps can even be automated with the [MetaMorphoSys Batch approach](https://www.nlm.nih.gov/research/umls/implementation_resources/community/mmsys/BatchMetaMorphoSys.html), although creating the required properties files in a plain text editor is complex.

Roughly 100 GB is required for the downloaded `.zip` file, the unzipped `.nlm` files, the `.RRF` extracts created by MetaMorphoSys, and the MySQL tables. I have run the whole process on Mac with 32 GB RAM.

## Downloading a UMLS full release archive

The bi-annual UMLS full release can be downloaded interactively from https://www.nlm.nih.gov/research/umls/licensedcontent/umlsknowledgesources.html, or from the command line with the UTS (ULMS terminology services) download script. The [UTS download script](http://download.nlm.nih.gov/rxnorm/terminology_download_script.zip) is published as a zip archive which includes documentation. [Hints for using the UTS download scripts]() are available as part of a separate TURBO document. A typical invocation would look like this:

`$ sh curl-uts-download.sh https://download.nlm.nih.gov/umls/kss/2019AB/umls-2019AB-full.zip`

UMLS releases are roughly 5 GB and will take roughly 20 minutes to download even over a fast network connection.


## MetaMorphoSys in graphical mode

- Launch MetaMorphoSys with the wrapper script appropriate for your OS

- Click Install UMLS

- Set the source to the folder containing the `.nlm` files

- Set the destination... presumably a new, empty folder

- Select the Metathesarus checkbox only, not the Semantic Network or the SPECIALIST Lexicon checkboxes

- Click OK

- Click "New Configuration" unless you already have an appropriate configuration file

- Read and accept the license

- Click OK to accept the default "Level 0" subset. This will be overridden in a subsequent next step.

- Graphical Configuration

  - no changes should be needed for the source format or folder
  - no changes should be needed for the output source or folder, but the database type for "Write Database Load Scripts" should be set to "MySQL 5.6", even if you are using a different version of MySQL or MariaDB. If you are really going to use MS Access or Oracle, you should indicate that. At the bottom of this pane, there is also the option to omit building and sorting some indices. That omission does not appear to penalize the following steps, and it can shave a few minutes off the over RRF extraction process.
  - Source list tab:  this is where you choose which [UMLS knowledgebase source(s)](sample_UMLS_sources.md) to include in the subset/output. Clicking on a source without holding control or command will clear all other selections. Note that in the default setting, clicking on sources **excludes** them. 
    - I recommend switching to "Select sources to INCLUDE in subset" mode.
    - Then click on "US Edition of SNOMED CT ...". Other sources should become unselected.
    - MetaMorphoSys will encourage you to include the Spanish Language Edition and the Veterinary Extensions. I have been control/command clicking both to clear them.
  - No changes should be required for the Precedence tab
  - No changes should be required for the "Suppressibility" tab
  - Click Done->Begin Subset from the top menu bar. You will be given an opportunity to save your configuration. A saved configuration will eliminate almost all of the previously mentioned clicks, and can even be used as a starting point for running MetaMorphoSys in batch mode in the future.

- Performing the extraction/RRF generation will take roughly one hour.

  

## MySQL server hints

- It is taken for granted that the reader has some basic familiarity with MySQL. 
- [The NLM provides their own notes for loading RRF into MySQL](https://www.nlm.nih.gov/research/umls/implementation_resources/scripts/README_RRF_MySQL_Output_Stream.html). They recommend sticking with the fairly old MySQL 5.5.
- I have used the current versions of MySQL and MariaDB without any difficulties, even without any special configurations. I'm currently using MySQL 8 from the homebrew package manager.
- The MySQL installer may suggest using the new SHA256 password format, but the either the NLM database load script and/or the next umls2rdf step *seem*s to have a MySQL 5.x client baked in and therefore require the legacy password format. 
- With a freshly created MySQL server, it will be necessary to create a new destination database and a new user. I have been creating a `umls@localhost` and a `umls@'%'` user. 
- I have been doing `GRANT ALL PRIVILEGES ON umls.* TO 'umls' @'%'` etc., but one could argue for granting fewer privileges.
- These might be helpful:
  - https://www.digitalocean.com/community/tutorials/how-to-create-a-new-user-and-grant-permissions-in-mysql
  - https://www.digitalocean.com/community/tutorials/how-to-create-and-manage-databases-in-mysql-and-mariadb-on-a-cloud-server
- If the following steps aren't going to be run on the same computer that the MySQL, it may be necessary to change the [bind address](https://www.digitalocean.com/community/tutorials/how-to-allow-remote-access-to-mysql).
-  It will probably be necessary to set `local_infile=1` in a configuration file like `/etc/my.cnf`

## Database population

- MetaMorphoSys places two `.sql` files plus shell wrappers in the output folder specified in the MetaMorphoSys properties.
- It may be necessary to change the line endings in `mysql_tables.sql` from `lines terminated by '\r\n'` to `lines terminated by '\n'` with a tool like sed.
- `populate_mysql_db.sh` has a `MYSQL_HOME` parameter. This is the directory in which the `bin/mysql` binary is found. When MySQL is installed on MacOS via home-homebrew, it will probably be `/usr/local/opt/mysql-client`. When MySQL is installed on Ubuntu Linux with `apt-get` it will probably be `/usr/`.
- `populate_mysql_db.sh` also has lines for hard-coding the MySQL user and password. [An alternative, possibly more-secure approach is described here.](ICD9CM_SNOMED_MAP-to-RDF.md)

- set the permissions for `populate_mysql_db.sh` to executable if necessary and start the population process with

`$ sh populate_mysql_db.sh`

## Dumping from MySQL to RDF

- Clone the [NCBO's umls2rdf](https://github.com/ncbo/umls2rdf)  GitHub repo
- Read `README.md`
- Make sure Python 2 is installed
  - you may need to change the first line of  `umls2rdf` so that it points to the python 2 binary. For example, changing `#! /usr/bin/env python` to `#! /usr/bin/env python2.7`
- Make sure that the required Python libraries are available or have been installed. Some of them may have  _system dependencies_. If either package needs to be installed, installing `pip` or another Python package manager will probably be necessary.
  - urllib
  - MySQLdb
    - I installed from the [mysqlclient fork](https://ruddra.com/posts/install-mysqlclient-macos/)
- `umls2rdf.py` also imports the following libraries, but they should be available as part of the standard library
  - codecs
   - collections
   - os
   - pdb
   - string.Template
   - sys
- Make sure the output directory exists and is writable. Also check to see if it contains any RDF files that might be unintentionally overwritten.
- Create a `conf.py` file by copying the `conf_sample.py` template.
- Set the database parameters in `conf.py`, including the username and password. It would probably be better to do with this with history-excluded environment variables, but I don't know how to do that in Python. Update `UMLS_VERSION`, leave the `UMLS_BASE_URI` as is, and set `INCLUDE_SEMANTIC_TYPES` to `False`
- Edit `umls.conf`. For making a SNMED RDF file as part of the TURBO disease to diagnosis workflow, all lines can be commented out besides

`SNOMEDCT_US;SNOMEDCT,SNOMEDCT.ttl,load_on_codes`



----



I have had difficulty exporting some sources (like `MTHSPL`) despite multiple different attempts and request for help from NCBO and stackoverflow. 

One also needs to indicate whether the IRIs for UMLS terms should based on their native codes, or on the UMLS assigned CUIs. CUIs are a better choice for linking to other UMLS terms, but codes may be a better choice for connecting to OMOP concepts. Some sources, however, do not have native codes.

- `cd` into the directory that contains the UMLS RRF files and run umls2rdf with its full path

```BASH
$ ~/umls2rdf/umls2rdf.py
```

Copy the resulting Turtle files into the `graphdb-import` folder on the GraphDB server where they disease to diagnosis repository is going to be constructed.

