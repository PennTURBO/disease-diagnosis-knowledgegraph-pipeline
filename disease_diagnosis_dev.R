library(SPARQL)
library(httr)
library(jsonlite)
library(httr)
library(config)
# could have used: jsonlite? rjsonio? rjson?

# switch to yaml config
# function for repeated tasks (like "named graph expectation")
# what's an example of scripts that do use yaml and named graph monitoring fuction?
#   tweencorn on http://pennturbo.org:8787/?

# see also populate_disease_to_diagnosis_code_repo.R

###

# TODO: some repetitive posting and monitoring code?... re-factor into functions
# also could  re-factor SPARQL prefixes

# maybe
# materialize all of the paths and then flatten for Hayden
# don't peruse syndromes or congenital conditions from mondo (ok, at least reporting) SNOMEDCT (no action)
# cancer maps to lots of false positives?
# apply over query labels, not the queries themselves?
# materialize SNOMEDCT icd10 text mappings? might they just be the same as shared CUIs?

###


# start by loading
# snomed from the ums2rdf pipeline into http://purl.bioontology.org/ontology/SNOMEDCT/
# icd9 from the ums2rdf pipeline into http://purl.bioontology.org/ontology/ICD9CM/
# icd10 from the ums2rdf pipeline into 	http://purl.bioontology.org/ontology/ICD10CM/
# mondo from http://purl.obolibrary.org/obo/mondo.owl into http://purl.obolibrary.org/obo/mondo.owl
#  my have to be staged as a file... GraphDB complains about loading some RDF files from web URLs
# OK, just check the redirection path for the obolibrary URL and state that its RDF/XML formatted

# ontorefine source:
# https://download.nlm.nih.gov/umls/kss/mappings/ICD9CM_TO_SNOMEDCT/ICD9CM_TO_SNOMEDCT_DIAGNOSIS_201812.zip
# but has also been saved as two projects that can be directly imported into graphdb servers
# maybe that should just be saved as a RDF file on the server
#  www.nlm.nih.gov-research-umls_mapping_projects-icd9cm_to_snomedct.html.brf.zip

# ICD9CM_SNOMED_MAP_1TO1_201812 1912899822059
# ICD9CM_SNOMED_MAP_1TOM_201812 2239824072298

###

monitor.pause.seconds <- 10

selected.gdb.configuration <- "pennturbo_lightsail_remote"

gdb.config <-
  config::get(config = selected.gdb.configuration, file = "disease_diagnosis.yaml")

graphdb.address.port <- gdb.config$graphdb.address.port
selected.repo <- gdb.config$selected.repo
api.user <- gdb.config$api.user
api.pass <- gdb.config$api.pass

saved.authentication <-
  authenticate(api.user, api.pass, type = "basic")

sparql.prefixes <- "
PREFIX obo: <http://purl.obolibrary.org/obo/>
PREFIX ontologies: <http://transformunify.org/ontologies/>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX sm: <tag:stardog:api:mapping:>
PREFIX turbo: <http://transformunify.org/ontologies/>
PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
"

update.endpoint <-
  paste0(graphdb.address.port,
         "/repositories/",
         selected.repo,
         "/statements")

select.endpoint <-
  paste0(graphdb.address.port, "/repositories/", selected.repo)

post.endpoint <-
  paste0(graphdb.address.port,
         "/rest/data/import/upload/",
         selected.repo,
         "/url")

### THIS SHOULDN'T DEPEND ON THE ORDER IN WHICH THE GRAPHS ARE REPORTED
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
    
    # SHUOLD THESE BE LEFT AS GLOBALS OR BE SWTICHED TO FUNCTION PARAMETERS?
    print(paste0(Sys.time(),
                 ": '",
                 post.status,
                 "' submitted at ",
                 post.time))
    # print(paste0("Expecting graphs ", expectation, collapse = " ; "))
    # print(paste0("Current graphs ", context.report, collapse = " ; "))
    
    print(paste0("Expecting graphs ", expectation))
    print(paste0("Current graphs ", context.report))
    
    print(paste0("Next check in ",
                 monitor.pause.seconds,
                 " seconds."))
    
    Sys.sleep(10)
    moveon <- setdiff(expectation, context.report)
    # will this properly handle the case when the report is mepty (NULL)?
    if (length(moveon) == 0) {
      print("Update complete")
      break()
    }
  }
}
###   ###   ###

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

post.time <- Sys.time()

# post.res <- POST(update.endpoint,
#                  body = list(update = "clear all"),
#                  saved.authentication)
#
# # empty for sparql statement
# post.status <- rawToChar(post.res$content)


# or just do it as a sparql update... some numerical trick for the encryption type?

# Warning message:
#   In testCurlOptionsInFormParameters(.params) :
#   Found possible curl options in form parameters: userpwd, httpauth

post.status <- update.statement <- "clear all"

sparql.result <-
  SPARQL(
    url =  update.endpoint,
    update = update.statement,
    curl_args = list(
      userpwd = paste0(api.user, ":", api.pass),
      httpauth = 1
    )
  )


# test by loading
# https://raw.githubusercontent.com/PennTURBO/Turbo-Ontology/master/ontologies/turbo_merged.owl
# see also https://wheregoes.com/retracer.php
# don't forget to assert type as
# RDF/XML

expectation <- NULL

monitor.named.graphs()

### MONDO

update.body <- '{
  "context": "http://purl.obolibrary.org/obo/mondo.owl",
  "data": "https://github.com/monarch-initiative/mondo/releases/download/current/mondo.owl",
  "format": "RDF/XML"
}'

placeholder <- POST(
  # post.dest,
  # body = bod4post,
  post.endpoint,
  body = update.body,
  content_type("application/json"),
  accept("application/json"),
  saved.authentication
)


# status.ph <- rawToChar(placeholder$content)
# submission.time <- Sys.time()
post.status <- rawToChar(placeholder$content)
post.time <- Sys.time()

### ICD9CM

update.body <- '{
  "type":"url",
  "format":"text/turtle",
  "context": "http://purl.bioontology.org/ontology/ICD9CM/",
  "data": "http://data.bioontology.org/ontologies/ICD9CM/submissions/17/download?apikey=9cf735c3-a44a-404f-8b2f-c49d48b2b8b2"
}'

placeholder <- POST(
  # post.dest,
  # body = bod4post,
  post.endpoint,
  body = update.body,
  content_type("application/json"),
  accept("application/json"),
  saved.authentication
)


# status.ph <- rawToChar(placeholder$content)
# submission.time <- Sys.time()
post.status <- rawToChar(placeholder$content)
post.time <- Sys.time()

### ICD10CM


update.body <- '{
  "type":"url",
  "format":"text/turtle",
  "context": "http://purl.bioontology.org/ontology/ICD10CM/",
  "data": "http://data.bioontology.org/ontologies/ICD10CM/submissions/17/download?apikey=8b5b7825-538d-40e0-9e9e-5ab9274a9aeb"
}'

placeholder <- POST(
  # post.dest,
  # body = bod4post,
  post.endpoint,
  body = update.body,
  content_type("application/json"),
  accept("application/json"),
  saved.authentication
)


# status.ph <- rawToChar(placeholder$content)
# submission.time <- Sys.time()
post.status <- rawToChar(placeholder$content)
post.time <- Sys.time()

expectation <-
  c(
    "http://purl.obolibrary.org/obo/mondo.owl",
    "http://purl.bioontology.org/ontology/ICD9CM/",
    "http://purl.bioontology.org/ontology/ICD10CM/"
  )

monitor.named.graphs()

###

# ###
#
#
# # bp_api:
# #   api_key: '9cf735c3-a44a-404f-8b2f-c49d48b2b8b2'
#
# # advertised
# # http://data.bioontology.org/ontologies/ICD9CM/submissions/17/download?apikey=8b5b7825-538d-40e0-9e9e-5ab9274a9aeb
#
# # customized
# # http://data.bioontology.org/ontologies/ICD9CM/submissions/17/download?apikey=9cf735c3-a44a-404f-8b2f-c49d48b2b8b2
#
# expectation <-
#   list(head = list(vars = "contextID"),
#        results = list(bindings = list(
#          list(
#            contextID = list(type = "uri", value = "http://purl.obolibrary.org/obo/mondo.owl")
#          ),
#          list(
#            contextID = list(type = "uri", value = "http://purl.bioontology.org/ontology/ICD10CM/")
#          ),
#          list(
#            contextID = list(type = "uri", value = "http://purl.bioontology.org/ontology/ICD9CM/")
#          ),
#          list(
#            contextID = list(type = "uri", value = "http://purl.bioontology.org/ontology/SNOMEDCT/")
#          )
#        )))
#
#
#
# ###
#
# # the version in embedded in teh URL, so this should become a configuration parameter
# update.body <- '{
#   "context": "http://purl.bioontology.org/ontology/ICD9CM/",
#   "data": "http://data.bioontology.org/ontologies/ICD9CM/submissions/17/download?apikey=9cf735c3-a44a-404f-8b2f-c49d48b2b8b2",
#   "format": "Turtle"
# }'
#
#
# update.body <- '{
#   "context": "http://purl.bioontology.org/ontology/ICD9CM/",
#   "data": "https://raw.githubusercontent.com/PennTURBO/Turbo-Ontology/master/ontologies/turbo_merged.owl",
#   "format": "RDF/XML"
# }'
#
# update.body <- '{
#   "context": "http://purl.obolibrary.org/obo/mondo.owl",
#   "data": "https://github.com/monarch-initiative/mondo/releases/download/current/mondo.owl",
#   "format": "RDF/XML"
# }'
#
#
# update.body <- '{
#   "context": "https://raw.githubusercontent.com/PennTURBO/Turbo-Ontology/master/ontologies/turbo_merged.owl",
#   "data": "https://raw.githubusercontent.com/PennTURBO/Turbo-Ontology/master/ontologies/turbo_merged.owl",
#   "format": "RDF/XML"
# }'
#
# update.body <- '{
# "context": "https://raw.githubusercontent.com/PennTURBO/Turbo-Ontology/master/ontologies/turbo_merged.owl",
# "data": "https://raw.githubusercontent.com/PennTURBO/Turbo-Ontology/master/ontologies/turbo_merged.ttl",
# "format": "RDF/XML"
# }'
#
# update.body <- '{
#   "context": "http://purl.bioontology.org/ontology/ICD9CM/",
#   "data": "http://data.bioontology.org/ontologies/ICD9CM/submissions/17/download?apikey=9cf735c3-a44a-404f-8b2f-c49d48b2b8b2",
#   "format": "RDF/XML"
# }'
#
#
# placeholder <- POST(
#   # post.dest,
#   # body = bod4post,
#   post.endpoint,
#   body = update.body,
#   content_type("application/json"),
#   accept("application/json"),
#   saved.authentication
# )
#
# rawToChar(placeholder$content)
#
#
# # status.ph <- rawToChar(placeholder$content)
# # submission.time <- Sys.time()
# post.status <- rawToChar(placeholder$content)
# post.time <- Sys.time()
#
#
# ###
#
