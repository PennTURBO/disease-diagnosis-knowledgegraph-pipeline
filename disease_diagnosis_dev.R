library(igraph)
library(httr)

library(config)
library(jsonlite)
# called explicitly to avoid confusion with get methods from other libraries

library(SPARQL)
# some interactions with the triplestore, esp. select queries, seem more convenient via the SPARQL library
# others, like updates, seem more convenient with lower level GETs/PUTs from httr or RCurl
# see also notes about rrdf above
# SPARQL imports at least RCurl

###   ###   ###

# the work of this script is mostly normalization of datatype properties in order to
# expose knowledge about the relationship between MonDO disease classes and ICD codes, even if it requires
# traversing other knowledge graphs

# a separate step is materializing those paths into individual triples,
#  or at least patterns with a finite length

# after that, one can calculate the information content of each ICD->MonDO mapping. 
# presumably, one would only want the deepest, most specific (informative) mappings

# SNOMEDCT or SNOMEDCT_US?
# UMLS calls the source "SNOMEDCT_US"
# BioPortal builds their uris like http://purl.bioontology.org/ontology/SNOMEDCT/123037004

# continue re-factoring SPARQL prefixes

###

# maybe...
# materialize all of the paths and then flatten for Hayden
# filter out rare diseases, syndromes or congenital conditions from MonDO
# haven't put SNOMEDCT filtering into production yet
# cancer maps to lots of false positives?
# materialize SNOMEDCT's icd10 text mappings? they might just be the same as shared CUIs?

###

# start by loading
# icd9  from BioPortal
# icd10 from BioPortal
# MonDO from http://purl.obolibrary.org/obo/mondo.owl into http://purl.obolibrary.org/obo/mondo.owl
#   may have to be staged as a file? GraphDB complains about loading some RDF files from web URLs
#   OK, just check the redirection path for the obo library URL and state that its RDF/XML formatted?
# snomed from the ums2rdf pipeline into http://purl.bioontology.org/ontology/SNOMEDCT/
# direct mapping triples from
#   https://download.nlm.nih.gov/umls/kss/mappings/ICD9CM_TO_SNOMEDCT/ICD9CM_TO_SNOMEDCT_DIAGNOSIS_201812.zip
#   see ICD9CM_SNOMED_MAP-to-RDF.R

# BioPortal has ICDs (including ICDO!)
#   http://bioportal.bioontology.org/ontologies/ICD-O-3-M
#   http://bioportal.bioontology.org/ontologies/ICD-O-3-T
# but may be a few months behind the UMLS may/November releases ?
#   http://bioportal.bioontology.org/ontologies/ICD10CM
# there's no public snomed RDF release at this point
# they're working on one, and currently provide a Perl script
# https://confluence.ihtsdotools.org/display/DOCTSG/9.2.6+SNOMED+CT+OWL+Distribution+FAQ

# version predicates:
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

args  <-  commandArgs(trailingOnly = TRUE)

potential.config.file <- args[1]
if (file.exists(potential.config.file)) {
  # if run from command line with Rscript like
  # `Rscript <script path>/disease_diagnosis_dev.R <config file path>
  # and <config file path> exists
  # VALIDITY OF FILE IS NOT CHECKED
  actual.config.file <- potential.config.file
  print(paste0("Using config file ", actual.config.file))
} else {
  # current working directory
  actual.config.file <- "disease_diagnosis.yaml"
  print(paste0(
    "Using default config file ",
    actual.config.file,
    " from current directory"
  ))
}

config.bootstrap <-
  config::get(file = actual.config.file)

selected.gdb.configuration <-
  config::get(config = config.bootstrap$selected.gdb.configuration,
              file = actual.config.file)

monitor.pause.seconds <- config.bootstrap$monitor.pause.seconds
snomed.triples.file <-
  selected.gdb.configuration$snomed.triples.file
icd9_to_snomed.triples.file <-
  selected.gdb.configuration$icd9_to_snomed.triples.file

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
    
    # THE DIFFERENT JSON LIBRARIES RETURN THE CONTENTS IN DIFFERENT FORMATS
    #   SOME OF WHICH MAY BE MORE CONVENIENT THAN OTHERS
    
    context.report <-
      jsonlite::fromJSON(rawToChar(context.report$content))
    
    # this will be a vector
    context.report <-
      context.report$results$bindings$contextID$value
    
    print(paste0(
      "Currently ",
      Sys.time(),
      ". Last import submitted at ",
      last.post.time
    ))
    
    # print(paste0("Expecting graphs ", expectation, collapse = " ; "))
    # print(paste0("Current graphs ", context.report, collapse = " ; "))
    
    pending.graphs <- sort(setdiff(expectation, context.report))
    
    # printing pending graphs only masks the possibiity that there are undesired graphs in the repo
    # print(paste0("Expected graphs: ", sort(expectation)))
    # print(paste0("Current graphs:  ", sort(context.report)))
    
    print(paste0("Pending graphs:  ", sort(pending.graphs)))
    
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

# CLEAR REPO

last.post.time <- Sys.time()

# post.res <- POST(update.endpoint,
#                  body = list(update = "clear all"),
#                  saved.authentication)
#
# # empty for sparql statement
# last.post.status <- rawToChar(post.res$content)

# or just do it as a sparql update

last.post.status <- ''

update.statement <- "clear all"

sparql.result <-
  SPARQL(
    url =  update.endpoint,
    update = update.statement,
    curl_args = list(.opts = curlOptions(
      userpwd = paste0(api.user, ":", api.pass),
      httpauth = 1L
    ))
  )
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
# # DOCUMENTATION  = https://github.com/PennTURBO/disease_to_diagnosis_code/blob/master/SNOMED_RDF_generation.md

update.body <- paste0(
  '{
  "fileNames": ["',
  snomed.triples.file,
  '"],
  "importSettings": { "context": "http://purl.bioontology.org/ontology/SNOMEDCT/" }
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
    "http://purl.bioontology.org/ontology/SNOMEDCT/",
    "http://purl.bioontology.org/ontology/STY/",
    "https://www.nlm.nih.gov/research/umls/mapping_projects/icd9cm_to_snomedct.html"
  )

monitor.named.graphs()

# ~ 5 minutes

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
  ("http://identifiers.org/snomedct/" "http://purl.bioontology.org/ontology/SNOMEDCT/")
  ("http://purl.obolibrary.org/obo/SCTID_" "http://purl.bioontology.org/ontology/SNOMEDCT/")
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
  ("http://identifiers.org/snomedct/" "http://purl.bioontology.org/ontology/SNOMEDCT/")
  ("http://purl.obolibrary.org/obo/SCTID_" "http://purl.bioontology.org/ontology/SNOMEDCT/")
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
  ("SCTID:" "http://purl.bioontology.org/ontology/SNOMEDCT/")
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
### UNNECESSARY with new direct mapping by ICD9CM_SNOMED_MAP-to-RDF.R
# "NLM ICD9CM to SNOMED mapping... tag predicates taking booleans" =
#   'insert data {
#     graph <https://www.nlm.nih.gov/research/umls/mapping_projects/icd9cm_to_snomedct.html> {
#         mydata:IS_CURRENT_ICD mydata:intPlaceholder true .
#         mydata:IS_NEC mydata:intPlaceholder true .
#         mydata:IS_1-1MAP mydata:intPlaceholder true .
#         mydata:IN_CORE mydata:intPlaceholder true .
#         <https://www.nlm.nih.gov/research/umls/mapping_projects/icd9cm_to_snomedct.html> rdfs:comment "NLM ICD9CM to SNOMED mapping, with predicates taking booleans tagged" .
#     }
# }',
#
# "ints to to bool"=
#   'insert {
#     graph <https://www.nlm.nih.gov/research/umls/mapping_projects/icd9cm_to_snomedct.html_boolean> {
#         ?s ?p ?boolean
#     }
# } where {
#     graph <https://www.nlm.nih.gov/research/umls/mapping_projects/icd9cm_to_snomedct.html> {
#         ?p mydata:intPlaceholder true .
#         ?s ?p ?int .
#         filter(datatype(?int)!=xsd:boolean)
#         bind(if(?int = "1", true, false) as ?boolean)
#     }
# }',
# "delete ints" =
#   'delete {
#     ?s ?p ?int .
# } where {
#     graph <https://www.nlm.nih.gov/research/umls/mapping_projects/icd9cm_to_snomedct.html> {
#         ?p mydata:intPlaceholder true .
#         ?s ?p ?int .
#         filter(datatype(?int)!=xsd:boolean)
#     }
# }',
# "migrate bools" = 'insert {
#     graph <https://www.nlm.nih.gov/research/umls/mapping_projects/icd9cm_to_snomedct.html> {
#         ?s ?p ?boolean
#     }
# }
# where {
#     graph <https://www.nlm.nih.gov/research/umls/mapping_projects/icd9cm_to_snomedct.html_boolean> {
#         ?s ?p ?boolean
#     }
# }',
# "clear temp" = 'clear graph <https://www.nlm.nih.gov/research/umls/mapping_projects/icd9cm_to_snomedct.html_boolean>',

"materialize ICD9CM to snomed mappings" =
  'insert {
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
"materializedVerySimpleMondoEquivalenceAxioms" = '
insert {
graph <http://example.com/resource/materializedVerySimpleMondoEquivalenceAxioms> {
?d ?onProp ?valSource .
}
}
where {
graph <http://purl.obolibrary.org/obo/mondo.owl> {
?d owl:equivalentClass ?eqc .
?eqc a owl:Class .
?eqc owl:intersectionOf ?intersection .
?intersection (owl:intersectionOf|rdf:first|rdf:rest)* ?restriction .
?restriction a owl:Restriction ;
owl:onProperty ?onProp ;
owl:someValuesFrom ?valSource .
#        # rdf:nil
}
}
#rdf:type 7336
#owl:intersectionOf 77325
#owl:unionOf 11',
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
graph <http://purl.bioontology.org/ontology/SNOMEDCT/> {
# + or * ?
?s rdfs:subClassOf* <http://purl.bioontology.org/ontology/SNOMEDCT/64572001> .
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
}',
'MondoTransitiveSimpleScoEqcAxioms' = '
insert {
graph <http://example.com/resource/MondoTransitiveSimpleScoEqcAxioms> {
?s ?p ?o
}
}
where {
graph <http://example.com/resource/MondoTransitiveSubClasses> {
?s rdfs:subClassOf ?restrictionSubject
}
{
  {
  graph <http://example.com/resource/materializedSimpleMondoAxioms> {
  ?restrictionSubject ?p ?o
  }
  }
  union
  {
  graph <http://example.com/resource/materializedVerySimpleMondoEquivalenceAxioms> {
  ?restrictionSubject ?p ?o
  }
  }
}
#    filter( ?restrictionSubject != ?inferee )
}
#limit 100
# contaminated with statements like rdfs:subClassOf rdfs:subClassOf rdfs:subClassOf',
'forward reverse graph names' = '
insert data {
graph mydata:AssertionOrientations {
mydata:rewrites_MonDO_object rdfs:label "reverse" .
mydata:rewrites_MonDO_subject rdfs:label "forward" .
}
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

# ~ 5 minutes

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
#   obo:MONDO_0037872 owl:equivalentClass http://purl.bioontology.org/ontology/SNOMEDCT/26484003 (26484003 is retired)
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

# determine depth of each MonDO disease
#   in other words, subClassOf hops from the disease root

my.query <- '
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX obo: <http://purl.obolibrary.org/obo/>
prefix mydata: <http://example.com/resource/>
PREFIX oboInOwl: <http://www.geneontology.org/formats/oboInOwl#>
select ?sid ?oid where {
graph <http://purl.obolibrary.org/obo/mondo.owl> {
?s rdfs:subClassOf ?o .
}
graph obo:mondo.owl {
?s oboInOwl:id ?sid .
?o oboInOwl:id ?oid .
}
}'


result.list <-
  SPARQL(
    url = select.endpoint ,
    query = my.query ,
    curl_args = list(
      userpwd = paste0(api.user, ":", api.pass),
      httpauth = 1
      # 'Accept-Encoding' = 'gzip, deflate'
    )
  )

result.frame <- result.list$results

mrg <- graph_from_data_frame(result.frame)

mrg.dists <- t(shortest.paths(graph = mrg, v = "MONDO:0000001"))
mrg.dists <- as.data.frame(mrg.dists)
mrg.dists$MonDO.term <- rownames(mrg.dists)
mrg.dists <- mrg.dists[is.finite(mrg.dists$`MONDO:0000001`), ]

mrg.dists <- mrg.dists[order(mrg.dists$MonDO.term),]

mrg.dists$disease.uri <-
  sub(pattern = "^MONDO:",
      replacement = "obo:MONDO_",
      x = mrg.dists$MonDO.term)

mrg.dists$mrg.composed <-
  paste0(mrg.dists$disease.uri,
         " mydata:diseaseDepth ",
         mrg.dists$`MONDO:0000001`,
         " . ")

chunk.size <- 100
composed.chunks <-
  split(mrg.dists$mrg.composed, ceiling(seq_along(mrg.dists$mrg.composed) /
                                          chunk.size))

chunked.template <- '
PREFIX obo: <http://purl.obolibrary.org/obo/>
PREFIX mydata: <http://example.com/resource/>
insert data {
graph mydata:diseaseDepth {
${payload}
}
}'

placeholder <- lapply(composed.chunks, function(current.chunk) {
  payload <- paste0(current.chunk, collapse = " ")
  
  interpreted <- stringr::str_interp(chunked.template)
  
  post.res <- POST(update.endpoint,
                   body = list(update = interpreted),
                   saved.authentication)
  
})

###   ###   ###

# # compare named graphs used by different iterations of this disease-diagnossi effort
# 
# my.query <- '
# select distinct (str(?g) as ?V1)
# where {
# graph ?g {
# ?s ?p ?o }}'
# 
# 
# result.list <-
#   SPARQL(
#     url = select.endpoint ,
#     query = my.query ,
#     curl_args = list(
#       userpwd = paste0(api.user, ":", api.pass),
#       httpauth = 1
#       # 'Accept-Encoding' = 'gzip, deflate'
#     )
#   )
# 
# disease_diagnosis_dev <- t(result.list$results)
# 
# toread <- "
# http://example.com/resource/AssertionOrientations
# http://example.com/resource/ICD10TransitiveSubClasses
# http://example.com/resource/ICD9DiseaseInjuryTransitiveSubClasses
# http://example.com/resource/MondoTransitiveSimpleScoEqcAxioms
# http://example.com/resource/MondoTransitiveSubClasses
# http://example.com/resource/SnomedDiseaseTransitiveSubClasses
# http://example.com/resource/definedIn
# http://example.com/resource/diseaseDepth
# http://example.com/resource/icd9range
# http://example.com/resource/materializedCui
# http://example.com/resource/materializedSimpleMondoAxioms
# http://example.com/resource/materializedVerySimpleMondoEquivalenceAxioms
# http://example.com/resource/rewrites_MonDO_object
# http://example.com/resource/rewrites_MonDO_subject
# http://purl.bioontology.org/ontology/ICD10CM/
# http://purl.bioontology.org/ontology/ICD9CM/
# http://purl.bioontology.org/ontology/SNOMEDCT/
# http://purl.bioontology.org/ontology/STY/
# http://purl.obolibrary.org/obo/mondo.owl
# http://www.itmat.upenn.edu/biobank/cached_mondo_icd_mappings
# http://www.itmat.upenn.edu/biobank/cached_mondo_icd_mappings_LEAFONLY
# http://www.itmat.upenn.edu/biobank/cached_mondo_icd_mappings_depthTimesMappingCountFormulaOnly
# http://www.itmat.upenn.edu/biobank/countIcdMappingsPerMondoTerm
# https://www.nlm.nih.gov/research/umls/mapping_projects/icd9cm_to_snomedct.html"
# 
# Diagnosis_KnowledgeGraph  <-
#   read.table(textConnection(toread), FALSE, stringsAsFactors = FALSE)
# closeAllConnections()
# 
# disease_diagnosis_dev_only <-
#   setdiff(disease_diagnosis_dev[, 1], Diagnosis_KnowledgeGraph$V1)
# 
# Diagnosis_KnowledgeGraph_only <-
#   setdiff(Diagnosis_KnowledgeGraph$V1, disease_diagnosis_dev[, 1])
# 
# # these were retained so that the transformations in this script wouldn't be completely destructive
# # it's ok that they don't appear in the production disease diagnosis graph
# print(disease_diagnosis_dev_only)
# 
# # these are created by Hayden's scripts
# print(Diagnosis_KnowledgeGraph_only)
