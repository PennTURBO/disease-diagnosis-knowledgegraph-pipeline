## Converting UMLS content into RDF

**Some** UMLS sources/components are already available as RDF files at the NCBO BioPortal. Others, like SNOMED, are not. This document describes how to convert those components into RDF on a remote Linux server. Note that the UMLS has an `AA` release in May of each year and an `AB` release in November. Some sources may be released more frequently (like RxNorm) and may have their own interfaces (like RxNav for RxNorm) that may be so convenient that they may be preferable over RDF in some cases.

Most of these steps will take many minutes to roughly one hour.

- Start AWS EC2 instance
- Mount data disk(s) if necessary

### System notes
Recent Ubuntu LTS 64 bit server with MySQL server and client software installed. Reader should be comfortable creating MySQL database and users, setting permissions, and managing remote visibility if desired (i.e. access from addresses other than `localhost`). I have been using a `x1e.xlarge`, but there are probably steps below that would benefit from a higher CPU count. 16 GB  (`r5a.large`) is definitely not enough for a dataset the size of SNOMED.

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
