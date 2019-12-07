library(SPARQL)
library(config)
library(httr)
library(jsonlite)


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