**`icd9_to_snomed.triples.file`** should be set to the name of a file containing an RDF direct mapping of the ICD9/SNOMED relations available in https://download.nlm.nih.gov/umls/kss/mappings/ICD9CM_TO_SNOMEDCT/ICD9CM_TO_SNOMEDCT_DIAGNOSIS_201812.zip. See https://www.nlm.nih.gov/research/umls/mapping_projects/icd9cm_to_snomedct.html for documentatio. **Contrary to recent claims, these mappings are updated (yearly), and the disease diagnosis workflow should ahve a method for regenreating them in an automated fashio.** A UMLS account is required to obtain the ICD9/SNOMED mappings. See https://uts.nlm.nih.gov//license.html

These ICD9/SNOMED RDF direct mappings only need to be created once, and any one of several approaches could be used, as long as they use the predicates expected by  `disease_diagnosis_dev.R`. Up to now, GraphDB's OntoRefine feature has been used (http://graphdb.ontotext.com/documentation/free/loading-data-using-ontorefine.html). OntoRefine's default settings can be used to load the two CSV files from `ICD9CM_TO_SNOMEDCT_DIAGNOSIS_201812.zip` into two different OntoRefine projects. The following SPARQL could then be run over each of the two projects to load the direct mappings into one named graph. 



```SPARQL
PREFIX mydata: <http://example.com/resource/>
PREFIX spif: <http://spinrdf.org/spif#>
insert {
  graph <https://www.nlm.nih.gov/research/umls/mapping_projects/icd9cm_to_snomedct.html> {
    ?myRowId a <https://www.nlm.nih.gov/research/umls/mapping_projects/icd9cm_to_snomedct.html> ;
    mydata:File ?File ;
    mydata:ICD_CODE ?ICD_CODE ;
    mydata:ICD_NAME ?ICD_NAME ;
    mydata:IS_CURRENT_ICD ?IS_CURRENT_ICD ;
    mydata:IP_USAGE ?IP_USAGE ;
    mydata:OP_USAGE ?OP_USAGE ;
    mydata:AVG_USAGE ?AVG_USAGE ;
    mydata:IS_NEC ?IS_NEC ;
    mydata:SNOMED_CID ?SNOMED_CID ;
    mydata:SNOMED_FSN ?SNOMED_FSN ;
    mydata:IS_1-1MAP ?IS_1_1MAP ;
    mydata:CORE_USAGE ?CORE_USAGE ;
    mydata:IN_CORE ?IN_CORE .
  }
} WHERE {
  SERVICE <SOME ONTOREFINE PROJECT CODE> {
  ?row a mydata:Row ;
  mydata:File ?File ;
  mydata:ICD_CODE ?ICD_CODE .
  optional {
    ?row mydata:ICD_NAME ?ICD_NAME ;
  }
  optional {
    ?row mydata:IS_CURRENT_ICD ?IS_CURRENT_ICD ;
  }
  optional {
    ?row  mydata:IP_USAGE ?IP_USAGE ;
  }
  optional {
    ?row  mydata:OP_USAGE ?OP_USAGE ;
  }
  optional {
    ?row  mydata:AVG_USAGE ?AVG_USAGE ;
  }
  optional {
    ?row  mydata:IS_NEC ?IS_NEC ;
  }
  optional {
    ?row  mydata:SNOMED_CID ?SNOMED_CID ;
  }
  optional {
    ?row  mydata:SNOMED_FSN ?SNOMED_FSN ;
  }
  optional {
    ?row  mydata:IS_1-1MAP ?IS_1_1MAP ;
  }
  optional {
    ?row  mydata:CORE_USAGE ?CORE_USAGE ;
  }
  optional {
    ?row  mydata:IN_CORE ?IN_CORE .
  }
  BIND(uuid() AS ?myRowId)
}
}'
```

The direct mapping should be performed outside of the disease diagnosis repository, and the direct mappings repository should then be exported to a turtle file and placed in the GraphDB's import folder. (See above.) The export can be performed in the web interface or programmatically.

http://graphdb.ontotext.com/documentation/free/backing-up-and-recovering-repo.html
