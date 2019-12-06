library(SPARQL)
library(httr)

# start by loading
# mondo from http://purl.obolibrary.org/obo/mondo.owl into http://purl.obolibrary.org/obo/mondo.owl
#  my have to be staged as a file... GraphDB complains about loading some RDF files from web URLs
# snomed from the ums2rdf pipeline into http://purl.bioontology.org/ontology/SNOMEDCT/
# icd9 from the ums2rdf pipeline into http://purl.bioontology.org/ontology/ICD9CM/
# icd10 from the ums2rdf pipeline into 	http://purl.bioontology.org/ontology/ICD10CM/
# ontorefine source:
# https://download.nlm.nih.gov/umls/kss/mappings/ICD9CM_TO_SNOMEDCT/ICD9CM_TO_SNOMEDCT_DIAGNOSIS_201812.zip
# but has also been saved as two projects that can be directly imported into graphdb servers


# maybe
# materialize all of the paths and then flatten for Hayden
# don't peruse syndromes or congenital conditions from mondo (ok, at least reporting) SNOMEDCT (no action)
# cancer maps to lots of false positives?
# apply over query labels, not the queries themselves?
# materialize SNOMEDCT icd10 text ammpings? might they just be the same as shared CUIs?



configurations <- list(
  "E5570" = list(
    "graphdb.address.port" =
      "http://localhost:7200",
    "selected.repo" = "disease_to_diagnosis",
    "ontorefine.projects" =
      list("1to1" = 'ontorefine:1743351501645', "1toMany" = 'ontorefine:2279568511296')
  ),
  "turbo-prd-db01" = list(
    "graphdb.address.port" =
      "http://turbo-prd-db01.pmacs.upenn.edu:7200",
    "selected.repo" = "disease_diagnosis_20190620",
    "ontorefine.projects" =
      list("1to1" = 'ontorefine:1908476393038', "1toMany" = 'ontorefine:1988267734735')
    
  )
)

selected.configuration <- "turbo-prd-db01"
selected.configuration <- configurations[[selected.configuration]]
graphdb.address.port <- selected.configuration[[1]]
selected.repo <- selected.configuration[[2]]
ontorefine.projects <- selected.configuration[[3]]

# sparql.prefixes <- ""

update.endpoint <-
  paste0(graphdb.address.port,
         "/repositories/",
         selected.repo,
         "/statements")

api.user <- "markampa"
api.pass <-
  rstudioapi::askForPassword(prompt = paste0("Password for ", api.user , " on ", graphdb.address.port , "?"))

saved.authentication <-
  authenticate(api.user, api.pass, type = "basic")

###   ###   ###

# CLEAR REPO

post.res <- POST(update.endpoint,
                 body = list(update = "clear all"),
                 saved.authentication)

# CONFIRM CLEAR

expectation <-
  list(head = list(vars = "contextID"),
       results = list(bindings = list()))

while (TRUE) {
  context.report <-
    GET(
      url = paste0(
        graphdb.address.port,
        "/repositories/",
        selected.repo,
        "/contexts"
      ),
      saved.authentication
    )
  
  context.report <- fromJSON(rawToChar(context.report$content))
  
  print(Sys.time())
  Sys.sleep(10)
  moveon <- identical(context.report, expectation)
  if (moveon) {
    break()
  }
}

# IMPORT MONDO, ICD, SNOMED BRF FROM SERVER

post.dest <-
  paste0(graphdb.address.port,
         "/rest/data/import/server/",
         selected.repo,
         "/")

bod4post <- '{
  "fileNames": [
    "MonDO_SNOMED_ICDs_mid_June_2019.brf.zip"
  ]
}'

placeholder <- POST(
  post.dest,
  body = bod4post,
  content_type("application/json"),
  accept("application/json"),
  saved.authentication
)

# CONFIRM IMPORT

expectation <-
  list(head = list(vars = "contextID"),
       results = list(bindings = list(
         list(
           contextID = list(type = "uri", value = "http://purl.obolibrary.org/obo/mondo.owl")
         ),
         list(
           contextID = list(type = "uri", value = "http://purl.bioontology.org/ontology/ICD10CM/")
         ),
         list(
           contextID = list(type = "uri", value = "http://purl.bioontology.org/ontology/ICD9CM/")
         ),
         list(
           contextID = list(type = "uri", value = "http://purl.bioontology.org/ontology/SNOMEDCT/")
         )
       )))


while (TRUE) {
  context.report <-
    GET(
      url = paste0(
        graphdb.address.port,
        "/repositories/",
        selected.repo,
        "/contexts"
      ),
      saved.authentication
    )
  
  context.report <- fromJSON(rawToChar(context.report$content))
  
  print(Sys.time())
  Sys.sleep(10)
  moveon <- identical(context.report, expectation)
  if (moveon) {
    break()
  }
}

###   ###   ###

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

ontorefine.results <-
  lapply(ontorefine.projects, function(current.project) {
    assembled.statement <-
      paste0(ontorefine.prefix, current.project, ontorefine.postfix)
    # cat(assembled.statement)
    print(current.project)
    post.res <- POST(update.endpoint,
                     body = list(update = assembled.statement),
                     saved.authentication)
    
    print(post.res$times[['total']])
  })

###   ###   ###


update.list <- list(
  "materialize UMLS CUIs" = '
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
}',
  "rewrite ?p mondo" = '
PREFIX mydata: <http://example.com/resource/>
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
PREFIX mydata: <http://example.com/resource/>
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
"mondo dbxr literal" = '
PREFIX mydata: <http://example.com/resource/>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
PREFIX owl: <http://www.w3.org/2002/07/owl#>
# remove icd9 ranges, even if they are defined (?rewrite a ?t)
insert {
    graph <http://example.com/resource/rewrites> {
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
',
"isolate undefined mondo ?p rewrites" = '
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
"delete undefined mondo ?p rewrites from mondo" = '
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
"isolate undefined rewrite ?p mondo" = '
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
"delete undefined rewrite ?p mondo from mondo" = '
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
"isolate ?momdo ?p icd9 ranges" = '
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
"delete ?momdo ?p icd9 ranges" = '
delete {
    graph <http://example.com/resource/rewrites> {
        ?mondo ?p ?rewrite
    }
} where {
    graph <http://example.com/resource/icd9range> {
        ?mondo ?p ?rewrite
    }
}
',"isolate ?icd9 ranges ?p momdo " = '
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
"delete ?icd9 ranges ?p momdo " = '
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
# leaves behind equivalent-to-restriction/blank node statements
"isolate mondo original statements" = '
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
',
"delete mondo original statements from mondo" = '
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
',
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
"clear temp" = 'clear graph <https://www.nlm.nih.gov/research/umls/mapping_projects/icd9cm_to_snomedct.html_boolean>',
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
"isolation of ICD10 siblings" = 'PREFIX mydata: <http://example.com/resource/>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
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
"deletion of ICD10 siblings" = 'PREFIX mydata: <http://example.com/resource/>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
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
"isolation of ICD9 siblings" = 'PREFIX mydata: <http://example.com/resource/>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
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
"deletion of ICD9 siblings" = 'PREFIX mydata: <http://example.com/resource/>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
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
"defined in" ='PREFIX mydata: <http://example.com/resource/>
PREFIX owl: <http://www.w3.org/2002/07/owl#>
insert {
    graph <http://example.com/resource/definedIn> {
        ?s <http://example.com/resource/definedIn> ?g
    }
} where {
    graph ?g {
        ?s a owl:Class
    }
}',
# does this miss equivalentCLass axioms and more complex subClassOf axioms?
"materializedMondoAxioms" = '
PREFIX mydata: <http://example.com/resource/>
PREFIX obo: <http://purl.obolibrary.org/obo/>
PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
insert {
        graph mydata:materializedMondoAxioms {
    ?term ?op ?valSource
    }
}
where {
    graph obo:mondo.owl {
        ?term rdfs:subClassOf* ?restr ;
                             rdfs:label ?termlab .
        ?restr a owl:Restriction ;
               owl:onProperty ?op ;
               owl:someValuesFrom ?valSource .
        ?op rdfs:label ?opl .
        ?valSource rdfs:label ?vsl .
        filter(isuri( ?term ))
    }
}
#limit 99',
"ICD9DiseaseInjuryTransitiveSubClasses" = '
PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
PREFIX mydata: <http://example.com/resource/>
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
}',
"ICD10TransitiveSubClasses" = '
PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
PREFIX mydata: <http://example.com/resource/>
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
}',
"SnomedDiseaseTransitiveSubClasses" = '
PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
PREFIX mydata: <http://example.com/resource/>
  insert {
    graph mydata:SnomedDiseaseTransitiveSubClasses {
      ?sub rdfs:subClassOf ?s .
    }
  }
where {
  graph <http://purl.bioontology.org/ontology/SNOMEDCT/> {
    # + or * ?
    ?s rdfs:subClassOf* <http://purl.bioontology.org/ontology/SNOMEDCT/64572001> .
    ?sub rdfs:subClassOf* ?s .
  }
}',
"filteredMondoTransitiveSubClasses" = '
PREFIX mondo: <http://purl.obolibrary.org/obo/mondo#>
PREFIX mydata: <http://example.com/resource/>
PREFIX obo: <http://purl.obolibrary.org/obo/>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
PREFIX owl: <http://www.w3.org/2002/07/owl#>
insert {
    graph mydata:filteredMondoTransitiveSubClasses {
        ?mondoSub rdfs:subClassOf ?mondo .
    }
}
where {
    graph <http://purl.obolibrary.org/obo/mondo.owl> {
        ?mondoSub rdfs:subClassOf+ ?mondo .
    }
    minus {
        graph <http://example.com/resource/materializedMondoAxioms> {
            ?mondoSub obo:RO_0002573 obo:MONDO_0021152 .
        }
    }
}'
)

update.names <- names(update.list)

update.outer.result <-
  lapply(update.names, function(current.name) {
    current.update <- update.list[[current.name]]
    # cat(current.update)
    print(current.name)
    print(Sys.time())
    post.res <- POST(update.endpoint,
                     body = list(update = current.update),
                     saved.authentication)
    
    print(post.res$times[['total']])
  })

# ###
#
# do.update <- FALSE
#
# # parameterize minus
# query.assembler <- function(paths.graphname = "mydata:m-dbxr-i9",
#                             mondo.top = "<http://purl.obolibrary.org/obo/MONDO_0005275>",
#                             path.start = "?mondo",
#                             path.predicate = "mydata:mdbxr",
#                             path.end = "?icd",
#                             path.extras = "",
#                             icd.graph = '<http://purl.bioontology.org/ontology/ICD10CM/>') {
#   assembled.query <- paste0(
#     '
# PREFIX mondo: <http://purl.obolibrary.org/obo/mondo#>
# PREFIX mydata: <http://example.com/resource/>
# PREFIX obo: <http://purl.obolibrary.org/obo/>
# PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
# PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
# PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
# insert {
#     graph ',
#     paths.graphname,
#     ' {
#     ?subIcd mydata:evidenceFor ?mondo
#     }
# } where {
#     graph <http://purl.obolibrary.org/obo/mondo.owl> {
#         ?mondo  rdfs:subClassOf+ ',
#     mondo.top ,
#     ' .
#         ?mondoSub rdfs:subClassOf* ?mondo .
#     }
#     minus {
#         graph <http://example.com/resource/materializedMondoAxioms> {
#             ?mondoSub obo:RO_0002573 obo:MONDO_0021152 .
#         }
#     }
#     graph <http://example.com/resource/rewrites> { ',
#     path.start,
#     " ",
#     path.predicate,
#     " ",
#     path.end,
#     " . } ",
#     path.extras,
#     ' graph ',
#     icd.graph,
#     ' {
#         ?icd a owl:Class .
#         ?subIcd rdfs:subClassOf* ?icd .
#     }
# }'
#   )
#   return(assembled.query)
# }
#
# path.configs <-
#   list(
#     # only the dbxr paths work for direct m-...-iX paths
#     # could eliminate the others and save time
#     "mydata:m-dbxr-i9" = list(
#       "mondo.top" = "<http://purl.obolibrary.org/obo/MONDO_0005275>",
#       "path.start" = "?mondo",
#       "path.predicate" = "mydata:mdbxr",
#       "path.end" = "?icd",
#       "path.extras" = "",
#       "icd.graph" = '<http://purl.bioontology.org/ontology/ICD9CM/>'
#     ),
#     # "mydata:m-eqClass-i9" = list(
#     #   "mondo.top" = "<http://purl.obolibrary.org/obo/MONDO_0005275>",
#     #   "path.start" = "?mondo",
#     #   "path.predicate" = "owl:equivalentClass",
#     #   "path.end" = "?icd",
#     #   "path.extras" = "",
#     #   "icd.graph" = '<http://purl.bioontology.org/ontology/ICD9CM/>'
#     # ),
#     # "mydata:m-exMatch-i9" = list(
#     #   "mondo.top" = "<http://purl.obolibrary.org/obo/MONDO_0005275>",
#     #   "path.start" = "?mondo",
#     #   "path.predicate" = "skos:exactMatch",
#     #   "path.end" = "?icd",
#     #   "path.extras" = "",
#     #   "icd.graph" = '<http://purl.bioontology.org/ontology/ICD9CM/>'
#     # ),
#     # "mydata:m-cMatch-i9" = list(
#     #   "mondo.top" = "<http://purl.obolibrary.org/obo/MONDO_0005275>",
#     #   "path.start" = "?mondo",
#     #   "path.predicate" = "skos:closeMatch",
#     #   "path.end" = "?icd",
#     #   "path.extras" = "",
#     #   "icd.graph" = '<http://purl.bioontology.org/ontology/ICD9CM/>'
#     # ),
#     "mydata:m-dbxr-i10" = list(
#       "mondo.top" = "<http://purl.obolibrary.org/obo/MONDO_0005275>",
#       "path.start" = "?mondo",
#       "path.predicate" = "mydata:mdbxr",
#       "path.end" = "?icd",
#       "path.extras" = "",
#       "icd.graph" = '<http://purl.bioontology.org/ontology/ICD10CM/>'
#     ),
#     # "mydata:m-eqClass-i10" = list(
#     #   "mondo.top" = "<http://purl.obolibrary.org/obo/MONDO_0005275>",
#     #   "path.start" = "?mondo",
#     #   "path.predicate" = "owl:equivalentClass",
#     #   "path.end" = "?icd",
#     #   "path.extras" = "",
#     #   "icd.graph" = '<http://purl.bioontology.org/ontology/ICD10CM/>'
#     # ),
#     # "mydata:m-exMatch-i10" = list(
#     #   "mondo.top" = "<http://purl.obolibrary.org/obo/MONDO_0005275>",
#     #   "path.start" = "?mondo",
#     #   "path.predicate" = "skos:exactMatch",
#     #   "path.end" = "?icd",
#     #   "path.extras" = "",
#     #   "icd.graph" = '<http://purl.bioontology.org/ontology/ICD10CM/>'
#     # ),
#     # "mydata:m-cMatch-i10" = list(
#     #   "mondo.top" = "<http://purl.obolibrary.org/obo/MONDO_0005275>",
#     #   "path.start" = "?mondo",
#     #   "path.predicate" = "skos:closeMatch",
#     #   "path.end" = "?icd",
#     #   "path.extras" = "",
#     #   "icd.graph" = '<http://purl.bioontology.org/ontology/ICD10CM/>'
#     # ),
#     # all eight of the next snomed shared CUI paths are productive
#     # some predicates work with the terms rewritten from http://identifiers.org/snomedct/...
#     # and the others work with those rewritten from  http://purl.obolibrary.org/obo/SCTID_
#     "mydata:m-dbxr-snomed-shared_cui-i9" = list(
#       "mondo.top" = "<http://purl.obolibrary.org/obo/MONDO_0005275>",
#       "path.start" = "?mondo",
#       "path.predicate" = "mydata:mdbxr",
#       "path.end" = "?code",
#       "path.extras" = '
#     graph <http://purl.bioontology.org/ontology/SNOMEDCT/> {
#         ?subcode rdfs:subClassOf* ?code ;
#                                 skos:prefLabel ?subCodeLabel .
#     }
#     graph mydata:materializedCui {
#         ?subcode mydata:materializedCui ?materializedCui .
#         ?icd mydata:materializedCui ?materializedCui .
#     }',
#       "icd.graph" = '<http://purl.bioontology.org/ontology/ICD9CM/>'
#     ),
#     "mydata:m-eqClass-snomed-shared_cui-i9" = list(
#       "mondo.top" = "<http://purl.obolibrary.org/obo/MONDO_0005275>",
#       "path.start" = "?mondo",
#       "path.predicate"  = "owl:equivalentClass",
#       "path.end" = "?code",
#       "path.extras" = '
#     graph <http://purl.bioontology.org/ontology/SNOMEDCT/> {
#         ?subcode rdfs:subClassOf* ?code ;
#                                 skos:prefLabel ?subCodeLabel .
#     }
#     graph mydata:materializedCui {
#         ?subcode mydata:materializedCui ?materializedCui .
#         ?icd mydata:materializedCui ?materializedCui .
#     }',
#       "icd.graph" = '<http://purl.bioontology.org/ontology/ICD9CM/>'
#     ),
#     "mydata:m-exMatch-snomed-shared_cui-i9" = list(
#       "mondo.top" = "<http://purl.obolibrary.org/obo/MONDO_0005275>",
#       "path.start" = "?mondo",
#       "path.predicate"  = "skos:exactMatch",
#       "path.end" = "?code",
#       "path.extras" = '
#     graph <http://purl.bioontology.org/ontology/SNOMEDCT/> {
#         ?subcode rdfs:subClassOf* ?code ;
#                                 skos:prefLabel ?subCodeLabel .
#     }
#     graph mydata:materializedCui {
#         ?subcode mydata:materializedCui ?materializedCui .
#         ?icd mydata:materializedCui ?materializedCui .
#     }',
#       "icd.graph" = '<http://purl.bioontology.org/ontology/ICD9CM/>'
#     ),
#     "mydata:m-cMatch-snomed-shared_cui-i9" = list(
#       "mondo.top" = "<http://purl.obolibrary.org/obo/MONDO_0005275>",
#       "path.start" = "?mondo",
#       "path.predicate"  = "skos:closeMatch",
#       "path.end" = "?code",
#       "path.extras" = '
#     graph <http://purl.bioontology.org/ontology/SNOMEDCT/> {
#         ?subcode rdfs:subClassOf* ?code ;
#                                 skos:prefLabel ?subCodeLabel .
#     }
#     graph mydata:materializedCui {
#         ?subcode mydata:materializedCui ?materializedCui .
#         ?icd mydata:materializedCui ?materializedCui .
#     }',
#       "icd.graph" = '<http://purl.bioontology.org/ontology/ICD9CM/>'
#     ),
#     "mydata:m-dbxr-snomed-shared_cui-i10" = list(
#       "mondo.top" = "<http://purl.obolibrary.org/obo/MONDO_0005275>",
#       "path.start" = "?mondo",
#       "path.predicate" = "mydata:mdbxr",
#       "path.end" = "?code",
#       "path.extras" = '
#     graph <http://purl.bioontology.org/ontology/SNOMEDCT/> {
#         ?subcode rdfs:subClassOf* ?code ;
#                                 skos:prefLabel ?subCodeLabel .
#     }
#     graph mydata:materializedCui {
#         ?subcode mydata:materializedCui ?materializedCui .
#         ?icd mydata:materializedCui ?materializedCui .
#     }',
#       "icd.graph" = '<http://purl.bioontology.org/ontology/ICD10CM/>'
#     ),
#     "mydata:m-eqClass-snomed-shared_cui-i10" = list(
#       "mondo.top" = "<http://purl.obolibrary.org/obo/MONDO_0005275>",
#       "path.start" = "?mondo",
#       "path.predicate"  = "owl:equivalentClass",
#       "path.end" = "?code",
#       "path.extras" = '
#     graph <http://purl.bioontology.org/ontology/SNOMEDCT/> {
#         ?subcode rdfs:subClassOf* ?code ;
#                                 skos:prefLabel ?subCodeLabel .
#     }
#     graph mydata:materializedCui {
#         ?subcode mydata:materializedCui ?materializedCui .
#         ?icd mydata:materializedCui ?materializedCui .
#     }',
#       "icd.graph" = '<http://purl.bioontology.org/ontology/ICD10CM/>'
#     ),
#     "mydata:m-exMatch-snomed-shared_cui-i10" = list(
#       "mondo.top" = "<http://purl.obolibrary.org/obo/MONDO_0005275>",
#       "path.start" = "?mondo",
#       "path.predicate"  = "skos:exactMatch",
#       "path.end" = "?code",
#       "path.extras" = '
#     graph <http://purl.bioontology.org/ontology/SNOMEDCT/> {
#         ?subcode rdfs:subClassOf* ?code ;
#                                 skos:prefLabel ?subCodeLabel .
#     }
#     graph mydata:materializedCui {
#         ?subcode mydata:materializedCui ?materializedCui .
#         ?icd mydata:materializedCui ?materializedCui .
#     }',
#       "icd.graph" = '<http://purl.bioontology.org/ontology/ICD10CM/>'
#     ),
#     "mydata:m-cMatch-snomed-shared_cui-i10" = list(
#       "mondo.top" = "<http://purl.obolibrary.org/obo/MONDO_0005275>",
#       "path.start" = "?mondo",
#       "path.predicate"  = "skos:closeMatch",
#       "path.end" = "?code",
#       "path.extras" = '
#     graph <http://purl.bioontology.org/ontology/SNOMEDCT/> {
#         ?subcode rdfs:subClassOf* ?code ;
#                                 skos:prefLabel ?subCodeLabel .
#     }
#     graph mydata:materializedCui {
#         ?subcode mydata:materializedCui ?materializedCui .
#         ?icd mydata:materializedCui ?materializedCui .
#     }',
#       "icd.graph" = '<http://purl.bioontology.org/ontology/ICD10CM/>'
#     ),
#     ###
#     "mydata:m-dbxr-snomed-NLM_mappings-i9" = list(
#       "mondo.top" = "<http://purl.obolibrary.org/obo/MONDO_0005275>",
#       "path.start" = "?mondo",
#       "path.predicate"  = "mydata:mdbxr",
#       "path.end" = "?code",
#       "path.extras" = '
#     graph <http://purl.bioontology.org/ontology/SNOMEDCT/> {
#         ?subcode rdfs:subClassOf* ?code ;
#                                 skos:prefLabel ?subCodeLabel .
#     }
#     graph <https://www.nlm.nih.gov/research/umls/mapping_projects/icd9cm_to_snomedct.html> {
#         ?icd <https://www.nlm.nih.gov/research/umls/mapping_projects/icd9cm_to_snomedct.html> ?subcode
#     }',
#       "icd.graph" = '<http://purl.bioontology.org/ontology/ICD9CM/>'
#     )
#     ,
#     "mydata:m-eqClass-snomed-NLM_mappings-i9" = list(
#       "mondo.top" = "<http://purl.obolibrary.org/obo/MONDO_0005275>",
#       "path.start" = "?mondo",
#       "path.predicate"  = "owl:equivalentClass",
#       "path.end" = "?code",
#       "path.extras" = '
#     graph <http://purl.bioontology.org/ontology/SNOMEDCT/> {
#         ?subcode rdfs:subClassOf* ?code ;
#                                 skos:prefLabel ?subCodeLabel .
#     }
#     graph <https://www.nlm.nih.gov/research/umls/mapping_projects/icd9cm_to_snomedct.html> {
#         ?icd <https://www.nlm.nih.gov/research/umls/mapping_projects/icd9cm_to_snomedct.html> ?subcode
#     }',
#       "icd.graph" = '<http://purl.bioontology.org/ontology/ICD9CM/>'
#     )
#     ,
#     "mydata:m-exMatch-snomed-NLM_mappings-i9" = list(
#       "mondo.top" = "<http://purl.obolibrary.org/obo/MONDO_0005275>",
#       "path.start" = "?mondo",
#       "path.predicate"  = "skos:exactMatch",
#       "path.end" = "?code",
#       "path.extras" = '
#     graph <http://purl.bioontology.org/ontology/SNOMEDCT/> {
#         ?subcode rdfs:subClassOf* ?code ;
#                                 skos:prefLabel ?subCodeLabel .
#     }
#     graph <https://www.nlm.nih.gov/research/umls/mapping_projects/icd9cm_to_snomedct.html> {
#         ?icd <https://www.nlm.nih.gov/research/umls/mapping_projects/icd9cm_to_snomedct.html> ?subcode
#     }',
#       "icd.graph" = '<http://purl.bioontology.org/ontology/ICD9CM/>'
#     )
#     ,
#     "mydata:m-cMatch-snomed-NLM_mappings-i9" = list(
#       "mondo.top" = "<http://purl.obolibrary.org/obo/MONDO_0005275>",
#       "path.start" = "?mondo",
#       "path.predicate"  = "skos:closeMatch",
#       "path.end" = "?code",
#       "path.extras" = '
#     graph <http://purl.bioontology.org/ontology/SNOMEDCT/> {
#         ?subcode rdfs:subClassOf* ?code ;
#                                 skos:prefLabel ?subCodeLabel .
#     }
#     graph <https://www.nlm.nih.gov/research/umls/mapping_projects/icd9cm_to_snomedct.html> {
#         ?icd <https://www.nlm.nih.gov/research/umls/mapping_projects/icd9cm_to_snomedct.html> ?subcode
#     }',
#       "icd.graph" = '<http://purl.bioontology.org/ontology/ICD9CM/>'
#     ),
#     # ^NLM mappings are for ICD9 only, don't bother looking for ICD10)
#     # Vthe only productive paths with an ICDx term on the left is equivalent class
#     "mydata:i9-eqClass-m" = list(
#       "mondo.top" = "<http://purl.obolibrary.org/obo/MONDO_0005275>",
#       "path.start" = "?icd",
#       "path.predicate"  = "owl:equivalentClass",
#       "path.end" = "?mondo",
#       "path.extras" = '',
#       "icd.graph" = '<http://purl.bioontology.org/ontology/ICD9CM/>'
#     ),
#     "mydata:i10-eqClass-m" = list(
#       "mondo.top" = "<http://purl.obolibrary.org/obo/MONDO_0005275>",
#       "path.start" = "?icd",
#       "path.predicate"  = "owl:equivalentClass",
#       "path.end" = "?mondo",
#       "path.extras" = '',
#       "icd.graph" = '<http://purl.bioontology.org/ontology/ICD10CM/>'
#     ),
#     # there are no productive paths with snomed terms on the left
#     # havent written any of these queries out
#     "mydata:m-dbxr-shared_cui-i9" = list(
#       "mondo.top" = "<http://purl.obolibrary.org/obo/MONDO_0005275>",
#       "path.start" = "?mondo",
#       "path.predicate" = "mydata:mdbxr",
#       "path.end" = "?cui",
#       "path.extras" = '
# graph <http://example.com/resource/materializedCui> {
#     ?icd <http://example.com/resource/materializedCui> ?cui .
# }',
#       "icd.graph" = '<http://purl.bioontology.org/ontology/ICD9CM/>'
#     ),
#     # the m-eqClass-shared_cui-iX paths aren't productive... see below
#     "mydata:m-eqClass-shared_cui-i9" = list(
#       "mondo.top" = "<http://purl.obolibrary.org/obo/MONDO_0005275>",
#       "path.start" = "?mondo",
#       "path.predicate" = "owl:equivalentClass",
#       "path.end" = "?cui",
#       "path.extras" = '
# graph <http://example.com/resource/materializedCui> {
#     ?icd <http://example.com/resource/materializedCui> ?cui .
# }',
#       "icd.graph" = '<http://purl.bioontology.org/ontology/ICD9CM/>'
#     ),
#     "mydata:m-exMatch-shared_cui-i9" = list(
#       "mondo.top" = "<http://purl.obolibrary.org/obo/MONDO_0005275>",
#       "path.start" = "?mondo",
#       "path.predicate" = "skos:exactMatch",
#       "path.end" = "?cui",
#       "path.extras" = '
# graph <http://example.com/resource/materializedCui> {
#     ?icd <http://example.com/resource/materializedCui> ?cui .
# }',
#       "icd.graph" = '<http://purl.bioontology.org/ontology/ICD9CM/>'
#     ),
#     "mydata:m-cMatch-shared_cui-i9" = list(
#       "mondo.top" = "<http://purl.obolibrary.org/obo/MONDO_0005275>",
#       "path.start" = "?mondo",
#       "path.predicate" = "skos:closeMatch",
#       "path.end" = "?cui",
#       "path.extras" = '
# graph <http://example.com/resource/materializedCui> {
#     ?icd <http://example.com/resource/materializedCui> ?cui .
# }',
#       "icd.graph" = '<http://purl.bioontology.org/ontology/ICD9CM/>'
#     ),
#     "mydata:m-dbxr-shared_cui-i10" = list(
#       "mondo.top" = "<http://purl.obolibrary.org/obo/MONDO_0005275>",
#       "path.start" = "?mondo",
#       "path.predicate" = "mydata:mdbxr",
#       "path.end" = "?cui",
#       "path.extras" = '
# graph <http://example.com/resource/materializedCui> {
#     ?icd <http://example.com/resource/materializedCui> ?cui .
# }',
#       "icd.graph" = '<http://purl.bioontology.org/ontology/ICD10CM/>'
#     ),
#     # the m-eqClass-shared_cui-iX paths aren't productive... see below
#     "mydata:m-eqClass-shared_cui-i10" = list(
#       "mondo.top" = "<http://purl.obolibrary.org/obo/MONDO_0005275>",
#       "path.start" = "?mondo",
#       "path.predicate" = "owl:equivalentClass",
#       "path.end" = "?cui",
#       "path.extras" = '
# graph <http://example.com/resource/materializedCui> {
#     ?icd <http://example.com/resource/materializedCui> ?cui .
# }',
#       "icd.graph" = '<http://purl.bioontology.org/ontology/ICD10CM/>'
#     ),
#     "mydata:m-exMatch-shared_cui-i10" = list(
#       "mondo.top" = "<http://purl.obolibrary.org/obo/MONDO_0005275>",
#       "path.start" = "?mondo",
#       "path.predicate" = "skos:exactMatch",
#       "path.end" = "?cui",
#       "path.extras" = '
# graph <http://example.com/resource/materializedCui> {
#     ?icd <http://example.com/resource/materializedCui> ?cui .
# }',
#       "icd.graph" = '<http://purl.bioontology.org/ontology/ICD10CM/>'
#     ),
#     "mydata:m-cMatch-shared_cui-i10" = list(
#       "mondo.top" = "<http://purl.obolibrary.org/obo/MONDO_0005275>",
#       "path.start" = "?mondo",
#       "path.predicate" = "skos:closeMatch",
#       "path.end" = "?cui",
#       "path.extras" = '
# graph <http://example.com/resource/materializedCui> {
#     ?icd <http://example.com/resource/materializedCui> ?cui .
# }',
#       "icd.graph" = '<http://purl.bioontology.org/ontology/ICD10CM/>'
#     ),
#     # the iX-...cui-m paths are only productive with equivalent class
#     "mydata:i9-shared_cui-eqClass-m" = list(
#       "mondo.top" = "<http://purl.obolibrary.org/obo/MONDO_0005275>",
#       "path.start" = "?cui",
#       "path.predicate" = "owl:equivalentClass",
#       "path.end" = "?mondo",
#       "path.extras" = '
# graph <http://example.com/resource/materializedCui> {
#     ?icd <http://example.com/resource/materializedCui> ?cui .
# }',
#       "icd.graph" = '<http://purl.bioontology.org/ontology/ICD9CM/>'
#     ),
#     # the iX-...cui-m paths are only productive with equivalent class
#     "mydata:i10-shared_cui-eqClass-m" = list(
#       "mondo.top" = "<http://purl.obolibrary.org/obo/MONDO_0005275>",
#       "path.start" = "?cui",
#       "path.predicate" = "owl:equivalentClass",
#       "path.end" = "?mondo",
#       "path.extras" = '
# graph <http://example.com/resource/materializedCui> {
#     ?icd <http://example.com/resource/materializedCui> ?cui .
# }',
#       "icd.graph" = '<http://purl.bioontology.org/ontology/ICD10CM/>'
#     )
#   )
#
#
#
#
# # cancer
# static.mondo.top <- "<http://purl.obolibrary.org/obo/MONDO_0004992>"
#
# # lung disease
# static.mondo.top <- "<http://purl.obolibrary.org/obo/MONDO_0005275>"
#
# static.mondo.top <- "<http://purl.obolibrary.org/obo/MONDO_0000001>"
#
#
# path.selections <- names(path.configs)
# # path.selections <- "mydata:m-eqClass-snomed-shared_cui-i9"
#
# placeholder <-
#   lapply(path.selections, function(current.name) {
#     # current.name <- "mydata:m-dbxr-i9"
#     # current.name <- "mydata:m-eqClass-snomed-shared_cui-i9"
#     print(current.name)
#     current.config <- path.configs[[current.name]]
#     # print(current.config)
#     # print(current.config[["mondo.top"]])
#     assembled.query <-
#       query.assembler(
#         paths.graphname = current.name,
#         # mondo.top = current.config[["mondo.top"]],
#         mondo.top = static.mondo.top,
#         path.start = current.config[["path.start"]],
#         path.predicate = current.config[["path.predicate"]],
#         path.end = current.config[["path.end"]],
#         path.extras = current.config[["path.extras"]],
#         icd.graph = current.config[["icd.graph"]]
#       )
#     # cat(assembled.query)
#
#     if (do.update) {
#       print("clear graph")
#       print(Sys.time())
#       post.res <- POST(update.endpoint,
#                        body = list(
#                          update = paste0(
#                            "
#     prefix mydata: <http://example.com/resource/>
#     clear graph ",
#                            current.name
#                          )
#                        ),
#                        saved.authentication)
#
#       print(post.res$status_code)
#       print(post.res$times[['total']])
#
#       print("insert")
#       print(Sys.time())
#       post.res <- POST(update.endpoint,
#                        body = list(update = assembled.query),
#                        saved.authentication)
#
#       print(post.res$status_code)
#       print(post.res$times[['total']])
#       # cat(assembled.query)
#
#     }
#
#     return(assembled.query)
#
#   })
#
# names(placeholder) <- path.selections

do.update <- FALSE

# parameterize minus
query.assembler <- function(paths.graphname = "mydata:m-dbxr-i9",
                            mondo.top = "<http://purl.obolibrary.org/obo/MONDO_0005275>",
                            path.start = "?mondo",
                            path.predicate = "mydata:mdbxr",
                            path.end = "?icd",
                            path.extras = "",
                            icd.native.graph = '<http://purl.bioontology.org/ontology/ICD10CM/>',
                            icd.transitvity.graph = '<http://example.com/resource/ICD10TransitiveSubClasses>') {
  assembled.query <- paste0(
    '
PREFIX mondo: <http://purl.obolibrary.org/obo/mondo#>
PREFIX mydata: <http://example.com/resource/>
PREFIX obo: <http://purl.obolibrary.org/obo/>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
PREFIX owl: <http://www.w3.org/2002/07/owl#>
insert {
    graph ',
    paths.graphname,
    ' {
        ?mondo mydata:mapsTo ?subIcd
    }
} where {
    graph <http://purl.obolibrary.org/obo/mondo.owl> {
        ?mondo rdfs:subClassOf+ ',
    mondo.top ,
    ' .
    }
    graph <http://example.com/resource/filteredMondoTransitiveSubClasses> {
        ?mondoSub rdfs:subClassOf ?mondo .
    }
    graph <http://example.com/resource/rewrites> { ',
    path.start,
    " ",
    path.predicate,
    " ",
    path.end,
    " . } ",
    path.extras,
    ' graph ',
    icd.native.graph,
    ' {
        ?icd a owl:Class .
    }
    graph ',
    icd.transitvity.graph ,
    '    {
        ?subIcd rdfs:subClassOf ?icd .
    }
}'
  )
  return(assembled.query)
}

icd.graph.pairs <- list(
  "icd9cm" = list(
    "icd.native.graph" = '<http://purl.bioontology.org/ontology/ICD9CM/>',
    "icd.transitvity.graph" = '<http://example.com/resource/ICD9DiseaseInjuryTransitiveSubClasses>'
  ),
  "icd10cm" = list(
    "icd.native.graph" = '<http://purl.bioontology.org/ontology/ICD10CM/>',
    "icd.transitvity.graph" = '<http://example.com/resource/ICD10TransitiveSubClasses>'
  )
)

path.configs <-
  list(
    # only the dbxr paths work for direct m-...-iX paths
    # could eliminate the others and save time
    "mydata:m-dbxr-i9" = list(
      "mondo.top" = "<http://purl.obolibrary.org/obo/MONDO_0005275>",
      "path.start" = "?mondo",
      "path.predicate" = "mydata:mdbxr",
      "path.end" = "?icd",
      "path.extras" = "",
      "icd.version" = "icd9cm"
    ),
    # "mydata:m-eqClass-i9" = list(
    #   "mondo.top" = "<http://purl.obolibrary.org/obo/MONDO_0005275>",
    #   "path.start" = "?mondo",
    #   "path.predicate" = "owl:equivalentClass",
    #   "path.end" = "?icd",
    #   "path.extras" = "",
    #   "icd.graph" = '<http://purl.bioontology.org/ontology/ICD9CM/>'
    # ),
    # "mydata:m-exMatch-i9" = list(
    #   "mondo.top" = "<http://purl.obolibrary.org/obo/MONDO_0005275>",
    #   "path.start" = "?mondo",
    #   "path.predicate" = "skos:exactMatch",
    #   "path.end" = "?icd",
    #   "path.extras" = "",
    #   "icd.graph" = '<http://purl.bioontology.org/ontology/ICD9CM/>'
    # ),
    # "mydata:m-cMatch-i9" = list(
    #   "mondo.top" = "<http://purl.obolibrary.org/obo/MONDO_0005275>",
    #   "path.start" = "?mondo",
    #   "path.predicate" = "skos:closeMatch",
    #   "path.end" = "?icd",
    #   "path.extras" = "",
    #   "icd.graph" = '<http://purl.bioontology.org/ontology/ICD9CM/>'
    # ),
    "mydata:m-dbxr-i10" = list(
      "mondo.top" = "<http://purl.obolibrary.org/obo/MONDO_0005275>",
      "path.start" = "?mondo",
      "path.predicate" = "mydata:mdbxr",
      "path.end" = "?icd",
      "path.extras" = "",
      "icd.version" = "icd10cm"
    ),
    #     ,
    #     # "mydata:m-eqClass-i10" = list(
    #     #   "mondo.top" = "<http://purl.obolibrary.org/obo/MONDO_0005275>",
    #     #   "path.start" = "?mondo",
    #     #   "path.predicate" = "owl:equivalentClass",
    #     #   "path.end" = "?icd",
    #     #   "path.extras" = "",
    #     #   "icd.graph" = '<http://purl.bioontology.org/ontology/ICD10CM/>'
    #     # ),
    #     # "mydata:m-exMatch-i10" = list(
    #     #   "mondo.top" = "<http://purl.obolibrary.org/obo/MONDO_0005275>",
    #     #   "path.start" = "?mondo",
    #     #   "path.predicate" = "skos:exactMatch",
    #     #   "path.end" = "?icd",
    #     #   "path.extras" = "",
    #     #   "icd.graph" = '<http://purl.bioontology.org/ontology/ICD10CM/>'
    #     # ),
    #     # "mydata:m-cMatch-i10" = list(
    #     #   "mondo.top" = "<http://purl.obolibrary.org/obo/MONDO_0005275>",
    #     #   "path.start" = "?mondo",
    #     #   "path.predicate" = "skos:closeMatch",
    #     #   "path.end" = "?icd",
    #     #   "path.extras" = "",
    #     #   "icd.graph" = '<http://purl.bioontology.org/ontology/ICD10CM/>'
    #     # ),
    # all eight of the next snomed shared CUI paths are productive
    # some predicates work with the terms rewritten from http://identifiers.org/snomedct/...
    # and the others work with those rewritten from  http://purl.obolibrary.org/obo/SCTID_
    # http://example.com/resource/SnomedDiseaseTransitiveSubClasses
    "mydata:m-dbxr-snomed-shared_cui-i9" = list(
      "mondo.top" = "<http://purl.obolibrary.org/obo/MONDO_0005275>",
      "path.start" = "?mondo",
      "path.predicate" = "mydata:mdbxr",
      "path.end" = "?code",
      "path.extras" = '
        graph <http://purl.bioontology.org/ontology/SNOMEDCT/> {
        ?code a owl:Class .
        }
        graph <http://example.com/resource/SnomedDiseaseTransitiveSubClasses> {
        ?subcode rdfs:subClassOf ?code
        }
        graph mydata:materializedCui {
            ?subcode mydata:materializedCui ?materializedCui .
            ?icd mydata:materializedCui ?materializedCui .
        }',
      "icd.version" = "icd9cm"
    )
    #     "mydata:m-eqClass-snomed-shared_cui-i9" = list(
    #       "mondo.top" = "<http://purl.obolibrary.org/obo/MONDO_0005275>",
    #       "path.start" = "?mondo",
    #       "path.predicate"  = "owl:equivalentClass",
    #       "path.end" = "?code",
    #       "path.extras" = '
    #     graph <http://purl.bioontology.org/ontology/SNOMEDCT/> {
    #         ?subcode rdfs:subClassOf* ?code ;
    #                                 skos:prefLabel ?subCodeLabel .
    #     }
    #     graph mydata:materializedCui {
    #         ?subcode mydata:materializedCui ?materializedCui .
    #         ?icd mydata:materializedCui ?materializedCui .
    #     }',
    #       "icd.graph" = '<http://purl.bioontology.org/ontology/ICD9CM/>'
    #     ),
    #     "mydata:m-exMatch-snomed-shared_cui-i9" = list(
    #       "mondo.top" = "<http://purl.obolibrary.org/obo/MONDO_0005275>",
    #       "path.start" = "?mondo",
    #       "path.predicate"  = "skos:exactMatch",
    #       "path.end" = "?code",
    #       "path.extras" = '
    #     graph <http://purl.bioontology.org/ontology/SNOMEDCT/> {
    #         ?subcode rdfs:subClassOf* ?code ;
    #                                 skos:prefLabel ?subCodeLabel .
    #     }
    #     graph mydata:materializedCui {
    #         ?subcode mydata:materializedCui ?materializedCui .
    #         ?icd mydata:materializedCui ?materializedCui .
    #     }',
    #       "icd.graph" = '<http://purl.bioontology.org/ontology/ICD9CM/>'
    #     ),
    #     "mydata:m-cMatch-snomed-shared_cui-i9" = list(
    #       "mondo.top" = "<http://purl.obolibrary.org/obo/MONDO_0005275>",
    #       "path.start" = "?mondo",
    #       "path.predicate"  = "skos:closeMatch",
    #       "path.end" = "?code",
    #       "path.extras" = '
    #     graph <http://purl.bioontology.org/ontology/SNOMEDCT/> {
    #         ?subcode rdfs:subClassOf* ?code ;
    #                                 skos:prefLabel ?subCodeLabel .
    #     }
    #     graph mydata:materializedCui {
    #         ?subcode mydata:materializedCui ?materializedCui .
    #         ?icd mydata:materializedCui ?materializedCui .
    #     }',
    #       "icd.graph" = '<http://purl.bioontology.org/ontology/ICD9CM/>'
    #     ),
    #     "mydata:m-dbxr-snomed-shared_cui-i10" = list(
    #       "mondo.top" = "<http://purl.obolibrary.org/obo/MONDO_0005275>",
    #       "path.start" = "?mondo",
    #       "path.predicate" = "mydata:mdbxr",
    #       "path.end" = "?code",
    #       "path.extras" = '
    #     graph <http://purl.bioontology.org/ontology/SNOMEDCT/> {
    #         ?subcode rdfs:subClassOf* ?code ;
    #                                 skos:prefLabel ?subCodeLabel .
    #     }
    #     graph mydata:materializedCui {
    #         ?subcode mydata:materializedCui ?materializedCui .
    #         ?icd mydata:materializedCui ?materializedCui .
    #     }',
    #       "icd.graph" = '<http://purl.bioontology.org/ontology/ICD10CM/>'
    #     ),
    #     "mydata:m-eqClass-snomed-shared_cui-i10" = list(
    #       "mondo.top" = "<http://purl.obolibrary.org/obo/MONDO_0005275>",
    #       "path.start" = "?mondo",
    #       "path.predicate"  = "owl:equivalentClass",
    #       "path.end" = "?code",
    #       "path.extras" = '
    #     graph <http://purl.bioontology.org/ontology/SNOMEDCT/> {
    #         ?subcode rdfs:subClassOf* ?code ;
    #                                 skos:prefLabel ?subCodeLabel .
    #     }
    #     graph mydata:materializedCui {
    #         ?subcode mydata:materializedCui ?materializedCui .
    #         ?icd mydata:materializedCui ?materializedCui .
    #     }',
    #       "icd.graph" = '<http://purl.bioontology.org/ontology/ICD10CM/>'
    #     ),
    #     "mydata:m-exMatch-snomed-shared_cui-i10" = list(
    #       "mondo.top" = "<http://purl.obolibrary.org/obo/MONDO_0005275>",
    #       "path.start" = "?mondo",
    #       "path.predicate"  = "skos:exactMatch",
    #       "path.end" = "?code",
    #       "path.extras" = '
    #     graph <http://purl.bioontology.org/ontology/SNOMEDCT/> {
    #         ?subcode rdfs:subClassOf* ?code ;
    #                                 skos:prefLabel ?subCodeLabel .
    #     }
    #     graph mydata:materializedCui {
    #         ?subcode mydata:materializedCui ?materializedCui .
    #         ?icd mydata:materializedCui ?materializedCui .
    #     }',
    #       "icd.graph" = '<http://purl.bioontology.org/ontology/ICD10CM/>'
    #     ),
    #     "mydata:m-cMatch-snomed-shared_cui-i10" = list(
    #       "mondo.top" = "<http://purl.obolibrary.org/obo/MONDO_0005275>",
    #       "path.start" = "?mondo",
    #       "path.predicate"  = "skos:closeMatch",
    #       "path.end" = "?code",
    #       "path.extras" = '
    #     graph <http://purl.bioontology.org/ontology/SNOMEDCT/> {
    #         ?subcode rdfs:subClassOf* ?code ;
    #                                 skos:prefLabel ?subCodeLabel .
    #     }
    #     graph mydata:materializedCui {
    #         ?subcode mydata:materializedCui ?materializedCui .
    #         ?icd mydata:materializedCui ?materializedCui .
    #     }',
    #       "icd.graph" = '<http://purl.bioontology.org/ontology/ICD10CM/>'
    #     ),
    #     ###
    #     "mydata:m-dbxr-snomed-NLM_mappings-i9" = list(
    #       "mondo.top" = "<http://purl.obolibrary.org/obo/MONDO_0005275>",
    #       "path.start" = "?mondo",
    #       "path.predicate"  = "mydata:mdbxr",
    #       "path.end" = "?code",
    #       "path.extras" = '
    #     graph <http://purl.bioontology.org/ontology/SNOMEDCT/> {
    #         ?subcode rdfs:subClassOf* ?code ;
    #                                 skos:prefLabel ?subCodeLabel .
    #     }
    #     graph <https://www.nlm.nih.gov/research/umls/mapping_projects/icd9cm_to_snomedct.html> {
    #         ?icd <https://www.nlm.nih.gov/research/umls/mapping_projects/icd9cm_to_snomedct.html> ?subcode
    #     }',
    #       "icd.graph" = '<http://purl.bioontology.org/ontology/ICD9CM/>'
    #     )
    #     ,
    #     "mydata:m-eqClass-snomed-NLM_mappings-i9" = list(
    #       "mondo.top" = "<http://purl.obolibrary.org/obo/MONDO_0005275>",
    #       "path.start" = "?mondo",
    #       "path.predicate"  = "owl:equivalentClass",
    #       "path.end" = "?code",
    #       "path.extras" = '
    #     graph <http://purl.bioontology.org/ontology/SNOMEDCT/> {
    #         ?subcode rdfs:subClassOf* ?code ;
    #                                 skos:prefLabel ?subCodeLabel .
    #     }
    #     graph <https://www.nlm.nih.gov/research/umls/mapping_projects/icd9cm_to_snomedct.html> {
    #         ?icd <https://www.nlm.nih.gov/research/umls/mapping_projects/icd9cm_to_snomedct.html> ?subcode
    #     }',
    #       "icd.graph" = '<http://purl.bioontology.org/ontology/ICD9CM/>'
    #     )
    #     ,
    #     "mydata:m-exMatch-snomed-NLM_mappings-i9" = list(
    #       "mondo.top" = "<http://purl.obolibrary.org/obo/MONDO_0005275>",
    #       "path.start" = "?mondo",
    #       "path.predicate"  = "skos:exactMatch",
    #       "path.end" = "?code",
    #       "path.extras" = '
    #     graph <http://purl.bioontology.org/ontology/SNOMEDCT/> {
    #         ?subcode rdfs:subClassOf* ?code ;
    #                                 skos:prefLabel ?subCodeLabel .
    #     }
    #     graph <https://www.nlm.nih.gov/research/umls/mapping_projects/icd9cm_to_snomedct.html> {
    #         ?icd <https://www.nlm.nih.gov/research/umls/mapping_projects/icd9cm_to_snomedct.html> ?subcode
    #     }',
    #       "icd.graph" = '<http://purl.bioontology.org/ontology/ICD9CM/>'
    #     )
    #     ,
    #     "mydata:m-cMatch-snomed-NLM_mappings-i9" = list(
    #       "mondo.top" = "<http://purl.obolibrary.org/obo/MONDO_0005275>",
    #       "path.start" = "?mondo",
    #       "path.predicate"  = "skos:closeMatch",
    #       "path.end" = "?code",
    #       "path.extras" = '
    #     graph <http://purl.bioontology.org/ontology/SNOMEDCT/> {
    #         ?subcode rdfs:subClassOf* ?code ;
    #                                 skos:prefLabel ?subCodeLabel .
    #     }
    #     graph <https://www.nlm.nih.gov/research/umls/mapping_projects/icd9cm_to_snomedct.html> {
    #         ?icd <https://www.nlm.nih.gov/research/umls/mapping_projects/icd9cm_to_snomedct.html> ?subcode
    #     }',
    #       "icd.graph" = '<http://purl.bioontology.org/ontology/ICD9CM/>'
    #     ),
    #     # ^NLM mappings are for ICD9 only, don't bother looking for ICD10)
    #     # Vthe only productive paths with an ICDx term on the left is equivalent class
    #     "mydata:i9-eqClass-m" = list(
    #       "mondo.top" = "<http://purl.obolibrary.org/obo/MONDO_0005275>",
    #       "path.start" = "?icd",
    #       "path.predicate"  = "owl:equivalentClass",
    #       "path.end" = "?mondo",
    #       "path.extras" = '',
    #       "icd.graph" = '<http://purl.bioontology.org/ontology/ICD9CM/>'
    #     ),
    #     "mydata:i10-eqClass-m" = list(
    #       "mondo.top" = "<http://purl.obolibrary.org/obo/MONDO_0005275>",
    #       "path.start" = "?icd",
    #       "path.predicate"  = "owl:equivalentClass",
    #       "path.end" = "?mondo",
    #       "path.extras" = '',
    #       "icd.graph" = '<http://purl.bioontology.org/ontology/ICD10CM/>'
    #     ),
    #     # there are no productive paths with snomed terms on the left
    #     # havent written any of these queries out
    #     "mydata:m-dbxr-shared_cui-i9" = list(
    #       "mondo.top" = "<http://purl.obolibrary.org/obo/MONDO_0005275>",
    #       "path.start" = "?mondo",
    #       "path.predicate" = "mydata:mdbxr",
    #       "path.end" = "?cui",
    #       "path.extras" = '
    # graph <http://example.com/resource/materializedCui> {
    #     ?icd <http://example.com/resource/materializedCui> ?cui .
    # }',
    #       "icd.graph" = '<http://purl.bioontology.org/ontology/ICD9CM/>'
    #     ),
    #     # the m-eqClass-shared_cui-iX paths aren't productive... see below
    #     "mydata:m-eqClass-shared_cui-i9" = list(
    #       "mondo.top" = "<http://purl.obolibrary.org/obo/MONDO_0005275>",
    #       "path.start" = "?mondo",
    #       "path.predicate" = "owl:equivalentClass",
    #       "path.end" = "?cui",
    #       "path.extras" = '
    # graph <http://example.com/resource/materializedCui> {
    #     ?icd <http://example.com/resource/materializedCui> ?cui .
    # }',
    #       "icd.graph" = '<http://purl.bioontology.org/ontology/ICD9CM/>'
    #     ),
    #     "mydata:m-exMatch-shared_cui-i9" = list(
    #       "mondo.top" = "<http://purl.obolibrary.org/obo/MONDO_0005275>",
    #       "path.start" = "?mondo",
    #       "path.predicate" = "skos:exactMatch",
    #       "path.end" = "?cui",
    #       "path.extras" = '
    # graph <http://example.com/resource/materializedCui> {
    #     ?icd <http://example.com/resource/materializedCui> ?cui .
    # }',
    #       "icd.graph" = '<http://purl.bioontology.org/ontology/ICD9CM/>'
    #     ),
    #     "mydata:m-cMatch-shared_cui-i9" = list(
    #       "mondo.top" = "<http://purl.obolibrary.org/obo/MONDO_0005275>",
    #       "path.start" = "?mondo",
    #       "path.predicate" = "skos:closeMatch",
    #       "path.end" = "?cui",
    #       "path.extras" = '
    # graph <http://example.com/resource/materializedCui> {
    #     ?icd <http://example.com/resource/materializedCui> ?cui .
    # }',
    #       "icd.graph" = '<http://purl.bioontology.org/ontology/ICD9CM/>'
    #     ),
    #     "mydata:m-dbxr-shared_cui-i10" = list(
    #       "mondo.top" = "<http://purl.obolibrary.org/obo/MONDO_0005275>",
    #       "path.start" = "?mondo",
    #       "path.predicate" = "mydata:mdbxr",
    #       "path.end" = "?cui",
    #       "path.extras" = '
    # graph <http://example.com/resource/materializedCui> {
    #     ?icd <http://example.com/resource/materializedCui> ?cui .
    # }',
    #       "icd.graph" = '<http://purl.bioontology.org/ontology/ICD10CM/>'
    #     ),
    #     # the m-eqClass-shared_cui-iX paths aren't productive... see below
    #     "mydata:m-eqClass-shared_cui-i10" = list(
    #       "mondo.top" = "<http://purl.obolibrary.org/obo/MONDO_0005275>",
    #       "path.start" = "?mondo",
    #       "path.predicate" = "owl:equivalentClass",
    #       "path.end" = "?cui",
    #       "path.extras" = '
    # graph <http://example.com/resource/materializedCui> {
    #     ?icd <http://example.com/resource/materializedCui> ?cui .
    # }',
    #       "icd.graph" = '<http://purl.bioontology.org/ontology/ICD10CM/>'
    #     ),
    #     "mydata:m-exMatch-shared_cui-i10" = list(
    #       "mondo.top" = "<http://purl.obolibrary.org/obo/MONDO_0005275>",
    #       "path.start" = "?mondo",
    #       "path.predicate" = "skos:exactMatch",
    #       "path.end" = "?cui",
    #       "path.extras" = '
    # graph <http://example.com/resource/materializedCui> {
    #     ?icd <http://example.com/resource/materializedCui> ?cui .
    # }',
    #       "icd.graph" = '<http://purl.bioontology.org/ontology/ICD10CM/>'
    #     ),
    #     "mydata:m-cMatch-shared_cui-i10" = list(
    #       "mondo.top" = "<http://purl.obolibrary.org/obo/MONDO_0005275>",
    #       "path.start" = "?mondo",
    #       "path.predicate" = "skos:closeMatch",
    #       "path.end" = "?cui",
    #       "path.extras" = '
    # graph <http://example.com/resource/materializedCui> {
    #     ?icd <http://example.com/resource/materializedCui> ?cui .
    # }',
    #       "icd.graph" = '<http://purl.bioontology.org/ontology/ICD10CM/>'
    #     ),
    #     # the iX-...cui-m paths are only productive with equivalent class
    #     "mydata:i9-shared_cui-eqClass-m" = list(
    #       "mondo.top" = "<http://purl.obolibrary.org/obo/MONDO_0005275>",
    #       "path.start" = "?cui",
    #       "path.predicate" = "owl:equivalentClass",
    #       "path.end" = "?mondo",
    #       "path.extras" = '
    # graph <http://example.com/resource/materializedCui> {
    #     ?icd <http://example.com/resource/materializedCui> ?cui .
    # }',
    #       "icd.graph" = '<http://purl.bioontology.org/ontology/ICD9CM/>'
    #     ),
    #     # the iX-...cui-m paths are only productive with equivalent class
    #     "mydata:i10-shared_cui-eqClass-m" = list(
    #       "mondo.top" = "<http://purl.obolibrary.org/obo/MONDO_0005275>",
    #       "path.start" = "?cui",
    #       "path.predicate" = "owl:equivalentClass",
    #       "path.end" = "?mondo",
    #       "path.extras" = '
    # graph <http://example.com/resource/materializedCui> {
    #     ?icd <http://example.com/resource/materializedCui> ?cui .
    # }',
    #       "icd.graph" = '<http://purl.bioontology.org/ontology/ICD10CM/>'
    #     )
  )




# cancer
static.mondo.top <- "<http://purl.obolibrary.org/obo/MONDO_0004992>"

# lung disease
static.mondo.top <- "<http://purl.obolibrary.org/obo/MONDO_0005275>"

static.mondo.top <- "<http://purl.obolibrary.org/obo/MONDO_0000001>"


path.selections <- names(path.configs)
# path.selections <- "mydata:m-eqClass-snomed-shared_cui-i9"

placeholder <-
  lapply(path.selections, function(current.name) {
    # current.name <- "mydata:m-dbxr-i9"
    # current.name <- "mydata:m-eqClass-snomed-shared_cui-i9"
    print(current.name)
    current.config <- path.configs[[current.name]]
    # print(current.config)
    # print(current.config[["mondo.top"]])
    
    icd.version <- current.config[['icd.version']]
    icd.native.graph <-
      icd.graph.pairs[[icd.version]][['icd.native.graph']]
    icd.transitvity.graph <-
      icd.graph.pairs[[icd.version]][['icd.transitvity.graph']]
    
    print(icd.version)
    print(icd.native.graph)
    
    assembled.query <-
      query.assembler(
        paths.graphname = current.name,
        # mondo.top = current.config[["mondo.top"]],
        mondo.top = static.mondo.top,
        path.start = current.config[["path.start"]],
        path.predicate = current.config[["path.predicate"]],
        path.end = current.config[["path.end"]],
        path.extras = current.config[["path.extras"]],
        icd.native.graph = icd.native.graph ,
        icd.transitvity.graph = icd.transitvity.graph
      )
    # cat(assembled.query)
    
    if (do.update) {
      print("clear graph")
      print(Sys.time())
      post.res <- POST(update.endpoint,
                       body = list(
                         update = paste0(
                           "
    prefix mydata: <http://example.com/resource/>
    clear graph ",
                           current.name
                         )
                       ),
                       saved.authentication)
      
      print(post.res$status_code)
      print(post.res$times[['total']])
      
      print("insert")
      print(Sys.time())
      post.res <- POST(update.endpoint,
                       body = list(update = assembled.query),
                       saved.authentication)
      
      print(post.res$status_code)
      print(post.res$times[['total']])
      # cat(assembled.query)
      
    }
    
    return(assembled.query)
    
  })

names(placeholder) <- path.selections

cat(placeholder[["mydata:m-dbxr-snomed-shared_cui-i9"]])
