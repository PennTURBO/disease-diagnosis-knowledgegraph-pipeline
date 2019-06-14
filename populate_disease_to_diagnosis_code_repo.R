library(SPARQL)
library(httr)

# start by loading
# mondo from http://purl.obolibrary.org/obo/mondo.owl into http://purl.obolibrary.org/obo/mondo.owl
#  my have to be staged as a file... GraphDB complains about loading some RDF files from web URLs
# snomed from the ums2rdf pipeline into http://purl.bioontology.org/ontology/SNOMEDCT/
# icd9 from the ums2rdf pipeline into http://purl.bioontology.org/ontology/ICD9CM/
# icd10 from the ums2rdf pipeline into 	http://purl.bioontology.org/ontology/ICD10CM/
# ontorefine:
# https://download.nlm.nih.gov/umls/kss/mappings/ICD9CM_TO_SNOMEDCT/ICD9CM_TO_SNOMEDCT_DIAGNOSIS_201812.zip
# ICD9CM_SNOMED_MAP_1TO1_201812.txt -> ontorefine:1743351501645 on laptop
# ICD9CM_SNOMED_MAP_1TOM_201812.txt -> ontorefine:2279568511296 on laptop


# still to do
# materialize SNOMEDCT icd10 relations... might they just be the same as shared CUIs?


# maybe
# materialize all of the paths and then flatten for Hayden
# don't peruse syndromes or congenital conditions from SNOMEDCT
# apply over query labels, not the queries themselves?


graphdb.address.port <- "http://turbo-prd-db01.pmacs.upenn.edu:7200"
# graphdb.address.port <- "http://localhost:7200"

# locahost free
# selected.repo <- "disease_to_diagnosis"
selected.repo <- "disease_diagnosis_20190612"

# sparql.prefixes <- ""

update.endpoint <-
  paste0(graphdb.address.port,
         "/repositories/",
         selected.repo,
         "/statements")

api.user <- "markampa"
api.pass <- rstudioapi::askForPassword()

saved.authentication <-
  authenticate(api.user, api.pass, type = "basic")

update.list <- list(
  "materialize UMLS CUIs" <- '
PREFIX umls: <http://bioportal.bioontology.org/ontologies/umls/>
insert {
    graph <http://example.com/resource/materializedCui> {
        ?c a  <http://example.com/resource/materializedCui> .
        ?s <http://example.com/resource/materializedCui> ?c
    }
} where {
    ?s umls:cui ?o .
    bind(uri(concat("http://example.com/cui/", ?o)) as ?c)
}',
  "rewrite ?p mondo" = '
  PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
PREFIX owl: <http://www.w3.org/2002/07/owl#>
# remove icd9 ranges, even if they are defined ?reqrite a ?t
insert {
    graph <http://example.com/resource/rewrites> {
        ?rewrite  ?p ?mondo
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
',
"mondo ?p rewrite" = '
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
PREFIX owl: <http://www.w3.org/2002/07/owl#>
# remove icd9 ranges, even if they are defined ?reqrite a ?t
insert {
    graph <http://example.com/resource/rewrites> {
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
',
"mondo dbxr literal", '
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
PREFIX owl: <http://www.w3.org/2002/07/owl#>
# remove icd9 ranges, even if they are defined (?rewrite a ?t)
insert {
    graph <http://example.com/resource/rewrites> {
        ?mondo <http://www.itmat.upenn.edu/biobank/mdbxr> ?rewrite
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
',
"isolate undefined mondo ?p rewrites",'
insert {
    graph <http://example.com/resource/undefinedRewrites> {
        ?mondo ?p ?rewrite
    }
}
where {
    graph <http://example.com/resource/rewrites> {
        ?mondo ?p ?rewrite
    }
    minus {
        ?rewrite a ?t
    }
}
',
"delete undefined mondo ?p rewrites from mondo",'
delete {
    graph <http://example.com/resource/rewrites> {
        ?mondo ?p ?rewrite
    }
}
where {
    graph <http://example.com/resource/rewrites> {
        ?mondo ?p ?rewrite
    }
    minus {
        ?rewrite a ?t
    }
}
',
"isolate undefined rewrite ?p mondo",'
insert {
    graph <http://example.com/resource/undefinedRewrites> {
        ?rewrite  ?p ?mondo
    }
}
where {
    graph <http://example.com/resource/rewrites> {
        ?rewrite  ?p ?mondo
    }
    minus {
        ?rewrite a ?t
    }
}
',
"delete undefined rewrite ?p mondo from mondo",'
delete {
    graph <http://example.com/resource/rewrites> {
        ?rewrite  ?p ?mondo
    }
}
where {
    graph <http://example.com/resource/rewrites> {
        ?rewrite  ?p ?mondo
    }
    minus {
        ?rewrite a ?t
    }
}
',
"isolate ?momdo ?p icd9 ranges",'
insert {
    graph <http://example.com/resource/icd9range> {
        ?mondo ?p ?rewrite
    }
} where {
    graph <http://example.com/resource/rewrites> {
        ?mondo ?p ?rewrite
    }
    filter(strstarts(str( ?rewrite ),"http://purl.bioontology.org/ontology/ICD9CM/"))
    filter(contains(str( ?rewrite),"-"))
}
',
"delete ?momdo ?p icd9 ranges",'
delete {
    graph <http://example.com/resource/rewrites> {
        ?mondo ?p ?rewrite
    }
} where {
    graph <http://example.com/resource/icd9range> {
        ?mondo ?p ?rewrite
    }
}
',"isolate ?icd9 ranges ?p momdo ",'
insert {
    graph <http://example.com/resource/icd9range> {
        ?rewrite ?p ?mondo
    }
} where {
    graph <http://example.com/resource/rewrites> {
        ?rewrite ?p ?mondo
    }
    filter(strstarts(str( ?rewrite ),"http://purl.bioontology.org/ontology/ICD9CM/"))
    filter(contains(str( ?rewrite),"-"))
}
',
"delete ?icd9 ranges ?p momdo ",'
delete {
    graph <http://example.com/resource/rewrites> {
        ?s ?p ?o
    }
} where {
    graph <http://example.com/resource/icd9range> {
        ?s ?p ?o
    }
}
',
"isolate mondo original statements",'
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
',
"delete mondo original statements from mondo",'
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
')

update.outer.result <-
  lapply(update.list, function(current.update) {
    cat(current.update)
    post.res <- POST(update.endpoint,
                     body = list(update = current.update),
                     saved.authentication)
    
    print(post.res$times[['total']])
  })

ontorefine.prefix <- 'PREFIX mydata: <http://example.com/resource/>
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
  SERVICE <'

ontorefine.postfix <- '> {
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

ontorefie.projects <-
  list("1to1" = 'ontorefine:1743351501645', "1toMany" = 'ontorefine:2279568511296')

ontorefine.results <-
  lapply(ontorefie.projects, function(current.project) {
    assembled.statement <-
      paste0(ontorefine.prefix, current.project, ontorefine.postfix)
    cat(assembled.statement)
    post.res <- POST(update.endpoint,
                     body = list(update = assembled.statement),
                     saved.authentication)
    
    print(post.res$times[['total']])
  })


update.list <-
  list(
    "NLM ICD9CM to SNOMED mapping" = 'PREFIX mydata: <http://example.com/resource/>
insert data {
graph <https://www.nlm.nih.gov/research/umls/mapping_projects/icd9cm_to_snomedct.html> {
    mydata:IS_CURRENT_ICD mydata:intPlaceholder true .
    mydata:IS_NEC mydata:intPlaceholder true .
    mydata:IS_1-1MAP mydata:intPlaceholder true .
    mydata:IN_CORE mydata:intPlaceholder true .
    <https://www.nlm.nih.gov/research/umls/mapping_projects/icd9cm_to_snomedct.html> rdfs:label "NLM ICD9CM to SNOMED mapping" .
}
}',
"into to bool"='PREFIX mydata: <http://example.com/resource/>
insert {
    graph <https://www.nlm.nih.gov/research/umls/mapping_projects/icd9cm_to_snomedct.html_boolean> {
        ?s ?p ?boolean
    }
} where {
    graph <https://www.nlm.nih.gov/research/umls/mapping_projects/icd9cm_to_snomedct.html> {
        ?p mydata:intPlaceholder true .
        ?s ?p ?int .
        bind(if(?int = "1", true, false) as ?boolean)
    }
}',
"delete ints" = 'PREFIX mydata: <http://example.com/resource/>
delete {
    ?s ?p ?int .
} where {
    graph <https://www.nlm.nih.gov/research/umls/mapping_projects/icd9cm_to_snomedct.html> {
        ?p mydata:intPlaceholder true .
        ?s ?p ?int .
    }
}',
"migrate bools" = 'insert {
    graph <https://www.nlm.nih.gov/research/umls/mapping_projects/icd9cm_to_snomedct.html> {
        ?s ?p ?boolean
    }
}
where {
    graph <https://www.nlm.nih.gov/research/umls/mapping_projects/icd9cm_to_snomedct.html_boolean> {
        ?s ?p ?boolean
    }
}',
"clear temp",'clear graph <https://www.nlm.nih.gov/research/umls/mapping_projects/icd9cm_to_snomedct.html_boolean>',
"materialize ICD9CM to snomed mappings" = 'PREFIX mydata: <http://example.com/resource/>
PREFIX owl: <http://www.w3.org/2002/07/owl#>
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
}'
,
"isolation of ICD10 siblings" = 'PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
insert  {
    graph <http://example.com/resource/ICD10CM_siblings> {
        ?s <http://purl.bioontology.org/ontology/ICD10CM/SIB> ?o
    }
}
where {
    graph <http://purl.bioontology.org/ontology/ICD10CM/> {
        ?s <http://purl.bioontology.org/ontology/ICD10CM/SIB> ?o
    }
}',
"deletion of ICD10 siblings" = 'PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
delete  {
    graph <http://purl.bioontology.org/ontology/ICD10CM/> {
        ?s <http://purl.bioontology.org/ontology/ICD10CM/SIB> ?o
    }
}
where {
    graph <http://purl.bioontology.org/ontology/ICD10CM/> {
        ?s <http://purl.bioontology.org/ontology/ICD10CM/SIB> ?o
    }
}'
,
"isolation of ICD9 siblings" = 'PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
insert  {
    graph <http://example.com/resource/ICD9CM_siblings> {
        ?s <http://purl.bioontology.org/ontology/ICD9CM/SIB> ?o
    }
}
where {
    graph <http://purl.bioontology.org/ontology/ICD9CM/> {
        ?s <http://purl.bioontology.org/ontology/ICD9CM/SIB> ?o
    }
}',
"deletion of ICD9 siblings" = 'PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
delete  {
    graph <http://purl.bioontology.org/ontology/ICD9CM/> {
        ?s <http://purl.bioontology.org/ontology/ICD9CM/SIB> ?o
    }
}
where {
    graph <http://purl.bioontology.org/ontology/ICD9CM/> {
        ?s <http://purl.bioontology.org/ontology/ICD9CM/SIB> ?o
    }
}',
"defined in" ='PREFIX owl: <http://www.w3.org/2002/07/owl#>
insert {
    graph <http://example.com/resource/definedIn> {
        ?s <http://example.com/resource/definedIn> ?g
    }
} where {
    graph ?g {
        ?s a owl:Class
    }
}'
  )

update.outer.result <-
  lapply(update.list, function(current.update) {
    cat(current.update)
    post.res <- POST(update.endpoint,
                     body = list(update = current.update),
                     saved.authentication)
    
    print(post.res$times[['total']])
  })
