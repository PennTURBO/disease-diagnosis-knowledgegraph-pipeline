library(config)
library(SPARQL)

library(httr)
library(jsonlite)

### revision log
# switched to yaml config
# refactored monitor.named.graphs into a function

# SNOMEDCT or SNOMEDCT_US?
# UMLS uses "SNOMEDCT_US" as their source abbrevation, adn that's what umls2rdf URIs use

# apply SPARQL updates over labels, not the queries themselves? (DONE?)

# continue re-factoring SPARQL prefixes

###

# could have used: jsonlite? rjsonio? rjson?
# slight differences in the returned structure
# need to match with monitoring/expectation code

# includes example of pure SPARQL::SPARQL update with authentication

# what's an example of scripts that do use yaml and named graph monitoring function?
#   tweencorn on http://pennturbo.org:8787/?
# see also
#   https://github.com/PennTURBO/disease_to_diagnosis_code/blob/master/populate_disease_to_diagnosis_code_repo.R
#     6672527 on Jun 20, 2019
#   https://github.com/pennbiobank/turbo/blob/master/doodads/directEvidenceFor_transIcd.R
#     5440382 on Aug 12, 2019
###

# continue re-factoring SPARQL prefixes

# maybe
# materialize all of the paths and then flatten for Hayden
# filter out rare diseases, syndromes or congenital conditions from mondo
# haven't put SNOMEDCT filtering into production yet
# cancer maps to lots of false positives?
# materialize SNOMEDCT's icd10 text mappings? they might just be the same as shared CUIs?

###


# start by loading
# snomed from the ums2rdf pipeline into http://purl.bioontology.org/ontology/SNOMEDCT_US/
# icd9  from BioPortal
# icd10 from BioPortal
# mondo from http://purl.obolibrary.org/obo/mondo.owl into http://purl.obolibrary.org/obo/mondo.owl
#   may have to be staged as a file? GraphDB complains about loading some RDF files from web URLs
#   OK, just check the redirection path for the obolibrary URL and state that its RDF/XML formatted?
# ontorefine instantation of
#   https://download.nlm.nih.gov/umls/kss/mappings/ICD9CM_TO_SNOMEDCT/ICD9CM_TO_SNOMEDCT_DIAGNOSIS_201812.zip
#   from server graphdb-import folder
#   previous dd scripts required loading the ICD9CM_TO_SNOMEDCT_DIAGNOSIS_201812 CSV files into OntoRefine projects
#   and instantiated them on the fly

# SAPRQL used to instantiate two CSVs (imported into two projects)
# from https://download.nlm.nih.gov/umls/kss/mappings/ICD9CM_TO_SNOMEDCT/ICD9CM_TO_SNOMEDCT_DIAGNOSIS_201812.zip
# with ontorefine

# PREFIX mydata: <http://example.com/resource/>
#   PREFIX spif: <http://spinrdf.org/spif#>
# insert {
#   graph <https://www.nlm.nih.gov/research/umls/mapping_projects/icd9cm_to_snomedct.html> {
#     ?myRowId a <https://www.nlm.nih.gov/research/umls/mapping_projects/icd9cm_to_snomedct.html> ;
#     mydata:File ?File ;
#     mydata:ICD_CODE ?ICD_CODE ;
#     mydata:ICD_NAME ?ICD_NAME ;
#     mydata:IS_CURRENT_ICD ?IS_CURRENT_ICD ;
#     mydata:IP_USAGE ?IP_USAGE ;
#     mydata:OP_USAGE ?OP_USAGE ;
#     mydata:AVG_USAGE ?AVG_USAGE ;
#     mydata:IS_NEC ?IS_NEC ;
#     mydata:SNOMED_CID ?SNOMED_CID ;
#     mydata:SNOMED_FSN ?SNOMED_FSN ;
#     mydata:IS_1-1MAP ?IS_1_1MAP ;
#     mydata:CORE_USAGE ?CORE_USAGE ;
#     mydata:IN_CORE ?IN_CORE .
#   }
# } WHERE {
#   SERVICE <SOME ONTOREFINE PROJECT CODE> {
#   ?row a mydata:Row ;
#   mydata:File ?File ;
#   mydata:ICD_CODE ?ICD_CODE .
#   optional {
#     ?row mydata:ICD_NAME ?ICD_NAME ;
#   }
#   optional {
#     ?row mydata:IS_CURRENT_ICD ?IS_CURRENT_ICD ;
#   }
#   optional {
#     ?row  mydata:IP_USAGE ?IP_USAGE ;
#   }
#   optional {
#     ?row  mydata:OP_USAGE ?OP_USAGE ;
#   }
#   optional {
#     ?row  mydata:AVG_USAGE ?AVG_USAGE ;
#   }
#   optional {
#     ?row  mydata:IS_NEC ?IS_NEC ;
#   }
#   optional {
#     ?row  mydata:SNOMED_CID ?SNOMED_CID ;
#   }
#   optional {
#     ?row  mydata:SNOMED_FSN ?SNOMED_FSN ;
#   }
#   optional {
#     ?row  mydata:IS_1-1MAP ?IS_1_1MAP ;
#   }
#   optional {
#     ?row  mydata:CORE_USAGE ?CORE_USAGE ;
#   }
#   optional {
#     ?row  mydata:IN_CORE ?IN_CORE .
#   }
#   BIND(uuid() AS ?myRowId)
# }
# }'


# bioportal has ICDs (including ICDO!)
# http://bioportal.bioontology.org/ontologies/ICD-O-3-M
# http://bioportal.bioontology.org/ontologies/ICD-O-3-T
# but may be a few months behind the UMLS may/November releases ?
# http://bioportal.bioontology.org/ontologies/ICD10CM
# there's no public snomed RDF release at this point
# they're working on one, and currently provide a Perl script
# https://confluence.ihtsdotools.org/display/DOCTSG/9.2.6+SNOMED+CT+OWL+Distribution+FAQ

# version predictes:
# subject	predicate	object	context
# http://purl.bioontology.org/ontology/ICD10CM/ 	owl:versionInfo 	2019aa	http://purl.bioontology.org/ontology/ICD10CM/
# http://purl.bioontology.org/ontology/ICD9CM/ 	owl:versionInfo 	2019aa	http://purl.bioontology.org/ontology/ICD9CM/
# snomed: 	owl:versionInfo 	2019aa	snomed:

# subject	predicate	object	context
# obo:mondo.owl 	owl:versionIRI 	obo:mondo/releases/2019-07-28/mondo.owl 	obo:mondo.owl

# repos (or individual named graphs) can be dumped with something like this.
# be sure to save into the graphdb-import folder in conf/graphdb.properties

# $ curl -X GET --header 'Accept: application/x-binary-rdf' 'http://localhost:7200/repositories/dd_by_wire/statements' -o snomed_icd_9_10_cm_2019aa.brf
# % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
# Dload  Upload   Total   Spent    Left  Speed
# 100  887M    0  887M    0     0  13.1M      0 --:--:--  0:01:07 --:--:-- 9515k

# turbo ontology good for testing loading methods
# https://raw.githubusercontent.com/PennTURBO/Turbo-Ontology/master/ontologies/turbo_merged.owl
# see also https://wheregoes.com/retracer.php
# don't forget to assert type as RDF/XML ?

###

config.bootstrap <-
  config::get(file = "disease_diagnosis.yaml")

selected.gdb.configuration <-
  config::get(config = config.bootstrap$selected.gdb.configuration,
              file = "disease_diagnosis.yaml")

monitor.pause.seconds <- config.bootstrap$monitor.pause.seconds
snomed.triples.file <-
  selected.gdb.configuration$snomed.triples.file
icd9_to_snomed.triples.file <-
  selected.gdb.configuration$icd9_to_snomed.triples.file

# does this ever get used?
bp.api.key <- config.bootstrap$bp.api.key

graphdb.address.port <-
  selected.gdb.configuration$graphdb.address.port
selected.repo <- selected.gdb.configuration$selected.repo
api.user <- selected.gdb.configuration$api.user
api.pass <- selected.gdb.configuration$api.pass

debug.flag <- config.bootstrap$debug.flag
delete.isolated.flag <- config.bootstrap$delete.isolated.flag

# NEW
ICD9CM.uri <- config.bootstrap$ICD9CM.uri
ICD10CM.uri <- config.bootstrap$ICD10CM.uri
umls.semantic.types.uri <- config.bootstrap$umls.semantic.types.uri


saved.authentication <-
  authenticate(api.user, api.pass, type = "basic")

sparql.prefixes <- "
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
"

update.endpoint <-
  paste0(graphdb.address.port,
         "/repositories/",
         selected.repo,
         "/statements")

select.endpoint <-
  paste0(graphdb.address.port, "/repositories/", selected.repo)

url.post.endpoint <-
  paste0(graphdb.address.port,
         "/rest/data/import/upload/",
         selected.repo,
         "/url")

filesystem.post.endpoint <-
  paste0(graphdb.address.port,
         "/rest/data/import/server/",
         selected.repo,
         "/")

# THE DIFFERENT JSON LIBRARIES RETURN THE CONTENTS IN DIFFERENT FORMATS
# SOME OF WHICH MAY BE MORE CONVENIENT THAN OTHERS

monitor.named.graphs <- function() {
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
    
    context.report <-
      jsonlite::fromJSON(rawToChar(context.report$content))
    # this will be a vector
    context.report <-
      context.report$results$bindings$contextID$value
    
    # SHOULD THESE BE LEFT AS GLOBALS OR BE SWITCHED TO FUNCTION PARAMETERS?
    print(paste0(
      Sys.time(),
      ": '",
      last.post.status,
      "' submitted at ",
      last.post.time
    ))
    # print(paste0("Expecting graphs ", expectation, collapse = " ; "))
    # print(paste0("Current graphs ", context.report, collapse = " ; "))
    
    print(paste0("Expected graphs: ", sort(expectation)))
    print(paste0("Current graphs:  ", sort(context.report)))
    
    print(paste0("Next check in ",
                 monitor.pause.seconds,
                 " seconds."))
    
    Sys.sleep(monitor.pause.seconds)
    moveon <- setdiff(expectation, context.report)
    # will this properly handle the case when the report is empty (NULL)?
    if (length(moveon) == 0) {
      print("Update complete")
      break()
    }
  }
}

###  END OF SETUP



#' # RDF4J configuration template for the GraphDB Free repository
#' @prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#>.
#' @prefix rep: <http://www.openrdf.org/config/repository#>.
#' @prefix sr: <http://www.openrdf.org/config/repository/sail#>.
#' @prefix sail: <http://www.openrdf.org/config/sail#>.
#' @prefix owlim: <http://www.ontotext.com/trree/owlim#>.
#'
#' [] a rep:Repository ;
#' rep:repositoryID "disease_diagnosis_dev" ;
#' rdfs:label "" ;
#' rep:repositoryImpl [
#'   rep:repositoryType "graphdb:FreeSailRepository" ;
#'   sr:sailImpl [
#'     sail:sailType "graphdb:FreeSail" ;
#'
#'     owlim:base-URL "http://example.org/owlim#" ;
#'     owlim:defaultNS "" ;
#'     owlim:entity-index-size "10000000" ;
#'     owlim:entity-id-size  "32" ;
#'     owlim:imports "" ;
#'     owlim:repository-type "file-repository" ;
#'     owlim:ruleset "empty" ;
#'     owlim:storage-folder "storage" ;
#'
#'     owlim:enable-context-index "true" ;
#'
#'     owlim:enablePredicateList "true" ;
#'
#'     owlim:in-memory-literal-properties "true" ;
#'     owlim:enable-literal-index "true" ;
#'
#'     owlim:check-for-inconsistencies "false" ;
#'     owlim:disable-sameAs  "true" ;
#'     owlim:query-timeout  "0" ;
#'     owlim:query-limit-results  "0" ;
#'     owlim:throw-QueryEvaluationException-on-timeout "false" ;
#'     owlim:read-only "false" ;
#'     ]
#'   ].


###   ###   ###

# CLEAR REPO

last.post.time <- Sys.time()

# post.res <- POST(update.endpoint,
#                  body = list(update = "clear all"),
#                  saved.authentication)
#
# # empty for sparql statement
# last.post.status <- rawToChar(post.res$content)


# or just do it as a sparql update

last.post.status <- update.statement <- "clear all"

sparql.result <-
  SPARQL(
    url =  update.endpoint,
    update = update.statement,
    curl_args = list(
      userpwd = paste0(api.user, ":", api.pass),
      httpauth = 1
    )
  )

# Warning message:
#   In testCurlOptionsInFormParameters(.params) :
#   Found possible curl options in form parameters: userpwd, httpauth

expectation <- NULL

monitor.named.graphs()

### MONDO

update.body <- '{
  "context": "http://purl.obolibrary.org/obo/mondo.owl",
  "data": "https://github.com/monarch-initiative/mondo/releases/download/current/mondo.owl",
  "format": "RDF/XML"
}'

post.res <- POST(
  url.post.endpoint,
  body = update.body,
  content_type("application/json"),
  accept("application/json"),
  saved.authentication
)

last.post.status <- rawToChar(post.res$content)
last.post.time <- Sys.time()

### ICD9CM

update.body <- paste0(
  '{
  "type":"url",
  "format":"text/turtle",
  "context": "http://purl.bioontology.org/ontology/ICD9CM/",
  "data": "',
  ICD9CM.uri,
  '"
}'
)

post.res <- POST(
  url.post.endpoint,
  body = update.body,
  content_type("application/json"),
  accept("application/json"),
  saved.authentication
)

last.post.status <- rawToChar(post.res$content)
last.post.time <- Sys.time()

### ICD10CM

update.body <- paste0(
  '{
  "type":"url",
  "format":"text/turtle",
  "context": "http://purl.bioontology.org/ontology/ICD10CM/",
  "data": "',
  ICD10CM.uri,
  '"
}'
)

post.res <- POST(
  url.post.endpoint,
  body = update.body,
  content_type("application/json"),
  accept("application/json"),
  saved.authentication
)

last.post.status <- rawToChar(post.res$content)
last.post.time <- Sys.time()


### semantic types
# I used to include these in each bioportal export
#   and in a separate file
# now I'm doing separate file only
# no ontology name is asserted in the file
# graph/context name?
# https://bioportal.bioontology.org/ontologies/STY ?
# http://purl.bioontology.org/ontology/STY/ ?
# https://www.nlm.nih.gov/research/umls/META3_current_semantic_types.html ?


update.body <- paste0(
  '{
  "type":"url",
  "format":"text/turtle",
  "context": "http://purl.bioontology.org/ontology/STY/",
  "data": "',
  umls.semantic.types.uri,
  '"
}'
)


post.res <- POST(
  url.post.endpoint,
  body = update.body,
  content_type("application/json"),
  accept("application/json"),
  saved.authentication
)


last.post.status <- rawToChar(post.res$content)
last.post.time <- Sys.time()

### icd9<->snomed mappings from https://www.nlm.nih.gov/research/umls/mapping_projects/icd9cm_to_snomedct.html,
# direct-map instantiated with OntoRefine, and saved to turtle file
# named graph?

update.body <- paste0(
  '{
  "fileNames": ["',
  icd9_to_snomed.triples.file,
  '"],
  "importSettings": { "context": "https://www.nlm.nih.gov/research/umls/mapping_projects/icd9cm_to_snomedct.html" }
}'
)

post.res <- POST(
  filesystem.post.endpoint,
  body = update.body,
  content_type("application/json"),
  accept("application/json"),
  saved.authentication
)

# ### snomed
# # use umls2rdf pipeline and save on local filesystem
# # DOCUMENTATION  = https://github.com/PennTURBO/disease_to_diagnosis_code/blob/master/disease_diagnosis_dev_inc_prep.md

update.body <- paste0(
  '{
  "fileNames": ["',
  snomed.triples.file,
  '"],
  "importSettings": { "context": "http://purl.bioontology.org/ontology/SNOMEDCT_US/" }
}'
)

post.res <- POST(
  filesystem.post.endpoint,
  body = update.body,
  content_type("application/json"),
  accept("application/json"),
  saved.authentication
)

last.post.status <- rawToChar(post.res$content)
last.post.time <- Sys.time()


###

expectation <-
  c(
    "http://purl.obolibrary.org/obo/mondo.owl",
    "http://purl.bioontology.org/ontology/ICD9CM/",
    "http://purl.bioontology.org/ontology/ICD10CM/",
    "http://purl.bioontology.org/ontology/SNOMEDCT_US/",
    "http://purl.bioontology.org/ontology/STY/",
    "https://www.nlm.nih.gov/research/umls/mapping_projects/icd9cm_to_snomedct.html"
  )

monitor.named.graphs()

###   ###   ###

### ARE ANY OF THESE NOTES, UP TO "update.list <- list()" STILL RELEVANT?

# currently trying direct links only, EXCEPT transitive over snomed
# then expand over ICD subclasses to be uniform with snomed transitivity
# then OPTIONALLY expand over MonDO subclasses, with axiom filter? in real time?

# should mondo "originals" be expanded to also include ?s owl:equivalentClass ?restriction (blank node)?
# should evidence be materialized directly only, and only dynamically over mondo subclasses?
#   would enable better axiomatic filtering

# select distinct ?g ?p
# where {
#   ?s  <http://example.com/resource/definedIn> <http://purl.obolibrary.org/obo/mondo.owl> .
#   graph ?g {
#     ?s ?p ?o .
#   }
#   filter (isblank(?o))
# }
#
# g	p
# mydata:filteredMondoTransitiveSubClasses 	rdfs:subClassOf
# obo:mondo.owl 	rdfs:subClassOf
# obo:mondo.owl 	owl:equivalentClass
# obo:mondo.owl 	owl:intersectionOf
# obo:mondo.owl 	owl:unionOf


# phase 1, organized topically not sequentially
# "materialize UMLS CUIs"
# "defined in"

# rewrites: "rewrite ?p mondo", "mondo ?p rewrite", "mondo dbxr literal"

# isolate (move to another graph) and delete from original graph:
#  "undefined mondo ?p rewrites", "undefined rewrite ?p mondo",
#  "?mondo ?p icd9 ranges", "?icd9 ranges ?p mondo"
#  "ICD10 siblings", "ICD9 siblings"

# *** "isolate mondo original statements"
# where {
#   graph <http://purl.obolibrary.org/obo/mondo.owl> {
#     values ?p {
#       skos:exactMatch
#       skos:closeMatch
#       # skos:narrowMatch
#       owl:equivalentClass
#     }
#     ?s ?p ?o
#     filter(isuri(?o))
#   }
# }
# "someMaterializedMondoAxioms"
# turned filter off!
# "filteredMondoTransitiveSubClasses"

# "NLM ICD9CM to SNOMED mapping... tag booleans"
# "ints to to bool", "delete ints", "migrate bools", "clear temp"

# "materialize ICD9CM to snomed mappings"

# "ICD9DiseaseInjuryTransitiveSubClasses"
# "ICD10TransitiveSubClasses"
# "SnomedDiseaseTransitiveSubClasses"

###   ###   ###

update.list <- list(
  "materialize UMLS CUIs" = '
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
            ("http://identifiers.org/snomedct/" "http://purl.bioontology.org/ontology/SNOMEDCT_US/")
            ("http://purl.obolibrary.org/obo/SCTID_" "http://purl.bioontology.org/ontology/SNOMEDCT_US/")
            ("http://purl.obolibrary.org/obo/ICD10_" "http://purl.bioontology.org/ontology/ICD10CM/")
            ("http://purl.obolibrary.org/obo/ICD9_" "http://purl.bioontology.org/ontology/ICD9CM/")
        }
        ?external  ?p ?mondo .
        filter(strstarts(str(?external),?mondoPattern))
        filter(strstarts(str(?mondo),"http://purl.obolibrary.org/obo/MONDO_"))
        bind(uri(concat(?rewritePattern,strafter(str(?external),?mondoPattern))) as ?rewrite)
    }
}
',
"mondo ?p rewrite" = '
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
            ("http://identifiers.org/snomedct/" "http://purl.bioontology.org/ontology/SNOMEDCT_US/")
            ("http://purl.obolibrary.org/obo/SCTID_" "http://purl.bioontology.org/ontology/SNOMEDCT_US/")
            ("http://purl.obolibrary.org/obo/ICD10_" "http://purl.bioontology.org/ontology/ICD10CM/")
            ("http://purl.obolibrary.org/obo/ICD9_" "http://purl.bioontology.org/ontology/ICD9CM/")
        }
        ?mondo ?p ?external .
        filter(strstarts(str(?external),?mondoPattern))
        filter(strstarts(str(?mondo),"http://purl.obolibrary.org/obo/MONDO_"))
        bind(uri(concat(?rewritePattern,strafter(str(?external),?mondoPattern))) as ?rewrite)
    }
}
',
"mondo dbxr literal" = '
insert {
    graph <http://example.com/resource/rewrites_MonDO_subject> {
        ?mondo mydata:mdbxr ?rewrite
    }
}
where {
    graph <http://purl.obolibrary.org/obo/mondo.owl> {
        values (?mondoPattern ?rewritePattern) {
            ("UMLS:" "http://example.com/cui/")
            ("SCTID:" "http://purl.bioontology.org/ontology/SNOMEDCT_US/")
            ("ICD10:" "http://purl.bioontology.org/ontology/ICD10CM/")
            ("ICD9:" "http://purl.bioontology.org/ontology/ICD9CM/")
        }
        ?mondo <http://www.geneontology.org/formats/oboInOwl#hasDbXref> ?external .
        filter(strstarts(?external,?mondoPattern))
        filter(strstarts(str(?mondo),"http://purl.obolibrary.org/obo/MONDO_"))
        bind(uri(concat(?rewritePattern,strafter(str(?external),?mondoPattern))) as ?rewrite)
    }
}
',
"isolate undefined mondo rewrites" = '
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
',
"delete undefined reverse rewrites from mondo" = '
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
',
"delete undefined forward rewrites from mondo" = '
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
',
"isolate ?mondo ?p icd9 ranges" = '
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
',
"delete forward icd9 ranges" = '
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
',"delete reverse icd9 ranges" = '
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
',
# leaves behind equivalent-to-restriction/blank node statements
"isolate mondo rewritable external-link statements" = '
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
"delete mondo original statements from mondo" = 'delete {
    graph <http://purl.obolibrary.org/obo/mondo.owl> {
        ?s ?p ?o
    }
}
where {
    graph <http://example.com/resource/mondoOriginals> {
        ?s ?p ?o
    }
}',
"NLM ICD9CM to SNOMED mapping... tag predicates taking booleans" =
  'insert data {
    graph <https://www.nlm.nih.gov/research/umls/mapping_projects/icd9cm_to_snomedct.html> {
        mydata:IS_CURRENT_ICD mydata:intPlaceholder true .
        mydata:IS_NEC mydata:intPlaceholder true .
        mydata:IS_1-1MAP mydata:intPlaceholder true .
        mydata:IN_CORE mydata:intPlaceholder true .
        <https://www.nlm.nih.gov/research/umls/mapping_projects/icd9cm_to_snomedct.html> rdfs:comment "NLM ICD9CM to SNOMED mapping, with predicates taking booleans tagged" .
    }
}',

"ints to to bool"=
  'insert {
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
}',
"delete ints" =
  'delete {
    ?s ?p ?int .
} where {
    graph <https://www.nlm.nih.gov/research/umls/mapping_projects/icd9cm_to_snomedct.html> {
        ?p mydata:intPlaceholder true .
        ?s ?p ?int .
        filter(datatype(?int)!=xsd:boolean)
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

"materialize ICD9CM to snomed mappings" =
  'insert {
    graph <https://www.nlm.nih.gov/research/umls/mapping_projects/icd9cm_to_snomedct.html> {
        ?icd <https://www.nlm.nih.gov/research/umls/mapping_projects/icd9cm_to_snomedct.html> ?snomed
    }
} where {
    graph <https://www.nlm.nih.gov/research/umls/mapping_projects/icd9cm_to_snomedct.html> {
        ?s mydata:ICD_CODE	?ICD_CODE	;
           mydata:SNOMED_CID ?SNOMED_CID .
        bind(uri(concat("http://purl.bioontology.org/ontology/SNOMEDCT_US/", ?SNOMED_CID)) as ?snomed)
        bind(uri(concat("http://purl.bioontology.org/ontology/ICD9CM/", ?ICD_CODE)) as ?icd)
    }
    graph <http://purl.bioontology.org/ontology/SNOMEDCT_US/> {
        ?snomed a owl:Class
    }
    graph <http://purl.bioontology.org/ontology/ICD9CM/> {
        ?icd a owl:Class
    }
}'
,

"isolation of ICD10 siblings" =
  'insert  {
    graph <http://example.com/resource/ICD10CM_siblings> {
        ?s <http://purl.bioontology.org/ontology/ICD10CM/SIB> ?o
    }
}
where {
    graph <http://purl.bioontology.org/ontology/ICD10CM/> {
        ?s <http://purl.bioontology.org/ontology/ICD10CM/SIB> ?o
    }
}',
"deletion of ICD10 siblings" =
  'delete  {
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
"isolation of ICD9 siblings" =
  'insert  {
    graph <http://example.com/resource/ICD9CM_siblings> {
        ?s <http://purl.bioontology.org/ontology/ICD9CM/SIB> ?o
    }
}
where {
    graph <http://purl.bioontology.org/ontology/ICD9CM/> {
        ?s <http://purl.bioontology.org/ontology/ICD9CM/SIB> ?o
    }
}',
"deletion of ICD9 siblings" =
  'delete  {
    graph <http://purl.bioontology.org/ontology/ICD9CM/> {
        ?s <http://purl.bioontology.org/ontology/ICD9CM/SIB> ?o
    }
}
where {
    graph <http://purl.bioontology.org/ontology/ICD9CM/> {
        ?s <http://purl.bioontology.org/ontology/ICD9CM/SIB> ?o
    }
}',
"defined in" =
  'insert {
    graph <http://example.com/resource/definedIn> {
        ?s <http://example.com/resource/definedIn> ?g
    }
} where {
    graph ?g {
        ?s a owl:Class
    }
}',
# does this miss equivalentCLass axioms and more complex subClassOf axioms (ie with intersections)?
"someMaterializedMondoAxioms" = 'insert {
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
#limit 99',
"ICD9DiseaseInjuryTransitiveSubClasses" = 'insert {
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
"ICD10TransitiveSubClasses" = 'insert {
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
"SnomedDiseaseTransitiveSubClasses" = 'insert {
    graph mydata:SnomedDiseaseTransitiveSubClasses {
      ?sub rdfs:subClassOf ?s .
    }
  }
where {
  graph <http://purl.bioontology.org/ontology/SNOMEDCT_US/> {
    # + or * ?
    ?s rdfs:subClassOf* <http://purl.bioontology.org/ontology/SNOMEDCT_US/64572001> .
    ?sub rdfs:subClassOf* ?s .
  }
}'
,
"MondoTransitiveSubClasses" = 'insert {
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
}'
)

update.names <- names(update.list)

# rewrite statements with consistent orientation
#   and with URIs matching linked knowledgebases
# also transitive materialization over knowledgebases (prior to path materializastion)

update.outer.result <-
  lapply(update.names, function(current.name) {
    current.update <- update.list[[current.name]]
    print(current.name)
    current.update <- paste0(sparql.prefixes, current.update, "\n")
    if (debug.flag) {
      cat(current.update)
    } else {
      print(Sys.time())
      post.res <- POST(update.endpoint,
                       body = list(update = current.update),
                       saved.authentication)
      print(post.res$times[['total']])
    }
  })


if (delete.isolated.flag) {
  post.res <- POST(
    update.endpoint,
    body = list(update = "clear graph <http://example.com/resource/ICD10CM_siblings>"),
    saved.authentication
  )
  
  
  post.res <- POST(
    update.endpoint,
    body = list(update = "clear graph <http://example.com/resource/ICD9CM_siblings>"),
    saved.authentication
  )
  
  post.res <- POST(
    update.endpoint,
    body = list(update = "clear graph <http://example.com/resource/icd9range>"),
    saved.authentication
  )
  
  post.res <- POST(
    update.endpoint,
    body = list(update = "clear graph <http://example.com/resource/mondoOriginals>"),
    saved.authentication
  )
  
  post.res <- POST(
    update.endpoint,
    body = list(update = "clear graph <http://example.com/resource/undefinedRewrites>"),
    saved.authentication
  )
}


# deletion justifications:
# siblings (predicate = http://purl.bioontology.org/ontology/ICD10CM/SIB) are accessible as children of the same
#   parent class and just make visualizations to busy
# we have decided not to pursue the ~ 30 MonDO database cross-references (http://example.com/resource/mdbxr)
#   to ICD ranges like obo:MONDO_0005002 mydata:mdbxr http://purl.bioontology.org/ontology/ICD9CM/490-496.99
#   implies asthma is a kind of COPD
# "mondo originals" includes these pre-re-written relations... don't want to retain them, just the rewrites
#             skos:exactMatch
#             skos:closeMatch
#             # skos:narrowMatch
#             owl:equivalentClass
# undefinedRewrites contains mentions of terms that are not asserted in some source ontology.
#   it could be a CUI that just isn't present in ICD-X or snomed
#   http://example.com/cui/C0001139 owl:equivalentClass obo:MONDO_0006635
#   where the contexts for C0001139 are medra and mesh and ndfrt
#   obo:MONDO_0037872 owl:equivalentClass http://purl.bioontology.org/ontology/SNOMEDCT_US/26484003 (26484003 is retired)
#   or it could be a mangled ICD code
#   obo:MONDO_0006015 mydata:mdbxr http://purl.bioontology.org/ontology/ICD10CM/A39.1+


# https://www.verywellhealth.com/icd-10-codes-and-how-do-they-work-1738471
# # The first 3 characters define the category of the disease, disorder, infection or symptom.
# For example, codes starting with M00-M99 are for diseases of the musculoskeletal system and connective tissue
# (like rheumatoid arthritis), while codes starting with J00-J99 are for diseases of the respiratory system.
# # Characters in positions 4-6 define the body site, severity of the problem, cause of the injury or disease,
# and other clinical details. In the rheumatoid arthritis example above, the fifth character defines the body site
# and the sixth character defines whether it’s the left or right side. A three in the fifth character position denotes
# it’s a wrist that’s affected. A two in the sixth character position denotes it’s the left side of the body that’s affected.
# # Character 7 is an extension character used for varied purposes such as defining whether this is the initial encounter
# for this problem, a subsequent encounter, or sequela arising as a result of another condition.


###   ###   ###
