## Disease Diagnosis Pipeline

### Converting UMLS content into RDF

**Some** UMLS sources/components are already available as RDF files at the NCBO BioPortal. Others, like SNOMED, are not. This document describes how to convert those components into RDF on a remote Linux server. Note that the UMLS has an `AA` release in May of each year and an `AB` release in November. Some sources may be released more frequently (like RxNorm) and may have their own interfaces (like RxNav for RxNorm) that may be so convenient that they may be preferable over RDF in some cases.

Most of these steps will take many minutes to roughly one hour.

- Start AWS EC2 instance
- Mount data disk(s) if necessary

### System notes
Recent Ubuntu LTS 64 bit server with MySQL server and client software installed. Reader should be comfortable creating MySQL database and users, setting permissions, and managing remote visibility if desired (i.e. access from addresses other than `localhost`). I have been using a `x1e.xlarge`, but there are probably steps below that would benefit from a higher CPU count. 16 GB  (`r5a.large`) is definitely not enough for a dataset the size of SNOMED.

### Sample UMLS sources

- See [UMLS Metathesaurus Vocabulary Documentation(https://www.nlm.nih.gov/research/umls/sourcereleasedocs/index.html)
- _Medi-Span data (SAB=MDDB) has been removed from RxNorm at Wolters Kluwer's request. As of October 2017, Medi-Span data will not be included in the RxNorm or UMLS releases. (see [https://www.nlm.nih.gov/pubs/techbull/nd17/nd17_umls_2017ab_release.html](https://www.nlm.nih.gov/pubs/techbull/nd17/nd17_umls_2017ab_release.html))_
- _See [https://uts.nlm.nih.gov/help/license/licensecategoryhelp.html](https://uts.nlm.nih.gov/help/license/licensecategoryhelp.html) for Restriction Levels_

**Recent English-language Vocabularies in 2019AB**|**Abbreviation**|**Last Updated**|**Restriction Level**
:-----|:-----|:-----|:-----:
Anatomical Therapeutic Chemical Classification System|ATC|2019AB|0
BioCarta online maps of molecular pathways, adapted for NCI use|NCI\_BioC|2019AB|0
Biomedical Research Integrated Domain Group Model|NCI\_BRIDG|2019AB|0
Cancer Research Center of Hawaii Nutrition Terminology|NCI\_CRCH|2019AB|0
Cancer Therapy Evaluation Program - Simple Disease Classification|NCI\_CTEP-SDC|2019AB|0
CDISC Glossary Terminology|NCI\_CDISC-GLOSS|2019AB|0
CDISC Terminology|NCI\_CDISC|2019AB|0
CDT|CDT|2019AB|3
Chemical Biology and Drug Development Vocabulary|NCI\_CBDD|2019AB|0
Clinical Proteomic Tumor Analysis Consortium|NCI\_CPTAC|2019AB|0
Clinical Trials Reporting Program Terms|NCI\_CTRP|2019AB|0
Common Terminology Criteria for Adverse Events|NCI\_CTCAE|2019AB|0
Common Terminology Criteria for Adverse Events 3.0|NCI\_CTCAE\_3|2019AB|0
Common Terminology Criteria for Adverse Events 5.0|NCI\_CTCAE\_5|2019AB|0
Content Archive Resource Exchange Lexicon|NCI\_CareLex|2019AB|0
CPT - Current Procedural Terminology|CPT|2019AA|3
CPT in HCPCS|HCPT|2019AA|3
Digital Imaging Communications in Medicine Terms|NCI\_DICOM|2019AB|0
DrugBank|DRUGBANK|2019AB|0
European Directorate for the Quality of Medicines & Healthcare Terms|NCI\_EDQM-HC|2019AB|0
FDA Structured Product Labels|MTHSPL|2019AB|0
FDA Terminology|NCI\_FDA|2019AB|0
FDB MedKnowledge|NDDF|2019AB|3
Foundational Model of Anatomy|FMA|2019AB|0
Gene Ontology|GO|2019AB|0
Geopolitical Entities, Names, and Codes (GENC) Standard Edition 1|NCI\_GENC|2019AB|0
Global Alignment of Immunization Safety Assessment in Pregnancy Terms|NCI\_GAIA|2019AB|0
Gold Standard Drug Database|GS|2019AB|3
HCPCS - Healthcare Common Procedure Coding System|HCPCS|2019AA|0
HCPCS Hierarchical Terms (UMLS)|MTHHH|2019AA|0
HL7 Version 2.5|HL7V2.5|2005AC|0
HL7 Version 3.0|HL7V3.0|2019AB|0
HUGO Gene Nomenclature Committee|HGNC|2019AB|0
Human Phenotype Ontology|HPO|2019AB|0
ICD-9-CM Entry Terms|MTHICD9|2015AA|0
ICD-10 Procedure Coding System|ICD10PCS|2019AB|0
ICD-10, American English Equivalents|ICD10AE|1998AA|3
International Classification for Nursing Practice|ICNP|2019AB|3
International Classification of Diseases and Related Health Problems, Tenth Revision|ICD10|2004AB|3
International Classification of Diseases, Ninth Revision, Clinical Modification|ICD9CM|2015AA|0
International Classification of Diseases, Tenth Revision, Clinical Modification|ICD10CM|2019AB|4
International Conference on Harmonization Terms|NCI\_ICH|2019AB|0
International Neonatal Consortium|NCI\_INC|2019AB|0
Jackson Laboratories Mouse Terminology, adapted for NCI use|NCI\_JAX|2019AB|0
KEGG Pathway Database Terms|NCI\_KEGG|2019AB|0
LOINC|LNC|2019AB|0
Manufacturers of Vaccines|MVX|2019AB|0
MEDCIN|MEDCIN|2019AB|3
MedDRA|MDR|2019AB|3
Medication Reference Terminology|MED-RT|2019AB|0
MeSH|MSH|2019AB|0
Metathesaurus CMS Formulary Reference File|MTHCMSFRF|2019AB|0
Metathesaurus Names|MTH|1990AA|0
Micromedex|MMX|2019AB|3
Minimal Standard Terminology (UMLS)|MTHMST|2002AA|0
Multum|MMSL|2019AB|1
National Cancer Institute Nature Pathway Interaction Database Terms|NCI\_PID|2019AB|0
National Drug File|VANDF|2019AB|0
NCBI Taxonomy|NCBI|2019AB|0
NCI Developmental Therapeutics Program|NCI\_DTP|2019AB|0
NCI Dictionary of Cancer Terms|NCI\_NCI-GLOSS|2019AB|0
NCI Division of Cancer Prevention Program Terms|NCI\_DCP|2019AB|0
NCI Health Level 7|NCI\_NCI-HL7|2019AB|0
NCI HUGO Gene Nomenclature|NCI\_NCI-HGNC|2019AB|0
NCI Thesaurus|NCI|2019AB|0
NCPDP Terminology|NCI\_NCPDP|2019AB|0
Neuronames Brain Hierarchy|NEU|2019AB|3
NICHD Terminology|NCI\_NICHD|2019AB|0
Online Mendelian Inheritance in Man|OMIM|2019AB|0
Prostate Imaging Reporting and Data System Terms|NCI\_PI-RADS|2019AB|0
Registry Nomenclature Information System|NCI\_RENI|2019AB|0
RXNORM|RXNORM|2019AB|0
SNOMED CT, US Edition|SNOMEDCT\_US|2019AB|9
SNOMED CT, Veterinary Extension|SNOMEDCT\_VET|2019AB|9
Source Terminology Names (UMLS)|SRC|1995AA|0
Standard Product Nomenclature|SPN|2004AA|0
U.S. Centers for Disease Control and Prevention Terms|NCI\_CDC|2019AB|0
Unified Code for Units of Measure|NCI\_UCUM|2019AB|0
USP Compendial Nomenclature|USP|2019AB|0
Vaccines Administered|CVX|2019AB|0
Zebrafish Model Organism Database Terms|NCI\_ZFin|2019AB|0

Download UMLS with curl-uts-download.sh from [terminology_download_script.zip](http://download.nlm.nih.gov/rxnorm/terminology_download_script.zip)

See the `README.txt` file

Requires a UMLS account. Hard-code credentials(?!) into `curl-uts-download.sh`

```BASH
$ sh curl-uts-download.sh https://download.nlm.nih.gov/umls/kss/2019AB/umls-2019AB-full.zip
$ unzip umls-2019AB-full.zip
$ cd 2019AB-full/
$ unzip mmsys.zip
```

Follow the directions [BatchMetaMorphoSys](https://www.nlm.nih.gov/research/umls/implementation_resources/community/mmsys/BatchMetaMorphoSys.html) directions to create _RRF_ files from the desired UMLS sources.

`cat` the BatchMetaMorphoSys bash script to `metamorphosys_batch.sh` and edit. For example:

```BASH
	#!/bin/sh -f
	# Specify directory containing .RRF or .nlm files
	METADIR=/terabytes/2019AB-full/
	# Specify output directory
	DESTDIR=/terabytes/2019AB_selected
	# Specify MetamorphoSys directory
	MMSYS_HOME=/terabytes/2019AB-full/
	# Specify CLASSPATH
	CLASSPATH=${MMSYS_HOME}:$MMSYS_HOME/lib/jpf-boot.jar
	# Specify JAVA_HOME
	JAVA_HOME=$MMSYS_HOME/jre/linux
	# Specify configuration file
	CONFIG_FILE=/terabytes/2019AB_selected.prop
	# Run Batch MetamorphoSys
	export METADIR
	export DESTDIR
	export MMSYS_HOME
	export CLASSPATH
	export JAVA_HOME
	cd $MMSYS_HOME
	$JAVA_HOME/bin/java -Djava.awt.headless=true -Djpf.boot.config=$MMSYS_HOME/etc/subset.boot.properties \
	-Dlog4j.configuration=$MMSYS_HOME/etc/subset.log4j.properties -Dinput.uri=$METADIR \
	-Doutput.uri=$DESTDIR -Dmmsys.config.uri=$CONFIG_FILE -Xms300M -Xmx1000M org.java.plugin.boot.Boot
```

Then create or edit the properties file if necessary, especially enabling or disabling sources. Enabled sources are values of the `selected_sources` property. For example:

```
# Configuration Properties File
#Fri May 31 07:42:59 EDT 2019
active_filters=gov.nih.nlm.umls.mmsys.filter.SourceListFilter;gov.nih.nlm.umls.mmsys.filter.PrecedenceFilter;gov.nih.nlm.umls.mmsys.filter.SuppressibleFilter
#default_subset_config_uri=C\:\\Users\\Mark\\Desktop\\2019AA-full\\config\\2019AA\\user.d.prop
gov.nih.nlm.umls.mmsys.filter.PrecedenceFilter.precedence=MTH|PN;RXNORM|MIN;MTHCMSFRF|PT;RXNORM|SCD;RXNORM|SBD;RXNORM|SCDG;RXNORM|SBDG;RXNORM|IN;RXNORM|PSN;RXNORM|SCDF;RXNORM|SBDF;RXNORM|SCDC;RXNORM|DFG;RXNORM|DF;RXNORM|SBDC;RXNORM|BN;RXNORM|PIN;RXNORM|BPCK;RXNORM|GPCK;RXNORM|SY;RXNORM|TMSY;MSH|MH;MSH|TQ;MSH|PEP;MSH|ET;MSH|XQ;MSH|PXQ;MSH|NM;SNOMEDCT_US|PT;SNOMEDCT_US|FN;SNOMEDCT_US|SY;SNOMEDCT_US|PTGB;SNOMEDCT_US|SYGB;SNOMEDCT_US|MTH_PT;SNOMEDCT_US|MTH_FN;SNOMEDCT_US|MTH_SY;SNOMEDCT_US|MTH_PTGB;SNOMEDCT_US|MTH_SYGB;SNOMEDCT_US|SB;SNOMEDCT_US|XM;SNOMEDCT_VET|PT;SNOMEDCT_VET|FN;SNOMEDCT_VET|SY;SNOMEDCT_VET|SB;HPO|PT;HPO|SY;HPO|ET;HPO|OP;HPO|IS;NCBI|SCN;MTHSPL|MTH_RXN_DP;MTHSPL|DP;MTHSPL|SU;ATC|RXN_PT;ATC|PT;VANDF|PT;VANDF|CD;VANDF|IN;USP|CD;USP|IN;USPMG|HC;USPMG|PT;MMX|MTH_RXN_CD;MMX|MTH_RXN_BD;MMX|CD;MMX|BD;DRUGBANK|IN;DRUGBANK|SY;DRUGBANK|FSY;MSH|N1;MSH|PCE;MSH|CE;CPM|PT;NEU|PT;NEU|ACR;NEU|SY;NEU|OP;NEU|IS;FMA|PT;FMA|SY;FMA|AB;FMA|OP;FMA|IS;UWDA|PT;UWDA|SY;UMD|PT;UMD|SY;UMD|ET;UMD|RT;GS|CD;MMSL|CD;GS|MTH_RXN_BD;GS|BD;GS|IN;MMSL|MTH_RXN_BD;MMSL|BD;MMSL|SC;MMSL|MS;MMSL|GN;MMSL|BN;ATC|RXN_IN;ATC|IN;MMSL|IN;VANDF|AB;GS|MTH_RXN_CD;VANDF|MTH_RXN_CD;NDDF|MTH_RXN_CDC;NDDF|CDC;NDDF|CDD;NDDF|CDA;NDDF|IN;NDDF|DF;NDFRT|MTH_RXN_RHT;NDFRT|HT;MED-RT|PT;MED-RT|FN;NDFRT|FN;NDFRT|PT;MED-RT|SY;NDFRT|SY;NDFRT|AB;SPN|PT;MDR|MTH_PT;MDR|PT;MDR|HG;MDR|MTH_HG;MDR|OS;MDR|MTH_OS;MDR|HT;MDR|MTH_HT;MDR|LLT;MDR|MTH_LLT;MDR|SMQ;MDR|MTH_SMQ;MDR|AB;CPT|PT;CPT|SY;CPT|ETCLIN;CPT|POS;CPT|GLP;CPT|ETCF;CPT|MP;HCPT|PT;HCPCS|PT;CDT|PT;CDT|OP;MVX|PT;CVX|PT;CVX|RXN_PT;CVX|AB;HCDT|PT;HCPCS|MP;HCPT|MP;ICD10AE|PT;ICD10|PT;ICD10AE|PX;ICD10|PX;ICD10AE|PS;ICD10|PS;ICD10AMAE|PT;ICD10AM|PT;ICD10AMAE|PX;ICD10AM|PX;ICD10AMAE|PS;ICD10AM|PS;OMIM|PT;OMIM|PHENO;OMIM|PHENO_ET;OMIM|PTAV;OMIM|PTCS;OMIM|ETAL;OMIM|ET;OMIM|HT;OMIM|ACR;MEDCIN|PT;MEDCIN|FN;MEDCIN|XM;MEDCIN|SY;HGNC|PT;HGNC|ACR;HGNC|MTH_ACR;HGNC|NA;HGNC|SYN;ICNP|PT;ICNP|MTH_PT;ICNP|XM;PNDS|PT;PNDS|HT;PNDS|XM;NCI|PT;NCI|SY;NCI_BioC|SY;NCI_PI-RADS|PT;NCI_CPTAC|PT;NCI_CPTAC|SY;NCI_CPTAC|AB;NCI_CareLex|PT;NCI_CareLex|SY;NCI_CDC|PT;NCI_CDISC|PT;NCI_CDISC|SY;NCI|CSN;NCI_DCP|PT;NCI_DCP|SY;NCI|DN;NCI_DTP|PT;NCI_DTP|SY;NCI|FBD;NCI_FDA|AB;NCI_CTRP|PT;NCI_CTRP|SY;NCI_CTRP|DN;NCI_FDA|PT;NCI_FDA|SY;NCI|HD;NCI_GENC|PT;NCI_GENC|CA2;NCI_GENC|CA3;NCI_CRCH|PT;NCI_CRCH|SY;NCI_DICOM|PT;NCI_CDISC-GLOSS|PT;NCI_CDISC-GLOSS|SY;NCI_BRIDG|PT;NCI_BRIDG|SY;NCI_RENI|DN;NCI_BioC|PT;NCI|CCN;NCI_CTCAE|PT;NCI_EDQM-HC|PT;NCI_EDQM-HC|SY;NCI_CTCAE_5|PT;NCI_CTCAE_3|PT;NCI_CTEP-SDC|PT;NCI_CTEP-SDC|SY;NCI|CCS;NCI_JAX|PT;NCI_JAX|SY;NCI_KEGG|PT;NCI_ICH|AB;NCI_ICH|PT;NCI_NCI-HL7|AB;NCI_NCI-HGNC|PT;NCI_NCI-HGNC|SY;NCI_NCI-HL7|PT;NCI_UCUM|AB;NCI_UCUM|PT;NCI_KEGG|AB;NCI_KEGG|SY;NCI_NICHD|PT;NCI_NICHD|SY;NCI_PID|PT;NCI_NCPDP|PT;NCI_GAIA|PT;NCI_GAIA|SY;NCI_ZFin|PT;NCI_INC|PT;NCI_NCI-GLOSS|PT;NCI_ICH|SY;NCI_NCI-HL7|SY;NCI_UCUM|SY;NCI_NCPDP|SY;NCI_ZFin|SY;NCI_NCI-GLOSS|SY;NCI|OP;NCI_NICHD|OP;NCI|AD;NCI|CA2;NCI|CA3;NCI|BN;NCI|AB;PDQ|PT;PDQ|HT;PDQ|PSC;PDQ|SY;CHV|PT;MEDLINEPLUS|PT;MTHICPC2EAE|PT;ICPC2EENG|PT;MTHICPC2ICD10AE|PT;SOP|PT;ICF|HT;ICF|PT;ICF|MTH_HT;ICF|MTH_PT;ICF-CY|HT;ICF-CY|PT;ICF-CY|MTH_HT;ICF-CY|MTH_PT;ICPC2ICD10ENG|PT;ICPC|PX;ICPC|PT;ICPC|PS;ICPC|PC;ICPC|CX;ICPC|CP;ICPC|CS;ICPC|CC;ICPC2EENG|CO;ICPC|CO;MTHICPC2EAE|AB;ICPC2EENG|AB;ICPC2P|PTN;ICPC2P|MTH_PTN;ICPC2P|PT;ICPC2P|MTH_PT;ICPC2P|OPN;ICPC2P|MTH_OPN;ICPC2P|OP;ICPC2P|MTH_OP;AOT|PT;AOT|ET;HCPCS|OP;HCDT|OP;HCPT|OP;HCPCS|OM;HCPCS|OAM;GO|PT;GO|MTH_PT;GO|ET;GO|MTH_ET;GO|SY;GO|MTH_SY;GO|OP;GO|MTH_OP;GO|OET;GO|MTH_OET;GO|IS;GO|MTH_IS;PDQ|ET;PDQ|CU;PDQ|LV;PDQ|ACR;PDQ|AB;PDQ|BN;PDQ|FBD;PDQ|OP;PDQ|CCN;PDQ|CHN;PDQ|IS;NCBI|USN;NCBI|USY;NCBI|SY;NCBI|UCN;NCBI|CMN;NCBI|UE;NCBI|EQ;NCBI|AUN;NCBI|UAUN;LNC|LN;LNC|MTH_LN;LNC|OSN;LNC|CN;LNC|MTH_CN;LNC|LPN;LNC|LPDN;LNC|HC;LNC|HS;LNC|OLC;LNC|LC;LNC|XM;LNC|LS;LNC|LO;LNC|MTH_LO;LNC|OOSN;LNC|LA;ICD10CM|PT;ICD9CM|PT;MDR|OL;MDR|MTH_OL;ICD10CM|HT;ICD9CM|HT;CCS_10|HT;CCS_10|MD;CCS_10|MV;CCS_10|SD;CCS_10|SP;CCS_10|XM;CCS|HT;CCS|MD;CCS|SD;CCS|MV;CCS|SP;CCS|XM;ICPC2ICD10ENG|XM;ICD10AE|HT;ICD10PCS|PT;ICD10PCS|PX;ICD10PCS|HX;ICD10PCS|MTH_HX;ICD10PCS|HT;ICD10PCS|HS;ICD10PCS|AB;ICD10|HT;
gov.nih.nlm.umls.mmsys.filter.SourceListFilter.base_url=http\://www.nlm.nih.gov/research/umls/sourcereleasedocs/
gov.nih.nlm.umls.mmsys.filter.SourceListFilter.enforce_dep_source_selection=true
gov.nih.nlm.umls.mmsys.filter.SourceListFilter.enforce_family_selection=true
gov.nih.nlm.umls.mmsys.filter.SourceListFilter.ip_associations=
gov.nih.nlm.umls.mmsys.filter.SourceListFilter.remove_selected_sources=false
gov.nih.nlm.umls.mmsys.filter.SourceListFilter.selected_sources=ATC|ATC;CPT|CPT;CVX|CVX;DDB|DDB;DRUGBANK|DRUGBANK;GS|GS;HCPCS|HCPCS;HGNC|HGNC;HL7V3.0|HL7V3.0;HLREL|HLREL;ICD10|ICD10;ICD10AE|ICD10;ICD10CM|ICD10CM;ICD10PCS|ICD10PCS;ICD9CM|ICD9CM;ICPC|ICPC;ICPC2EENG|ICPC2EENG;ICPC2ICD10ENG|ICPC2ICD10ENG;ICPC2P|ICPC2P;LNC|LNC;MDDB|MDDB;MED-RT|MED-RT;MMSL|MMSL;MMX|MMX;MSH|MSH;MTH|MTH;MTHCMSFRF|MTHCMSFRF;MTHHH|HCPCS;MTHICD9|ICD9CM;MTHICPC2EAE|ICPC2EENG;MTHICPC2ICD10AE|ICPC2ICD10ENG;MTHMST|MTHMST;MTHSPL|MTHSPL;MVX|MVX;NCI|NCI;NCI_CDC|NCI;NCI_CTEP-SDC|NCI;NCI_CTRP|NCI;NCI_DCP|NCI;NCI_DICOM|NCI;NCI_FDA|NCI;NCI_ICH|NCI;NCI_NCI-GLOSS|NCI;NCI_NCI-HGNC|NCI;NCI_NCI-HL7|NCI;NCI_NCPDP|NCI;NCI_UCUM|NCI;NCISEER|NCISEER;NDDF|NDDF;NDFRT|NDFRT;NDFRT_FDASPL|NDFRT;NDFRT_FMTSME|NDFRT;OMIM|OMIM;RXNORM|RXNORM;SNOMEDCT_US|SNOMEDCT;SPN|SPN;UMD|UMD;USP|USP;USPMG|USPMG;VANDF|VANDF
#gov.nih.nlm.umls.mmsys.filter.SourceListFilter.selected_sources=AIR|AIR;ALT|ALT;AOD|AOD;AOT|AOT;ATC|ATC;BI|BI;CCC|CCC;CCPSS|CCPSS;CCS|CCS;CCS_10|CCS;CDT|CDT;CHV|CHV;COSTAR|COSTAR;CPM|CPM;CPTSP|CPT;CPT|CPT;CSP|CSP;CST|CST;CVX|CVX;DDB|DDB;DMDICD10|ICD10;DMDUMD|UMD;DRUGBANK|DRUGBANK;DSM-5|DSM-5;DXP|DXP;FMA|FMA;GO|GO;GS|GS;HCDT|HCPCS;HCPCS|HCPCS;HCPT|CPT;HGNC|HGNC;HL7V2.5|HL7V2.5;HL7V3.0|HL7V3.0;HLREL|HLREL;HPO|HPO;ICD10AE|ICD10;ICD10AMAE|ICD10AM;ICD10AM|ICD10AM;ICD10CM|ICD10CM;ICD10DUT|ICD10;ICD10PCS|ICD10PCS;ICD10|ICD10;ICD9CM|ICD9CM;ICF-CY|ICF;ICF|ICF;ICNP|ICNP;ICPC2EDUT|ICPC2EENG;ICPC2EENG|ICPC2EENG;ICPC2ICD10DUT|ICPC2ICD10ENG;ICPC2ICD10ENG|ICPC2ICD10ENG;ICPC2P|ICPC2P;ICPC|ICPC;ICPCBAQ|ICPC;ICPCDAN|ICPC;ICPCDUT|ICPC;ICPCFIN|ICPC;ICPCFRE|ICPC;ICPCGER|ICPC;ICPCHEB|ICPC;ICPCHUN|ICPC;ICPCITA|ICPC;ICPCNOR|ICPC;ICPCPOR|ICPC;ICPCSPA|ICPC;ICPCSWE|ICPC;JABL|JABL;KCD5|KCD5;LCH|LCH;LCH_NW|LCH;LNC-DE-AT|LNC;LNC-DE-CH|LNC;LNC-DE-DE|LNC;LNC-EL-GR|LNC;LNC-ES-AR|LNC;LNC-ES-CH|LNC;LNC-ES-ES|LNC;LNC-ET-EE|LNC;LNC-FR-BE|LNC;LNC-FR-CA|LNC;LNC-FR-CH|LNC;LNC-FR-FR|LNC;LNC-IT-CH|LNC;LNC-IT-IT|LNC;LNC-KO-KR|LNC;LNC-NL-NL|LNC;LNC-PT-BR|LNC;LNC-RU-RU|LNC;LNC-TR-TR|LNC;LNC-ZH-CN|LNC;LNC|LNC;MCM|MCM;MDR|MDR;MDRCZE|MDR;MDRDUT|MDR;MDRFRE|MDR;MDRGER|MDR;MDRHUN|MDR;MDRITA|MDR;MDRJPN|MDR;MDRPOR|MDR;MDRSPA|MDR;MED-RT|MED-RT;MEDCIN|MEDCIN;MEDLINEPLUS|MEDLINEPLUS;MMSL|MMSL;MMX|MMX;MSH|MSH;MSHCZE|MSH;MSHDUT|MSH;MSHFIN|MSH;MSHFRE|MSH;MSHGER|MSH;MSHITA|MSH;MSHJPN|MSH;MSHLAV|MSH;MSHNOR|MSH;MSHPOL|MSH;MSHPOR|MSH;MSHRUS|MSH;MSHSCR|MSH;MSHSPA|MSH;MSHSWE|MSH;MTH|MTH;MTHCMSFRF|MTHCMSFRF;MTHHH|HCPCS;MTHICD9|ICD9CM;MTHICPC2EAE|ICPC2EENG;MTHICPC2ICD10AE|ICPC2ICD10ENG;MTHMST|MTHMST;MTHMSTFRE|MTHMST;MTHMSTITA|MTHMST;MTHSPL|MTHSPL;MVX|MVX;NANDA-I|NANDA-I;NCBI|NCBI;NCI|NCI;NCI_BRIDG|NCI;NCI_BioC|NCI;NCI_CDC|NCI;NCI_CDISC-GLOSS|NCI;NCI_CDISC|NCI;NCI_CPTAC|NCI;NCI_CRCH|NCI;NCI_CTCAE|NCI;NCI_CTCAE_3|NCI;NCI_CTCAE_5|NCI;NCI_CTEP-SDC|NCI;NCI_CTRP|NCI;NCI_CareLex|NCI;NCI_DCP|NCI;NCI_DICOM|NCI;NCI_DTP|NCI;NCI_EDQM-HC|NCI;NCI_FDA|NCI;NCI_GAIA|NCI;NCI_GENC|NCI;NCI_ICH|NCI;NCI_INC|NCI;NCI_JAX|NCI;NCI_KEGG|NCI;NCI_NCI-GLOSS|NCI;NCI_NCI-HGNC|NCI;NCI_NCI-HL7|NCI;NCI_NCPDP|NCI;NCI_NICHD|NCI;NCI_PI-RADS|NCI;NCI_PID|NCI;NCI_RENI|NCI;NCI_UCUM|NCI;NCI_ZFin|NCI;NCISEER|NCISEER;NDDF|NDDF;NDFRT|NDFRT;NDFRT_FDASPL|NDFRT;NDFRT_FMTSME|NDFRT;NEU|NEU;NIC|NIC;NOC|NOC;NUCCPT|NUCCPT;OMIM|OMIM;OMS|OMS;PCDS|PCDS;PDQ|PDQ;PNDS|PNDS;PPAC|PPAC;PSY|PSY;QMR|QMR;RAM|RAM;RCD|RCD;RCDAE|RCD;RCDSA|RCD;RCDSY|RCD;RXNORM|RXNORM;SCTSPA|SNOMEDCT;SNM|SNM;SNMI|SNMI;SNOMEDCT_US|SNOMEDCT;SNOMEDCT_VET|SNOMEDCT;SOP|SOP;SPN|SPN;TKMT|TKMT;ULT|ULT;UMD|UMD;USPMG|USPMG;USP|USP;UWDA|UWDA;VANDF|VANDF;WHO|WHO;WHOFRE|WHO;WHOGER|WHO;WHOPOR|WHO;WHOSPA|WHO
gov.nih.nlm.umls.mmsys.filter.SuppressibleFilter.confirm_default_suppressible_sabttys=HPO|OP;HPO|IS;NEU|ACR;NEU|OP;NEU|IS;FMA|AB;FMA|OP;FMA|IS;MDR|AB;CDT|OP;ICD10AE|PS;ICD10|PS;ICD10AMAE|PS;ICD10AM|PS;NCI|OP;NCI_NICHD|OP;ICPC|PS;ICPC|CS;MTHICPC2EAE|AB;ICPC2EENG|AB;ICPC2P|MTH_PT;ICPC2P|OPN;ICPC2P|MTH_OPN;ICPC2P|OP;ICPC2P|MTH_OP;HCPCS|OP;HCDT|OP;HCPT|OP;HCPCS|OM;HCPCS|OAM;GO|OP;GO|MTH_OP;GO|OET;GO|MTH_OET;GO|IS;GO|MTH_IS;PDQ|OP;PDQ|IS;NCBI|AUN;NCBI|UAUN;LNC|OLC;LNC|LO;LNC|MTH_LO;LNC|OOSN;MDR|OL;MDR|MTH_OL;ICD10PCS|HS;ICD10PCS|AB;ICD10AE|HS;ICD10|HS;NUCCPT|OP;HL7V3.0|OP;HL7V3.0|ONP;ICD10CM|AB;ICD9CM|AB;MSH|DEV;MSH|DSV;MSH|QAB;MSH|QEV;MSH|QSV;CPT|AB;HCPT|AB;HCPCS|AB;SNMI|PX;SNMI|HX;SNMI|SX;RCD|OP;RCD|IS;RCD|AS;RCD|AB;RCDSA|OP;RCDSY|OP;RCDAE|OP;RCDSA|IS;RCDSY|IS;RCDAE|IS;RCDSA|AB;RCDSY|AB;RCDAE|AB;RCDSA|OA;RCDSY|OA;RCDAE|OA;RCD|OA;RCDAE|AA;RCD|AA;HCPT|OA;HCPT|AM;HCPCS|OA;HCPCS|AM;HCDT|AB;ALT|AB;HCDT|OA;SNOMEDCT_VET|OAP;SNOMEDCT_VET|OP;SNOMEDCT_US|OAP;SNOMEDCT_US|OP;SNOMEDCT_VET|OAF;SNOMEDCT_VET|OF;SNOMEDCT_US|OAF;SNOMEDCT_US|OF;SNOMEDCT_VET|OAS;SNOMEDCT_VET|IS;SNOMEDCT_US|OAS;SNOMEDCT_US|IS;SNOMEDCT_US|MTH_OAP;SNOMEDCT_US|MTH_OP;SNOMEDCT_US|MTH_OAF;SNOMEDCT_US|MTH_OF;SNOMEDCT_US|MTH_OAS;SNOMEDCT_US|MTH_IS;CCPSS|TC;SCTSPA|OP;SCTSPA|OAF;SCTSPA|OAP;SCTSPA|OAS;SCTSPA|OF;SCTSPA|IS;SCTSPA|MTH_OP;SCTSPA|MTH_OAF;SCTSPA|MTH_OAP;SCTSPA|MTH_OAS;SCTSPA|MTH_OF;SCTSPA|MTH_IS;MSHNOR|DSV;MSHGER|DSV;MDRSPA|OL;MDRSPA|AB;MDRDUT|OL;MDRDUT|AB;MDRFRE|OL;MDRFRE|AB;MDRGER|OL;MDRGER|AB;MDRITA|OL;MDRITA|AB;MDRJPN|OL;MDRJPN|OLJKN;MDRJPN|OLJKN1;MDRCZE|OL;MDRHUN|OL;MDRPOR|OL;MDRCZE|AB;MDRHUN|AB;MDRPOR|AB;LNC-DE-CH|OOSN;LNC-DE-DE|LO;LNC-EL-GR|LO;LNC-ES-AR|LO;LNC-ES-AR|OOSN;LNC-ES-CH|OOSN;LNC-ES-ES|LO;LNC-ET-EE|LO;LNC-FR-BE|LO;LNC-FR-CA|LO;LNC-FR-CH|OOSN;LNC-FR-FR|OLC;LNC-FR-FR|LO;LNC-IT-CH|OOSN;LNC-IT-IT|LO;LNC-KO-KR|LO;LNC-NL-NL|LO;LNC-PT-BR|LO;LNC-PT-BR|OOSN;LNC-RU-RU|LO;LNC-TR-TR|LO;LNC-ZH-CN|LO;LNC-DE-AT|LO
gov.nih.nlm.umls.mmsys.filter.SuppressibleFilter.confirm_selections=true
gov.nih.nlm.umls.mmsys.filter.SuppressibleFilter.remove_editor_suppressible_data=false
gov.nih.nlm.umls.mmsys.filter.SuppressibleFilter.remove_obsolete_data=false
gov.nih.nlm.umls.mmsys.filter.SuppressibleFilter.remove_source_tty_suppressible_data=false
gov.nih.nlm.umls.mmsys.filter.SuppressibleFilter.suppressed_sabttys=ALT|AB;CCPSS|TC;CDT|OP;CPT|AB;FMA|AB;FMA|IS;FMA|OP;GO|IS;GO|MTH_IS;GO|MTH_OET;GO|MTH_OP;GO|OET;GO|OP;HCDT|AB;HCDT|OA;HCDT|OP;HCPCS|AB;HCPCS|AM;HCPCS|OA;HCPCS|OAM;HCPCS|OM;HCPCS|OP;HCPT|AB;HCPT|AM;HCPT|OA;HCPT|OP;HL7V3.0|ONP;HL7V3.0|OP;HPO|IS;HPO|OP;ICD10|HS;ICD10|PS;ICD10AE|HS;ICD10AE|PS;ICD10AM|PS;ICD10AMAE|PS;ICD10CM|AB;ICD10PCS|AB;ICD10PCS|HS;ICD9CM|AB;ICPC|CS;ICPC|PS;ICPC2EENG|AB;ICPC2P|MTH_OP;ICPC2P|MTH_OPN;ICPC2P|MTH_PT;ICPC2P|OP;ICPC2P|OPN;LNC|LO;LNC|MTH_LO;LNC|OLC;LNC|OOSN;LNC-DE-AT|LO;LNC-DE-CH|OOSN;LNC-DE-DE|LO;LNC-EL-GR|LO;LNC-ES-AR|LO;LNC-ES-AR|OOSN;LNC-ES-CH|OOSN;LNC-ES-ES|LO;LNC-ET-EE|LO;LNC-FR-BE|LO;LNC-FR-CA|LO;LNC-FR-CH|OOSN;LNC-FR-FR|LO;LNC-FR-FR|OLC;LNC-IT-CH|OOSN;LNC-IT-IT|LO;LNC-KO-KR|LO;LNC-NL-NL|LO;LNC-PT-BR|LO;LNC-PT-BR|OOSN;LNC-RU-RU|LO;LNC-TR-TR|LO;LNC-ZH-CN|LO;MDR|AB;MDR|MTH_OL;MDR|OL;MDRCZE|AB;MDRCZE|OL;MDRDUT|AB;MDRDUT|OL;MDRFRE|AB;MDRFRE|OL;MDRGER|AB;MDRGER|OL;MDRHUN|AB;MDRHUN|OL;MDRITA|AB;MDRITA|OL;MDRJPN|OL;MDRJPN|OLJKN;MDRJPN|OLJKN1;MDRPOR|AB;MDRPOR|OL;MDRSPA|AB;MDRSPA|OL;MSH|DEV;MSH|DSV;MSH|QAB;MSH|QEV;MSH|QSV;MSHGER|DSV;MSHNOR|DSV;MTHICPC2EAE|AB;NCBI|AUN;NCBI|UAUN;NCI|OP;NCI_NICHD|OP;NEU|ACR;NEU|IS;NEU|OP;NUCCPT|OP;PDQ|IS;PDQ|OP;RCD|AA;RCD|AB;RCD|AS;RCD|IS;RCD|OA;RCD|OP;RCDAE|AA;RCDAE|AB;RCDAE|IS;RCDAE|OA;RCDAE|OP;RCDSA|AB;RCDSA|IS;RCDSA|OA;RCDSA|OP;RCDSY|AB;RCDSY|IS;RCDSY|OA;RCDSY|OP;SCTSPA|IS;SCTSPA|MTH_IS;SCTSPA|MTH_OAF;SCTSPA|MTH_OAP;SCTSPA|MTH_OAS;SCTSPA|MTH_OF;SCTSPA|MTH_OP;SCTSPA|OAF;SCTSPA|OAP;SCTSPA|OAS;SCTSPA|OF;SCTSPA|OP;SNMI|HX;SNMI|PX;SNMI|SX;SNOMEDCT_US|IS;SNOMEDCT_US|MTH_IS;SNOMEDCT_US|MTH_OAF;SNOMEDCT_US|MTH_OAP;SNOMEDCT_US|MTH_OAS;SNOMEDCT_US|MTH_OF;SNOMEDCT_US|MTH_OP;SNOMEDCT_US|OAF;SNOMEDCT_US|OAP;SNOMEDCT_US|OAS;SNOMEDCT_US|OF;SNOMEDCT_US|OP;SNOMEDCT_VET|IS;SNOMEDCT_VET|OAF;SNOMEDCT_VET|OAP;SNOMEDCT_VET|OAS;SNOMEDCT_VET|OF;SNOMEDCT_VET|OP
#gov.nih.nlm.umls.mmsys.io.NLMFileMetamorphoSysInputStream.meta_source_uri=C\:\\Users\\Mark\\Desktop\\2019AA-full
gov.nih.nlm.umls.mmsys.io.RRFMetamorphoSysOutputStream.add_unicode_bom=false
gov.nih.nlm.umls.mmsys.io.RRFMetamorphoSysOutputStream.build_indexes=false
gov.nih.nlm.umls.mmsys.io.RRFMetamorphoSysOutputStream.calculate_md5s=false
gov.nih.nlm.umls.mmsys.io.RRFMetamorphoSysOutputStream.character_encoding=UTF-8
gov.nih.nlm.umls.mmsys.io.RRFMetamorphoSysOutputStream.database=MySQL 5.6
gov.nih.nlm.umls.mmsys.io.RRFMetamorphoSysOutputStream.max_field_length=4000
gov.nih.nlm.umls.mmsys.io.RRFMetamorphoSysOutputStream.remove_mth_only=false
#gov.nih.nlm.umls.mmsys.io.RRFMetamorphoSysOutputStream.subset_dir=C\:\\Users\\Mark\\Desktop\\2019AA-full\\2019AA\\META
gov.nih.nlm.umls.mmsys.io.RRFMetamorphoSysOutputStream.truncate=false
gov.nih.nlm.umls.mmsys.io.RRFMetamorphoSysOutputStream.versioned_output=false
install_lex=false
install_lvg=false
install_meta=true
install_net=false
install_umls=true
#meta_destination_uri=C\:\\Users\\Mark\\Desktop\\2019AA-full\\2019AA\\META
#meta_source_uri=C\:\\Users\\Mark\\Desktop\\2019AA-full
mmsys_input_stream=gov.nih.nlm.umls.mmsys.io.NLMFileMetamorphoSysInputStream
mmsys_output_stream=gov.nih.nlm.umls.mmsys.io.RRFMetamorphoSysOutputStream
release_version=2019AA
#umls_destination_uri=C\:\\Users\\Mark\\Desktop\\2019AA-full
versioned_output=false
```
Then start creating the _RRF_ files:

```BASH
$ ./metamorphosys_batch.sh
```


----

next: populate MySQL database

enter MySQL credentials into `populate_mysql_db.sh populate_mysql_db.sh`.  Note... one a typical Ubuntu system with MySQL installed via apt,

> MYSQL_HOME=/usr/
> 
UMLS recommends MySQL 5.5, but I don't believe I have had any problems with much more recent (MariaDB) versions.

I have been creating a separate MySQL database for each UMLS release.

Because the MySQL load scripts seem to have been written with Windows line endings in mind, it will probably be necessary to change the line endings in `mysql_tables.sql` from `lines terminated by '\r\n'` to `lines terminated by '\n'`

Then:

`$ ./populate_mysql_db.sh`

Now the selected UMLS sources are available in the MySQL database. So use [NCBO's umls2rdf](https://github.com/ncbo/umls2rdf) to dump selected MySQL content to RDF files.

Edit the source choices in `umls.conf`, copying from `conf_sample.py` if necessary,  and the database connection in `conf.py`.  I have had difficulty exporting some sources (like `MTHSPL`) despite multiple different attempts and request for help from NCBO and stackoverflow. One also needs to indicate whether the IRIs for UMLS terms should based on their native codes, or on the UMLS assigned CUIs. CUIs are a better choice for linking to other UMLS terms, but codes may be a better choice for connecting to OMOP concepts. Some sources, however, do not have native codes.

Then 
- make sure that the permissions on `umls2rdf.py` allow it to be executed by the current user
- make sure python 2 is installed
	- you may need to change the first line of  `umls2rdf` so that it points to the python 2 binary, like `#! /usr/bin/env python2.7`, instead of `#! /usr/bin/env python`
- make sure that the required python libraries have been loaded. Some of them may have system dependencies.
    - MySQLdb
    - urllib
- these libraries are imported, too, but should be available as part of the standard library
   - codecs
    - collections
    - os
    - pdb
    - string.Template
    - sys

- make sure the output directory exists
    - and check if you might overwrite a file
-  `cd` into the directory that contains the `umls2rdf` script and/or run it with the pull path

```BASH
$ ./umls2rdf.py
```
Copy the resulting Turtle files into the `graphdb-import` folder on the GraphDB server where they disease to diagnosis repository is going to be constructed.

One good place to store files like these, and move them onto another location, is Amazon S3.

Also required in the `graphdb-import` folder: `www_nlm_nih_gov_research_umls_mapping_projects_icd9cm_to_snomedct.ttl`, or some equivalent files that contains a direct mapping of the two csv files in the zip archive downloadable from https://www.nlm.nih.gov/research/umls/mapping_projects/icd9cm_to_snomedct.html

Next, run [https://github.com/PennTURBO/disease_to_diagnosis_code/blob/master/disease_diagnosis_dev.R](https://github.com/PennTURBO/disease_to_diagnosis_code/blob/master/disease_diagnosis_dev.R)

That R script is extensively commented.

----

## Orientation to the named graphs

### MonDO

#### Class usage

```SPARQL
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
select
?o ?l (count(?s) as ?count)
where {
    graph <http://purl.obolibrary.org/obo/mondo.owl> {
        ?s rdf:type ?o .
        optional {
            ?o rdfs:label ?l
        }
    }
}
group by ?o ?l
order by desc(count(distinct ?s)) ?o
```

**o**|**l**|**count**
:-----|:-----|-----:
owl:Axiom| |263471
owl:Class| |117778
owl:Restriction| |22425
owl:AnnotationProperty| |70
owl:ObjectProperty| |27
owl:Ontology| |1
owl:TransitiveProperty| |1

#### Predicate usage

```SPARQL
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
select
?p ?l (count(distinct ?s) as ?count)
where {
    graph <http://purl.obolibrary.org/obo/mondo.owl> {
        ?s ?p ?o .
        optional {
            ?p rdfs:label ?l
        }
    }
}
group by ?p ?l
order by desc(count(distinct ?s))
```

**p**|**l**|**count**
:-----:|:-----:|-----:
rdf:type| |403772
owl:annotatedProperty| |263471
owl:annotatedSource| |263471
owl:annotatedTarget| |263471
oboInOwl:source| |148839
oboInOwl:hasDbXref|database\_cross\_reference|136711
owl:equivalentClass| |65043
rdfs:label| |23556
oboInOwl:id| |23535
owl:onProperty| |22425
owl:someValuesFrom| |22425
rdfs:subClassOf| |22027
skos:exactMatch| |21577
oboInOwl:hasExactSynonym|has\_exact\_synonym|17642
obo:IAO\_0000115|definition|15442
rdf:first| |15358
rdf:rest| |15358
oboInOwl:hasRelatedSynonym|has\_related\_synonym|11375
oboInOwl:inSubset|in\_subset|10945
owl:intersectionOf| |7452
skos:closeMatch| |7110
rdfs:seeAlso|seeAlso|3042
owl:deprecated| |1781
obo:IAO\_0100001|term replaced by|1554
rdfs:comment| |996
oboInOwl:hasSynonymType|has\_synonym\_type|860
mondo:excluded\_subClassOf|excluded subClassOf|776
oboInOwl:hasNarrowSynonym|has\_narrow\_synonym|290
oboInOwl:hasBroadSynonym|has\_broad\_synonym|262
oboInOwl:consider|consider|119
obo:IAO\_0000231| |113
oboInOwl:hasAlternativeId|has\_alternative\_id|111
owl:disjointWith| |68
dc:date| |55
dc:creator| |54
rdfs:subPropertyOf| |34
oboInOwl:shorthand|shorthand|17
oboInOwl:created\_by| |16
owl:unionOf| |11
skos:broadMatch| |11
skos:narrowMatch| |10
mondo:excluded\_synonym| |7
owl:propertyChainAxiom| |7
oboInOwl:is\_metadata\_tag| |4
oboInOwl:notes| |3
oboInOwl:is\_class\_level| |2
oboInOwl:hasOBOFormatVersion|has\_obo\_format\_version|1
mondo:may\_be\_merged\_into|may\_be\_merged\_into|1
obo:RO\_0002161|never in taxon|1
mondo:pathogenesis| |1
mondo:related| |1
dc:title| |1
terms:description| |1
terms:license| |1
terms:source| |1
oboInOwl:creation\_date| |1
oboInOwl:modified\_by| |1
oboInOwl:severity| |1
owl:imports| |1
owl:versionIRI| |1
foaf:homepage| |1

### Predicate usage on `owl:Axiom`s

```SPARQL
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX owl: <http://www.w3.org/2002/07/owl#>
select
?p ?l (count(distinct ?s) as ?count)
where {
    graph <http://purl.obolibrary.org/obo/mondo.owl> {
        ?s a owl:Axiom ;
           ?p ?o .
        optional {
            ?p rdfs:label ?l
        }
    }
}
group by ?p ?l
order by desc(count(distinct ?s)) ?p
```

**p**|**l**|**count**
:-----|:-----|-----:
rdf:type| |263471
owl:annotatedProperty| |263471
owl:annotatedSource| |263471
owl:annotatedTarget| |263471
oboInOwl:source| |148839
oboInOwl:hasDbXref|database\_cross\_reference|114619
oboInOwl:hasSynonymType|has\_synonym\_type|860
rdfs:comment| |11
oboInOwl:notes| |3
obo:IAO\_0000115|definition|1
oboInOwl:hasExactSynonym|has\_exact\_synonym|1
oboInOwl:modified\_by| |1
oboInOwl:severity| |1

### Predicate usage on `owl:Restriction`s

```SPARQL
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX owl: <http://www.w3.org/2002/07/owl#>
select
?p ?l (count(distinct ?s) as ?count)
where {
    graph <http://purl.obolibrary.org/obo/mondo.owl> {
        ?s a owl:Restriction ;
           ?p ?o .
        optional {
            ?p rdfs:label ?l
        }
    }
}
group by ?p ?l
order by desc(count(distinct ?s)) ?p
```

**p**|**l**|**count**
:-----|:-----|-----:
rdf:type| |22425
owl:onProperty| |22425
owl:someValuesFrom| |22425

### Predicate usage on `owl:Class`es

```SPARQL
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX owl: <http://www.w3.org/2002/07/owl#>
select
?p ?l (count(distinct ?s) as ?count)
where {
    graph <http://purl.obolibrary.org/obo/mondo.owl> {
        ?s a owl:Class ;
           ?p ?o .
        optional {
            ?p rdfs:label ?l
        }
    }
}
group by ?p ?l
order by desc(count(distinct ?s)) ?p
```

**p**|**l**|**count**
:-----|:-----|-----:
rdf:type| |117778
owl:equivalentClass| |65043
oboInOwl:id| |23506
rdfs:label| |23506
oboInOwl:hasDbXref|database\_cross\_reference|22075
rdfs:subClassOf| |21951
skos:exactMatch| |21577
oboInOwl:hasExactSynonym|has\_exact\_synonym|17641
obo:IAO\_0000115|definition|15441
oboInOwl:hasRelatedSynonym|has\_related\_synonym|11375
oboInOwl:inSubset|in\_subset|10945
owl:intersectionOf| |7452
skos:closeMatch| |7110
rdfs:seeAlso|seeAlso|3042
owl:deprecated| |1781
obo:IAO\_0100001|term replaced by|1554
rdfs:comment| |957
mondo:excluded\_subClassOf|excluded subClassOf|776
oboInOwl:hasNarrowSynonym|has\_narrow\_synonym|290
oboInOwl:hasBroadSynonym|has\_broad\_synonym|262
oboInOwl:consider|consider|119
obo:IAO\_0000231| |113
oboInOwl:hasAlternativeId|has\_alternative\_id|111
owl:disjointWith| |68
dc:date| |55
dc:creator| |54
oboInOwl:created\_by| |16
owl:unionOf| |11
skos:broadMatch| |11
skos:narrowMatch| |10
mondo:excluded\_synonym| |7
obo:RO\_0002161|never in taxon|1
mondo:may\_be\_merged\_into|may\_be\_merged\_into|1
mondo:pathogenesis| |1
mondo:related| |1
oboInOwl:creation\_date| |1


### subClassOf patterns

```SPARQL
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX owl: <http://www.w3.org/2002/07/owl#>
select
?st ?ot ?isuri_o (count(distinct ?s) as ?count)
where {
    graph <http://purl.obolibrary.org/obo/mondo.owl> {
        ?s rdfs:subClassOf ?o .
        optional {
            ?s a ?st .
        }
        optional {
            ?o a ?ot .
        }
    }
    bind(isuri(?o) as ?isuri_o)
}
group by ?st ?ot ?isuri_o
order by desc(count(distinct ?s))
```

**st**|**ot**|**isuri\_o**|**count**
:-----|:-----|:-----|-----:
owl:Class|owl:Class|true|21857
owl:Class|owl:Restriction|false|7929
owl:Class| |true|102
. |owl:Class|true|76

### equivalentClass patterns

```SPARQL
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX owl: <http://www.w3.org/2002/07/owl#>
select
?st ?ot ?isuri_o (count(distinct ?s) as ?count)
where {
    graph <http://purl.obolibrary.org/obo/mondo.owl> {
        ?s owl:equivalentClass ?o .
        optional {
            ?s a ?st .
        }
        optional {
            ?o a ?ot .
        }
    }
    bind(isuri(?o) as ?isuri_o)
}
group by ?st ?ot ?isuri_o
order by desc(count(distinct ?s))
```

**st**|**ot**|**isuri\_o**|**count**
:-----|:-----|:-----|-----:
owl:Class|owl:Class|true|64721
owl:Class|owl:Class|false|7334

### ICD9CM_TO_SNOMEDCT_DIAGNOSIS_201812.zip

(Ontorefine instantiation of two CSV files from [https://www.nlm.nih.gov/research/umls/mapping_projects/icd9cm_to_snomedct.html](https://www.nlm.nih.gov/research/umls/mapping_projects/icd9cm_to_snomedct.html))

_Based on input from Anurag Verma, we are not using the General Equivalence Mappings from_ [https://www.cms.gov/Medicare/Coding/ICD10/index?redirect=/ICD10/01_Overview.asp#TopOfPage](https://www.cms.gov/Medicare/Coding/ICD10/index?redirect=/ICD10/01_Overview.asp#TopOfPage)

```SPARQL
select 
?p (count(?s) as ?count)
where {
    graph <https://www.nlm.nih.gov/research/umls/mapping_projects/icd9cm_to_snomedct.html> {
        ?s ?p ?o .
    }
}
group by ?p 
order by desc(count(?s))
```

> Showing results from 1 to 15 of 15. Query took 1.3s, minutes ago.

**p**|**count**
:-----|-----:
mydata:AVG\_USAGE|46645
mydata:CORE\_USAGE|46645
mydata:File|46645
mydata:ICD\_CODE|46645
mydata:ICD\_NAME|46645
mydata:IN\_CORE|46645
mydata:IP\_USAGE|46645
mydata:IS\_1-1MAP|46645
mydata:IS\_CURRENT\_ICD|46645
mydata:IS\_NEC|46645
mydata:OP\_USAGE|46645
mydata:SNOMED\_CID|46645
mydata:SNOMED\_FSN|46645
rdf:type|46645
https://www.nlm.nih.gov/research/umls/mapping\_projects/icd9cm\_to\_snomedct.html|45598

_Why is the mapping predicate used 45598 times, but the others are all only used 46645 times?_

_Note that the mapping predicate and graph name have been written with a trailing slash in some places and without in others. Standardize to WITHOUT_


## Actions performed by [disease_diagnosis_dev.R](https://github.com/PennTURBO/disease_to_diagnosis_code/blob/master/disease_diagnosis_dev.R) script

###  Materialize CUIs

- later... check if CUIs asserted by MonDO are actually claimed by any UMLS->BioPortal terms?
- see source predicate, destination graph, destination predicate and destination subject template below

```SPARQL
PREFIX mydata: <http://example.com/resource/>
PREFIX umls: <http://bioportal.bioontology.org/ontologies/umls/>
insert {
    graph <http://example.com/resource/materializedCui> {
        ?c a  <http://example.com/resource/materializedCui> .
        ?s <http://example.com/resource/materializedCui> ?c
    }
} where {
    ?s umls:cui ?o .
    bind(uri(concat("http://example.com/cui/", ?o)) as ?c)
}
```

> Added 939750 statements. Update took 30s, minutes ago.

### Rewrite subjects of "reverse" MonDO assertions

"Reverse" means a MonDO term is the object. "Rewriting" means aligning the URI structure with the ICD and SNOMED URIs used by BioPortal, and our CUI materializations.

This doesn't guarantee that the subject term is actually defined by the ICDs or SNOMED, or that it is a valid CUI. ICD9 ranges may need to be removed or isolated at a later point.

_In previous disease/diagnosis repos, forward and reverse rewrites kept MonDO's native orientation and were put in a single named graph,_ `<http://example.com/resource/rewrites>` 

```SPARQL
PREFIX mydata: <http://example.com/resource/>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
PREFIX owl: <http://www.w3.org/2002/07/owl#>
# remove icd9 ranges LATER?, even if they are defined ?rewrite a ?t
insert {
    graph <http://example.com/resource/rewrites_MonDO_object> {
        ?mondo ?p ?rewrite
    }
}
where {
    graph <http://purl.obolibrary.org/obo/mondo.owl> {
        values ?p {
            skos:exactMatch
            skos:closeMatch
            # skos:narrowMatch
            owl:equivalentClass
        }
        values (?mondoPattern ?rewritePattern) {
            ("http://linkedlifedata.com/resource/umls/id/" "http://example.com/cui/")
            ("http://identifiers.org/snomedct/" "http://purl.bioontology.org/ontology/SNOMEDCT/")
            ("http://purl.obolibrary.org/obo/SCTID_" "http://purl.bioontology.org/ontology/SNOMEDCT/")
            ("http://purl.obolibrary.org/obo/ICD10_" "http://purl.bioontology.org/ontology/ICD10CM/")
            ("http://purl.obolibrary.org/obo/ICD9_" "http://purl.bioontology.org/ontology/ICD9CM/")
        }
        ?external  ?p ?mondo .
        filter(strstarts(str(?external),?mondoPattern))
        filter(strstarts(str(?mondo),"http://purl.obolibrary.org/obo/MONDO_"))
        bind(uri(concat(?rewritePattern,strafter(str(?external),?mondoPattern))) as ?rewrite)
        #        ?rewrite a ?t
    }
}
```

> Added 19609 statements. Update took 5s, minutes ago.

### Rewrite subjects of "forward" MonDO assertions

```SPARQL
PREFIX mydata: <http://example.com/resource/>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
PREFIX owl: <http://www.w3.org/2002/07/owl#>
# remove icd9 ranges LATER?, even if they are defined ?rewrite a ?t
insert {
    graph <http://example.com/resource/rewrites_MonDO_subject> {
        ?mondo ?p ?rewrite
    }
}
where {
    graph <http://purl.obolibrary.org/obo/mondo.owl> {
        values ?p {
            skos:exactMatch
            skos:closeMatch
            # skos:narrowMatch
            owl:equivalentClass
        }
        values (?mondoPattern ?rewritePattern) {
            ("http://linkedlifedata.com/resource/umls/id/" "http://example.com/cui/")
            ("http://identifiers.org/snomedct/" "http://purl.bioontology.org/ontology/SNOMEDCT/")
            ("http://purl.obolibrary.org/obo/SCTID_" "http://purl.bioontology.org/ontology/SNOMEDCT/")
            ("http://purl.obolibrary.org/obo/ICD10_" "http://purl.bioontology.org/ontology/ICD10CM/")
            ("http://purl.obolibrary.org/obo/ICD9_" "http://purl.bioontology.org/ontology/ICD9CM/")
        }
        ?mondo ?p ?external .
        filter(strstarts(str(?external),?mondoPattern))
        filter(strstarts(str(?mondo),"http://purl.obolibrary.org/obo/MONDO_"))
        bind(uri(concat(?rewritePattern,strafter(str(?external),?mondoPattern))) as ?rewrite)
        #        ?rewrite a ?t
    }
}
```

> Added 50572 statements. Update took 8.3s, minutes ago.

### Materialize MonDO database cross references 

```SPARQL
PREFIX mydata: <http://example.com/resource/>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
PREFIX owl: <http://www.w3.org/2002/07/owl#>
# remove icd9 ranges, even if they are defined (?rewrite a ?t)
insert {
    graph <http://example.com/resource/rewrites_MonDO_subject> {
        ?mondo mydata:mdbxr ?rewrite
    }
}
where {
    graph <http://purl.obolibrary.org/obo/mondo.owl> {
        values (?mondoPattern ?rewritePattern) {
            ("UMLS:" "http://example.com/cui/")
            ("SCTID:" "http://purl.bioontology.org/ontology/SNOMEDCT/")
            ("ICD10:" "http://purl.bioontology.org/ontology/ICD10CM/")
            ("ICD9:" "http://purl.bioontology.org/ontology/ICD9CM/")
        }
        ?mondo <http://www.geneontology.org/formats/oboInOwl#hasDbXref> ?external .
        filter(strstarts(?external,?mondoPattern))
        filter(strstarts(str(?mondo),"http://purl.obolibrary.org/obo/MONDO_"))
        bind(uri(concat(?rewritePattern,strafter(str(?external),?mondoPattern))) as ?rewrite)
        #        ?rewrite a ?t
    }
}
```

> Added 43154 statements. Update took 6.5s, moments ago.

### Isolate undefined rewrites

```SPARQL
insert {
    graph <http://example.com/resource/undefinedRewrites> {
        ?mondo ?p ?rewrite
    }
}
where {
    {
        {
            graph <http://example.com/resource/rewrites_MonDO_object> {
                ?mondo ?p ?rewrite
            }
        } 
        union {
            {
                graph <http://example.com/resource/rewrites_MonDO_subject> {
                    ?mondo ?p ?rewrite
                }
            }  
        }
    }
    minus {
        ?rewrite a ?t
    }
}
```

### Delete undefined reverse rewrites

```SPARQL
delete {
    graph <http://example.com/resource/rewrites_MonDO_object> {
        ?mondo ?p ?rewrite
    }
}
where {
    graph <http://example.com/resource/undefinedRewrites> {
        ?mondo ?p ?rewrite
    }
}
```

> Removed 9328 statements. Update took 0.6s, minutes ago.

### Delete undefined forward rewrites

```SPARQL
delete {
    graph <http://example.com/resource/rewrites_MonDO_subject> {
        ?mondo ?p ?rewrite
    }
}
where {
    graph <http://example.com/resource/undefinedRewrites> {
        ?mondo ?p ?rewrite
    }
}
```

> Removed 58530 statements. Update took 1.2s, moments ago.

### Isolate ICD9 ranges

```SPARQL
insert {
    graph <http://example.com/resource/icd9range> {
        ?mondo ?p ?rewrite
    }
}
where {
    {
        {
            graph <http://example.com/resource/rewrites_MonDO_object> {
                ?mondo ?p ?rewrite
            }
        } 
        union {
            {
                graph <http://example.com/resource/rewrites_MonDO_subject> {
                    ?mondo ?p ?rewrite
                }
            }  
        }
    }
    filter(strstarts(str( ?rewrite ),"http://purl.bioontology.org/ontology/ICD9CM/"))
    filter(contains(str( ?rewrite),"-"))
}
```

> Added 31 statements. Update took 0.4s, minutes ago.

### Delete forward ICD9 ranges

```SPARQL
delete {
    graph <http://example.com/resource/rewrites_MonDO_subject> {
        ?mondo ?p ?rewrite
    }
}
where {
    graph <http://example.com/resource/icd9range> {
        ?mondo ?p ?rewrite
    }
}
```
_Deleted all 31 of the isolated triples. Timing lost._



### Delete reverse ICD9 ranges

```SPARQL
delete {
    graph <http://example.com/resource/rewrites_MonDO_object> {
        ?mondo ?p ?rewrite
    }
}
where {
    graph <http://example.com/resource/icd9range> {
        ?mondo ?p ?rewrite
    }
}
```

_Deleted 0 of the isolated triples. Timing lost._

### Isolate re-writable external-link statements from MonDO

This leaves in place all `subClassOf` statements, and any `equivalentClass` statements that take a restriction, or other blank node as their object. 

```SPARQL
PREFIX mydata: <http://example.com/resource/>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
PREFIX owl: <http://www.w3.org/2002/07/owl#>
insert {
    graph <http://example.com/resource/mondoOriginals> {
        ?s ?p ?o
    }
}
where {
    graph <http://purl.obolibrary.org/obo/mondo.owl> {
        values ?p {
            skos:exactMatch
            skos:closeMatch
            # skos:narrowMatch
            owl:equivalentClass
        }
        ?s ?p ?o
        filter(isuri(?o))
    }
}
```

> Added 167354 statements. Update took 3.9s, minutes ago.

### Delete re-writable external-link statements from _MonDO named graph_

They're still available in the isolation graph above (unless a decision is made to clear it.)

```SPARQL
PREFIX mydata: <http://example.com/resource/>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
PREFIX owl: <http://www.w3.org/2002/07/owl#>
delete {
    graph <http://purl.obolibrary.org/obo/mondo.owl> {
        ?s ?p ?o
    }
}
where {
    graph <http://example.com/resource/mondoOriginals> {
        ?s ?p ?o
    }
}
```

> Removed 167354 statements. Update took 3.1s, moments ago.

### Tag ICD9->SNOMED predicates that should take a Boolean object

```SPARQL
PREFIX mondo: <http://purl.obolibrary.org/obo/mondo#>
PREFIX mydata: <http://example.com/resource/>
PREFIX obo: <http://purl.obolibrary.org/obo/>
PREFIX ontologies: <http://transformunify.org/ontologies/>
PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
PREFIX sm: <tag:stardog:api:mapping:>
PREFIX turbo: <http://transformunify.org/ontologies/>
PREFIX umls: <http://bioportal.bioontology.org/ontologies/umls/>
PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
insert data {
    graph <https://www.nlm.nih.gov/research/umls/mapping_projects/icd9cm_to_snomedct.html> {
        mydata:IS_CURRENT_ICD mydata:intPlaceholder true .
        mydata:IS_NEC mydata:intPlaceholder true .
        mydata:IS_1-1MAP mydata:intPlaceholder true .
        mydata:IN_CORE mydata:intPlaceholder true .
        <https://www.nlm.nih.gov/research/umls/mapping_projects/icd9cm_to_snomedct.html> rdfs:comment "NLM ICD9CM to SNOMED mapping, with predicates taking booleans tagged" .
    }
}
```

> Added 5 statements. Update took 0.1s, moments ago.


### Enforce (cast) Boolean objects

```SPARQL
PREFIX mondo: <http://purl.obolibrary.org/obo/mondo#>
PREFIX mydata: <http://example.com/resource/>
PREFIX obo: <http://purl.obolibrary.org/obo/>
PREFIX ontologies: <http://transformunify.org/ontologies/>
PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
PREFIX sm: <tag:stardog:api:mapping:>
PREFIX turbo: <http://transformunify.org/ontologies/>
PREFIX umls: <http://bioportal.bioontology.org/ontologies/umls/>
PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
insert {
    graph <https://www.nlm.nih.gov/research/umls/mapping_projects/icd9cm_to_snomedct.html_boolean> {
        ?s ?p ?boolean
    }
} where {
    graph <https://www.nlm.nih.gov/research/umls/mapping_projects/icd9cm_to_snomedct.html> {
        ?p mydata:intPlaceholder true .
        ?s ?p ?int .
        filter(datatype(?int)!=xsd:boolean)
        bind(if(?int = "1", true, false) as ?boolean)
    }
}
```

_This has already been applied to the_ `www_nlm_nih_gov_research_umls_mapping_projects_icd9cm_to_snomedct.ttl` _input file, so it may seem like no action is taking place. There's no harm in leaving these steps in, and they might be required if the two (CSV) ICD9->SNOMED mapping  files had to be re-instantiated with OntoRefine or some other technology._

Imported successfully in 18s.
> Added 5 statements. Update took 0.1s, moments ago.

### Delete the triples that have undesired integer objects

```SPARQL
PREFIX mondo: <http://purl.obolibrary.org/obo/mondo#>
PREFIX mydata: <http://example.com/resource/>
PREFIX obo: <http://purl.obolibrary.org/obo/>
PREFIX ontologies: <http://transformunify.org/ontologies/>
PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
PREFIX sm: <tag:stardog:api:mapping:>
PREFIX turbo: <http://transformunify.org/ontologies/>
PREFIX umls: <http://bioportal.bioontology.org/ontologies/umls/>
PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
delete {
    ?s ?p ?int .
} where {
    graph <https://www.nlm.nih.gov/research/umls/mapping_projects/icd9cm_to_snomedct.html> {
        ?p mydata:intPlaceholder true .
        ?s ?p ?int .
        filter(datatype(?int)!=xsd:boolean)
    }
}
```

>  The number of statements did not change

### Migrate the desired triples with Boolean objects out of the temporary graph

```SPARQL
PREFIX mondo: <http://purl.obolibrary.org/obo/mondo#>
PREFIX mydata: <http://example.com/resource/>
PREFIX obo: <http://purl.obolibrary.org/obo/>
PREFIX ontologies: <http://transformunify.org/ontologies/>
PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
PREFIX sm: <tag:stardog:api:mapping:>
PREFIX turbo: <http://transformunify.org/ontologies/>
PREFIX umls: <http://bioportal.bioontology.org/ontologies/umls/>
PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
insert {
    graph <https://www.nlm.nih.gov/research/umls/mapping_projects/icd9cm_to_snomedct.html> {
        ?s ?p ?boolean
    }
}
where {
    graph <https://www.nlm.nih.gov/research/umls/mapping_projects/icd9cm_to_snomedct.html_boolean> {
        ?s ?p ?boolean
    }
}
```

> The number of statements did not change

### Clear the temporary graph

```SPARQL
clear graph <https://www.nlm.nih.gov/research/umls/mapping_projects/icd9cm_to_snomedct.html_boolean>
```

> The number of statements did not change

### Materialize the ICD9->SNOMED mappings

```SPARQL
PREFIX mondo: <http://purl.obolibrary.org/obo/mondo#>
PREFIX mydata: <http://example.com/resource/>
PREFIX obo: <http://purl.obolibrary.org/obo/>
PREFIX ontologies: <http://transformunify.org/ontologies/>
PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
PREFIX sm: <tag:stardog:api:mapping:>
PREFIX turbo: <http://transformunify.org/ontologies/>
PREFIX umls: <http://bioportal.bioontology.org/ontologies/umls/>
PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
insert {
    graph <https://www.nlm.nih.gov/research/umls/mapping_projects/icd9cm_to_snomedct.html> {
        ?icd <https://www.nlm.nih.gov/research/umls/mapping_projects/icd9cm_to_snomedct.html> ?snomed
    }
} where {
    graph <https://www.nlm.nih.gov/research/umls/mapping_projects/icd9cm_to_snomedct.html> {
        ?s mydata:ICD_CODE	?ICD_CODE	;
           mydata:SNOMED_CID ?SNOMED_CID .
        bind(uri(concat("http://purl.bioontology.org/ontology/SNOMEDCT/", ?SNOMED_CID)) as ?snomed)
        bind(uri(concat("http://purl.bioontology.org/ontology/ICD9CM/", ?ICD_CODE)) as ?icd)
    }
    graph <http://purl.bioontology.org/ontology/SNOMEDCT/> {
        ?snomed a owl:Class
    }
    graph <http://purl.bioontology.org/ontology/ICD9CM/> {
        ?icd a owl:Class
    }
}
```

> The number of statements did not change

### _End of ICD9->SNOMED steps_

### Isolate statements about ICD10 siblings

_These statements don't add any knowledge over having a shared super-class, and they clutter up visualizations._

```SPARQL
PREFIX mondo: <http://purl.obolibrary.org/obo/mondo#>
PREFIX mydata: <http://example.com/resource/>
PREFIX obo: <http://purl.obolibrary.org/obo/>
PREFIX ontologies: <http://transformunify.org/ontologies/>
PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
PREFIX sm: <tag:stardog:api:mapping:>
PREFIX turbo: <http://transformunify.org/ontologies/>
PREFIX umls: <http://bioportal.bioontology.org/ontologies/umls/>
PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
insert  {
    graph <http://example.com/resource/ICD10CM_siblings> {
        ?s <http://purl.bioontology.org/ontology/ICD10CM/SIB> ?o
    }
}
where {
    graph <http://purl.bioontology.org/ontology/ICD10CM/> {
        ?s <http://purl.bioontology.org/ontology/ICD10CM/SIB> ?o
    }
}
```

> Added 458236 statements

_Lost the timing data_

### Delete siblings statements from ICD10 graph

```SPARQL
PREFIX mondo: <http://purl.obolibrary.org/obo/mondo#>
PREFIX mydata: <http://example.com/resource/>
PREFIX obo: <http://purl.obolibrary.org/obo/>
PREFIX ontologies: <http://transformunify.org/ontologies/>
PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
PREFIX sm: <tag:stardog:api:mapping:>
PREFIX turbo: <http://transformunify.org/ontologies/>
PREFIX umls: <http://bioportal.bioontology.org/ontologies/umls/>
PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
delete  {
    graph <http://purl.bioontology.org/ontology/ICD10CM/> {
        ?s <http://purl.bioontology.org/ontology/ICD10CM/SIB> ?o
    }
}
where {
    graph <http://purl.bioontology.org/ontology/ICD10CM/> {
        ?s <http://purl.bioontology.org/ontology/ICD10CM/SIB> ?o
    }
}
```

> Removed 458236 statements. Update took 8.8s, moments ago.


### Isolate statements about ICD9 siblings

_These statements don't add any knowledge over having a shared super-class, and they clutter up visualizations._

```SPARQL
PREFIX mondo: <http://purl.obolibrary.org/obo/mondo#>
PREFIX mydata: <http://example.com/resource/>
PREFIX obo: <http://purl.obolibrary.org/obo/>
PREFIX ontologies: <http://transformunify.org/ontologies/>
PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
PREFIX sm: <tag:stardog:api:mapping:>
PREFIX turbo: <http://transformunify.org/ontologies/>
PREFIX umls: <http://bioportal.bioontology.org/ontologies/umls/>
PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
insert  {
    graph <http://example.com/resource/ICD9CM_siblings> {
        ?s <http://purl.bioontology.org/ontology/ICD9CM/SIB> ?o
    }
}
where {
    graph <http://purl.bioontology.org/ontology/ICD9CM/> {
        ?s <http://purl.bioontology.org/ontology/ICD9CM/SIB> ?o
    }
}
```

> Added 138124 statements. Update took 2.7s, minutes ago.


### Delete siblings statements from ICD9 graph

```SPARQL
PREFIX mondo: <http://purl.obolibrary.org/obo/mondo#>
PREFIX mydata: <http://example.com/resource/>
PREFIX obo: <http://purl.obolibrary.org/obo/>
PREFIX ontologies: <http://transformunify.org/ontologies/>
PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
PREFIX sm: <tag:stardog:api:mapping:>
PREFIX turbo: <http://transformunify.org/ontologies/>
PREFIX umls: <http://bioportal.bioontology.org/ontologies/umls/>
PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
delete  {
    graph <http://purl.bioontology.org/ontology/ICD9CM/> {
        ?s <http://purl.bioontology.org/ontology/ICD9CM/SIB> ?o
    }
}
where {
    graph <http://purl.bioontology.org/ontology/ICD9CM/> {
        ?s <http://purl.bioontology.org/ontology/ICD9CM/SIB> ?o
    }
}
```

> Removed 138124 statements. Update took 2.5s, moments ago.

### Assert the named graph in which terms are defined

```SPARQL
PREFIX mondo: <http://purl.obolibrary.org/obo/mondo#>
PREFIX mydata: <http://example.com/resource/>
PREFIX obo: <http://purl.obolibrary.org/obo/>
PREFIX ontologies: <http://transformunify.org/ontologies/>
PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
PREFIX sm: <tag:stardog:api:mapping:>
PREFIX turbo: <http://transformunify.org/ontologies/>
PREFIX umls: <http://bioportal.bioontology.org/ontologies/umls/>
PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
insert {
    graph <http://example.com/resource/definedIn> {
        ?s <http://example.com/resource/definedIn> ?g
    }
} where {
    graph ?g {
        ?s a owl:Class
    }
}
```

> Added 593053 statements. Update took 15s, moments ago.

### Materialize simple MonDO disease axioms

_This only acts on subclasses of simple `owl:Restriction`s. It (probably?) won't act on `rdfs:subClassOf` statements whose object is a  blank node, intersection, etc. Same thing for any `owl:equivalentClass` statements, although they tend to have those complex objects anyway._

```SPARQL
PREFIX mondo: <http://purl.obolibrary.org/obo/mondo#>
PREFIX mydata: <http://example.com/resource/>
PREFIX obo: <http://purl.obolibrary.org/obo/>
PREFIX ontologies: <http://transformunify.org/ontologies/>
PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
PREFIX sm: <tag:stardog:api:mapping:>
PREFIX turbo: <http://transformunify.org/ontologies/>
PREFIX umls: <http://bioportal.bioontology.org/ontologies/umls/>
PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
insert {
    graph mydata:materializedSimpleMondoAxioms {
        ?term ?op ?valSource
    }
}
where {
    graph obo:mondo.owl {
        ?term rdfs:subClassOf* ?restr .
        # ?term rdfs:label ?termlab .
        ?restr a owl:Restriction ;
               owl:onProperty ?op ;
               owl:someValuesFrom ?valSource .
        # ?op rdfs:label ?opl .
        # ?valSource rdfs:label ?vsl .
        filter(isuri( ?term ))
    }
}
```

> Added 213298 statements. Update took 1m 26s, moments ago.

### What are the roots of the ICD9CM taxonomy?

```SPARQL
PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
select 
distinct ?s ?l
where {
    graph <http://purl.bioontology.org/ontology/ICD9CM/> {
        ?s a owl:Class .
        optional {
            ?s skos:prefLabel ?l
        }
        minus {
            ?s rdfs:subClassOf ?parent
        }
    }
}
```

> Showing results from 1 to 2 of 2. Query took 0.4s, minutes ago.

**s**|**l**
:-----|-----:
http://purl.bioontology.org/ontology/STY/T051|Event
http://purl.bioontology.org/ontology/STY/T071|Entity

#### BioPortal says

- [DISEASES AND INJURIES](https://bioportal.bioontology.org/ontologies/ICD9CM/?p=classes&conceptid=http%3A%2F%2Fpurl.bioontology.org%2Fontology%2FICD9CM%2F001-999.99)
	-  ICD9CM:001-999.99
- [PROCEDURES](https://bioportal.bioontology.org/ontologies/ICD9CM/?p=classes&conceptid=http%3A%2F%2Fpurl.bioontology.org%2Fontology%2FICD9CM%2F00-99.99)
	-   ICD9CM:00-99.99
-  [SUPPLEMENTARY CLASSIFICATION OF EXTERNAL CAUSES OF INJURY AND POISONING](https://bioportal.bioontology.org/ontologies/ICD9CM/?p=classes&conceptid=http%3A%2F%2Fpurl.bioontology.org%2Fontology%2FICD9CM%2FE000-E999.9)
	-   ICD9CM:E000-E999.9
- [SUPPLEMENTARY CLASSIFICATION OF FACTORS INFLUENCING HEALTH STATUS AND CONTACT WITH HEALTH SERVICES](https://bioportal.bioontology.org/ontologies/ICD9CM/?p=classes&conceptid=http%3A%2F%2Fpurl.bioontology.org%2Fontology%2FICD9CM%2FV01-V91.99)
	- ICD9CM:V01-V91.99

### Transitively materialize sub-classes of ICD9 Diseases and Injuries

```SPARQL
PREFIX mondo: <http://purl.obolibrary.org/obo/mondo#>
PREFIX mydata: <http://example.com/resource/>
PREFIX obo: <http://purl.obolibrary.org/obo/>
PREFIX ontologies: <http://transformunify.org/ontologies/>
PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
PREFIX sm: <tag:stardog:api:mapping:>
PREFIX turbo: <http://transformunify.org/ontologies/>
PREFIX umls: <http://bioportal.bioontology.org/ontologies/umls/>
PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
insert {
    graph mydata:ICD9DiseaseInjuryTransitiveSubClasses {
        ?sub rdfs:subClassOf ?s .
    }
}
where {
    graph <http://purl.bioontology.org/ontology/ICD9CM/> {
        # + or * ?
        ?s rdfs:subClassOf* <http://purl.bioontology.org/ontology/ICD9CM/001-999.99> .
        ?sub rdfs:subClassOf* ?s .
    }
}
```

> Added 81980 statements. Update took 12s, minutes ago.

### What are the roots of the ICD10CM taxonomy?

```SPARQL
PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
select 
distinct ?s ?l
where {
    graph <http://purl.bioontology.org/ontology/ICD10CM/> {
        ?s a owl:Class .
        optional {
            ?s skos:prefLabel ?l
        }
        minus {
            ?s rdfs:subClassOf ?parent
        }
    }
}
```

> Showing results from 1 to 3 of 3. Query took 1.2s, moments ago.

**s**|**l**
:-----|:-----
http://purl.bioontology.org/ontology/STY/T051|Event
http://purl.bioontology.org/ontology/STY/T071|Entity
http://purl.bioontology.org/ontology/ICD10CM/ICD-10-CM|ICD-10-CM TABULAR LIST of DISEASES and INJURIES

#### BioPortal says

- [Certain conditions originating in the perinatal period (P00-P96)](https://bioportal.bioontology.org/ontologies/ICD10CM/?p=classes&conceptid=http%3A%2F%2Fpurl.bioontology.org%2Fontology%2FICD10CM%2FP00-P96)
- [Certain infectious and parasitic diseases (A00-B99)](https://bioportal.bioontology.org/ontologies/ICD10CM/?p=classes&conceptid=http%3A%2F%2Fpurl.bioontology.org%2Fontology%2FICD10CM%2FA00-B99)
- [Congenital malformations, deformations and chromosomal abnormalities (Q00-Q99)](https://bioportal.bioontology.org/ontologies/ICD10CM/?p=classes&conceptid=http%3A%2F%2Fpurl.bioontology.org%2Fontology%2FICD10CM%2FQ00-Q99)
- [Diseases of the blood and blood-forming organs and certain disorders involving the immune mechanism (D50-D89)](https://bioportal.bioontology.org/ontologies/ICD10CM/?p=classes&conceptid=http%3A%2F%2Fpurl.bioontology.org%2Fontology%2FICD10CM%2FD50-D89)
- [Diseases of the circulatory system (I00-I99)](https://bioportal.bioontology.org/ontologies/ICD10CM/?p=classes&conceptid=http%3A%2F%2Fpurl.bioontology.org%2Fontology%2FICD10CM%2FI00-I99)
- [Diseases of the digestive system (K00-K95)](https://bioportal.bioontology.org/ontologies/ICD10CM/?p=classes&conceptid=http%3A%2F%2Fpurl.bioontology.org%2Fontology%2FICD10CM%2FK00-K95)
- [Diseases of the ear and mastoid process (H60-H95)](https://bioportal.bioontology.org/ontologies/ICD10CM/?p=classes&conceptid=http%3A%2F%2Fpurl.bioontology.org%2Fontology%2FICD10CM%2FH60-H95)
- [Diseases of the eye and adnexa (H00-H59)](https://bioportal.bioontology.org/ontologies/ICD10CM/?p=classes&conceptid=http%3A%2F%2Fpurl.bioontology.org%2Fontology%2FICD10CM%2FH00-H59)
- [Diseases of the genitourinary system (N00-N99)](https://bioportal.bioontology.org/ontologies/ICD10CM/?p=classes&conceptid=http%3A%2F%2Fpurl.bioontology.org%2Fontology%2FICD10CM%2FN00-N99)
- [Diseases of the musculoskeletal system and connective tissue (M00-M99)](https://bioportal.bioontology.org/ontologies/ICD10CM/?p=classes&conceptid=http%3A%2F%2Fpurl.bioontology.org%2Fontology%2FICD10CM%2FM00-M99)
- [Diseases of the nervous system (G00-G99)](https://bioportal.bioontology.org/ontologies/ICD10CM/?p=classes&conceptid=http%3A%2F%2Fpurl.bioontology.org%2Fontology%2FICD10CM%2FG00-G99)
- [Diseases of the respiratory system (J00-J99)](https://bioportal.bioontology.org/ontologies/ICD10CM/?p=classes&conceptid=http%3A%2F%2Fpurl.bioontology.org%2Fontology%2FICD10CM%2FJ00-J99)
- [Diseases of the skin and subcutaneous tissue (L00-L99)](https://bioportal.bioontology.org/ontologies/ICD10CM/?p=classes&conceptid=http%3A%2F%2Fpurl.bioontology.org%2Fontology%2FICD10CM%2FL00-L99)
- [Endocrine, nutritional and metabolic diseases (E00-E89)](https://bioportal.bioontology.org/ontologies/ICD10CM/?p=classes&conceptid=http%3A%2F%2Fpurl.bioontology.org%2Fontology%2FICD10CM%2FE00-E89)
- [External causes of morbidity (V00-Y99)](https://bioportal.bioontology.org/ontologies/ICD10CM/?p=classes&conceptid=http%3A%2F%2Fpurl.bioontology.org%2Fontology%2FICD10CM%2FV00-Y99)
- [Factors influencing health status and contact with health services (Z00-Z99)](https://bioportal.bioontology.org/ontologies/ICD10CM/?p=classes&conceptid=http%3A%2F%2Fpurl.bioontology.org%2Fontology%2FICD10CM%2FZ00-Z99)
- [Injury, poisoning and certain other consequences of external causes (S00-T88)](https://bioportal.bioontology.org/ontologies/ICD10CM/?p=classes&conceptid=http%3A%2F%2Fpurl.bioontology.org%2Fontology%2FICD10CM%2FS00-T88)
- [Mental, Behavioral and Neurodevelopmental disorders (F01-F99)](https://bioportal.bioontology.org/ontologies/ICD10CM/?p=classes&conceptid=http%3A%2F%2Fpurl.bioontology.org%2Fontology%2FICD10CM%2FF01-F99)
- [Neoplasms (C00-D49)](https://bioportal.bioontology.org/ontologies/ICD10CM/?p=classes&conceptid=http%3A%2F%2Fpurl.bioontology.org%2Fontology%2FICD10CM%2FC00-D49)
- [Pregnancy, childbirth and the puerperium (O00-O9A)](https://bioportal.bioontology.org/ontologies/ICD10CM/?p=classes&conceptid=http%3A%2F%2Fpurl.bioontology.org%2Fontology%2FICD10CM%2FO00-O9A)
- [Symptoms, signs and abnormal clinical and laboratory findings, not elsewhere classified (R00-R99)](https://bioportal.bioontology.org/ontologies/ICD10CM/?p=classes&conceptid=http%3A%2F%2Fpurl.bioontology.org%2Fontology%2FICD10CM%2FR00-R99)

### Transitively materialize sub-classes of ICD10 classes

_Should procedures, external factors, etc be removed from this materialization?_

```SPARQL
PREFIX mondo: <http://purl.obolibrary.org/obo/mondo#>
PREFIX mydata: <http://example.com/resource/>
PREFIX obo: <http://purl.obolibrary.org/obo/>
PREFIX ontologies: <http://transformunify.org/ontologies/>
PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
PREFIX sm: <tag:stardog:api:mapping:>
PREFIX turbo: <http://transformunify.org/ontologies/>
PREFIX umls: <http://bioportal.bioontology.org/ontologies/umls/>
PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
insert {
    graph mydata:ICD10TransitiveSubClasses {
        ?sub rdfs:subClassOf ?s .
    }
}
where {
    graph <http://purl.bioontology.org/ontology/ICD10CM/> {
        # + or * ?
        ?s rdfs:subClassOf+ owl:Thing .
        ?sub rdfs:subClassOf* ?s .
    }
}
```

> Added 565588 statements. Update took 1m 24s, moments ago.

----

[http://purl.bioontology.org/ontology/SNOMEDCT/64572001](http://purl.bioontology.org/ontology/SNOMEDCT/64572001) doesn't have any sub-classes?

Index on 
- http://www.w3.org/2000/01/rdf-schema#label
- http://www.w3.org/2004/02/skos/core#prefLabel
- URIs
- 
_Takes less than 5 minutes!_

Then look for AIDS-associated disorder, http://purl.bioontology.org/ontology/SNOMEDCT/420721002

Found [http://purl.bioontology.org/ontology/SNOMEDCT_US/420721002](http://purl.bioontology.org/ontology/SNOMEDCT_US/420721002)


### Transitively materialize MonDO sub-classes

_No up-front filtering this time... apply at query time. Exclude any diseases that are a `rdfs:subClassOf*` rare, congenital or syndromic?_

_Constrain to ["disease or disorder", `obo:MONDO_0000001`](http://purl.obolibrary.org/obo/MONDO_0000001)?_

```SPARQL
PREFIX mydata: <http://example.com/resource/>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX obo: <http://purl.obolibrary.org/obo/>
insert {
    graph mydata:MondoTransitiveSubClasses {
        ?mondoSub rdfs:subClassOf ?mondo .
    }
}
where {
    graph <http://purl.obolibrary.org/obo/mondo.owl> {
        ?mondoSub rdfs:subClassOf* ?mondo .
    }
    # minus {
    #     graph <http://example.com/resource/materializedMondoAxioms> {
    #         ?mondoSub obo:RO_0002573 obo:MONDO_0021152 .
    #     }
    # }
}
```

> Added 1044847 statements. Update took 1m 31s, minutes ago.

## 22 paths in repo `dd_include_icd_transitivity` 

_on http://turbo-prd-db01.pmacs.upenn.edu:7200/ _

```R
 [1] "mydata:m-dbxr-i9"                        "mydata:m-dbxr-i10"                       "mydata:m-dbxr-snomed-shared_cui-i9"     
 [4] "mydata:m-eqClass-snomed-shared_cui-i9"   "mydata:m-exMatch-snomed-shared_cui-i9"   "mydata:m-cMatch-snomed-shared_cui-i9"   
 [7] "mydata:m-dbxr-snomed-shared_cui-i10"     "mydata:m-eqClass-snomed-shared_cui-i10"  "mydata:m-exMatch-snomed-shared_cui-i10" 
[10] "mydata:m-cMatch-snomed-shared_cui-i10"   "mydata:m-dbxr-snomed-NLM_mappings-i9"    "mydata:m-eqClass-snomed-NLM_mappings-i9"
[13] "mydata:m-exMatch-snomed-NLM_mappings-i9" "mydata:m-cMatch-snomed-NLM_mappings-i9"  "mydata:i9-eqClass-m"                    
[16] "mydata:i10-eqClass-m"                    "mydata:m-dbxr-shared_cui-i9"             "mydata:m-exMatch-shared_cui-i9"         
[19] "mydata:m-cMatch-shared_cui-i9"           "mydata:m-dbxr-shared_cui-i10"            "mydata:m-exMatch-shared_cui-i10"        
[22] "mydata:m-cMatch-shared_cui-i10"          "mydata:i9-shared_cui-eqClass-m"          "mydata:i10-shared_cui-eqClass-m" 
```

## paths from `Hayden_diseaseToDiagnosis`

1. http://graphBuilder.org/mondoToIcdMappings
1. http://graphBuilder.org/mondoToIcdMappingsFullSemantics
1. owl:equivalentClass_snomed_with_icd9_map
1. oboInOwl:hasDbXref_snomed_with_icd9_map
1. skos:exactMatch_snomed_with_icd9_map
1. owl:equivalentClass_snomed_shared_cui
1. oboInOwl:hasDbXref_snomed_shared_cui
1. skos:exactMatch_snomed_shared_cui
1. oboInOwl:hasDbXref_cui
1. skos:exactMatch_cui
1. oboInOwl:hasDbXref_icd9_without_range_subclasses
1. owl:cui_equivalentClass
1. owl:icd9_equivalentClass
1. oboInOwl:hasDbXref_icd10
1. owl:icd10_equivalentClass
1. skos:closeMatch_snomed_with_icd9_map
1. skos:closeMatch_snomed_shared_cui
1. skos:closeMatch_cui


## Queries possible with no additional materialization

### MonDO's direct paths to ICD10 codes

In this case the _detailed_ paths would be the Cartesian product of the two `?rewriteGraph`s (which capture the orientation of MonDO's assertion) and the  `?assertedPredicate`s, which appear to be limited to two

1. `mydata:mdbxr`
1. `owl:equivalentClass`

```SPARQL
PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
select 
distinct ?m ?rewriteGraph ?assertedPredicate ?i10code
where {
    graph <http://example.com/resource/MondoTransitiveSubClasses> {
        ?m rdfs:subClassOf <http://purl.obolibrary.org/obo/MONDO_0000001> .
    }
    graph ?rewriteGraph {
        ?m ?assertedPredicate ?i10
    }
    graph <http://example.com/resource/ICD10TransitiveSubClasses> {
        ?i10 rdfs:subClassOf ?anythingIcd10 .
    }
    graph <http://purl.bioontology.org/ontology/ICD10CM/> {
        ?i10 skos:notation ?i10code
    }
}
```

Timing: The results from this query (raw or **pre-distinct-ified**) can be **downloaded from AWS** to Penn in roughly 5 seconds.

### MonDO's direct paths to ICD9 codes

All of the remarks about the ICD10 mapping above hold true here, too.

```SPARQL
PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
select 
distinct 
?m ?rewriteGraph ?assertedPredicate ?i10code
where {
    graph <http://example.com/resource/MondoTransitiveSubClasses> {
        ?m rdfs:subClassOf <http://purl.obolibrary.org/obo/MONDO_0000001> .
    }
    graph ?rewriteGraph {
        ?m ?assertedPredicate ?i9
    }
    graph <http://example.com/resource/ICD9DiseaseInjuryTransitiveSubClasses> {
        ?i9 rdfs:subClassOf ?anythingIcd9 .
    }
    graph <http://purl.bioontology.org/ontology/ICD9CM/> {
        ?i9 skos:notation ?i9code
    }
}
```

### Real-time MonDO axiom filtering example

----
