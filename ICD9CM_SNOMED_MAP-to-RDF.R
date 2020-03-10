library(readr)
library(rdflib)
library(dplyr)
library(tidyr)
library(tibble)
library(uuid)
library(config)

args  <-  commandArgs(trailingOnly = TRUE)
# print(args)
# print(file.exists(args[1]))
# print(getwd())

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
  actual.config.file <- "config/disease_diagnosis.yaml"
  print(paste0(
    "Using default config file ",
    actual.config.file,
    " from current directory"
  ))
}


config <- config::get(file = actual.config.file)

read.snomed.icd9.mapping <- function(mapping.path) {
  ICD9CM_SNOMED_MAP <-
    read_delim(
      mapping.path,
      "\t",
      escape_double = FALSE,
      col_types = cols(
        CORE_USAGE = col_character(),
        OP_USAGE = col_character(),
        AVG_USAGE = col_character(),
        IN_CORE = col_logical(),
        `IS_1-1MAP` = col_logical(),
        IS_CURRENT_ICD = col_logical(),
        IS_NEC = col_character(),
        SNOMED_CID = col_character()
      ),
      trim_ws = TRUE
    )
  
  ICD9CM_SNOMED_MAP$CORE_USAGE <-
    as.numeric(ICD9CM_SNOMED_MAP$CORE_USAGE)
  
  ICD9CM_SNOMED_MAP$OP_USAGE <-
    as.numeric(ICD9CM_SNOMED_MAP$OP_USAGE)
  
  ICD9CM_SNOMED_MAP$AVG_USAGE <-
    as.numeric(ICD9CM_SNOMED_MAP$AVG_USAGE)
  
  return(ICD9CM_SNOMED_MAP)
  
}

ICD9CM_SNOMED_MAP_1TO1.frame <-
  read.snomed.icd9.mapping(config$ICD9CM_SNOMED_MAP_1TO1.path)

ICD9CM_SNOMED_MAP_1TOM.frame <-
  read.snomed.icd9.mapping(config$ICD9CM_SNOMED_MAP_1TOM.path)

ICD9CM_SNOMED_MAP <-
  rbind.data.frame(ICD9CM_SNOMED_MAP_1TO1.frame, ICD9CM_SNOMED_MAP_1TOM.frame)

ICD9CM_SNOMED_MAP_triples <-
  ICD9CM_SNOMED_MAP %>%
  rowid_to_column("subject") %>%
  mutate(subject = paste0("http://example.com/resource/snomed_icd9_mapping/", subject)) %>%
  gather(predicate, object, -subject)  %>%
  mutate(predicate = paste0("http://example.com/resource/", predicate))

ICD9CM_SNOMED_MAP_triples$subject <-
  paste0("http://example.com/resource/", UUIDgenerate(n = nrow(ICD9CM_SNOMED_MAP)))

# nrow(ICD9CM_SNOMED_MAP_triples)
rdf <- rdf()
# print(Sys.time())
system.time(placeholder <-
              apply(
                X = ICD9CM_SNOMED_MAP_triples,
                MARGIN = 1,
                FUN = function(current.row) {
                  rdf %>% rdf_add(current.row[["subject"]], current.row[["predicate"]], current.row[["object"]])
                  rdf %>% rdf_add(
                    current.row[["subject"]],
                    "http://www.w3.org/1999/02/22-rdf-syntax-ns#type",
                    "https://www.nlm.nih.gov/research/umls/mapping_projects/icd9cm_to_snomedct.html"
                  )
                }
              ))

# rdf

# https://www.nlm.nih.gov/research/umls/mapping_projects/icd9cm_to_snomedct.html

rdf_serialize(rdf, config$ICD9CM_SNOMED_MAP.filepath, format = "turtle")
