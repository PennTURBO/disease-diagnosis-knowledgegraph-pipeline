library(stringr)
library(data.table)
library(readr)
library(dplyr)
library(RPostgres)
library(data.table)
library(DBI)

source("turbo_graphdb_setup.R")

selected.postgres.configuration <-
  config::get(config = "dd_postgres",
              file = config.yaml.file)

host.name <- selected.postgres.configuration$host
database.name <- selected.postgres.configuration$dbname
postgres.user <- selected.postgres.configuration$user
# postgres.passwd <- rstudioapi::askForPassword("Database password")
postgres.passwd <- selected.postgres.configuration$pgpass
postgres.port <- selected.postgres.configuration$port
dd.table.name <- selected.postgres.configuration$dd.table.name

pg.RPostgres <- dbConnect(
  RPostgres::Postgres(),
  host = host.name,
  dbname = database.name,
  user = postgres.user,
  password = postgres.passwd,
  port = postgres.port
)

icdlist.file <-
  rstudioapi::selectFile(
    # CSV-formatted ?
    caption = "Select a headerless, single-column ICD list File",
    label = "Select",
    path = rstudioapi::getActiveProject(),
    filter = "All Files (*)",
    existing = TRUE
  )


icdlist <- read_csv(icdlist.file, col_names = FALSE)

print(nrow(icdlist))
# 26450
# how many can SPARQL candle per chunk?
# ~ 200 seems OK
# too big -> un-parsable result or failed distinct operation
# just do the distinct externally?

chunk.size <- 200

col2vec <- icdlist$X1

# col2vec <- "137.4"

the.chunks <-
  split(col2vec, ceiling(seq_along(col2vec) / chunk.size))

query.templates <- list(
  "icdCodes to icdTerms" = 'select
distinct ?icdTerms ?icdCodes
where {
    values ?icdCodes { ${current.assembled} }
    {
        {
            graph <http://purl.bioontology.org/ontology/ICD9CM/> {
                ?icdTerms skos:notation ?icdCodes .
            }
        }
        union {
            graph <http://purl.bioontology.org/ontology/ICD10CM/> {
                ?icdTerms skos:notation ?icdCodes .
            }
        }
    }
}'
)

chunk.count <- length(the.chunks)


outer <-
  lapply(names(query.templates), function(current.template.name) {
    inner <-
      lapply(1:chunk.count, function(chunk.index) {
        print(
          paste0(
            Sys.time(),
            ": ",
            current.template.name,
            " chunk ",
            chunk.index,
            ' of ',
            chunk.count
          )
        )
        current.assembled <-
          paste0(sapply(the.chunks[[chunk.index]], function(x)
            toString(dQuote(x, q = FALSE))), collapse = " ")
        
        
        current.template <- query.templates[[current.template.name]]
        
        prepre <- str_interp(current.template)
        
        prepre <-
          gsub(pattern = " +",
               replacement = " ",
               x = prepre)
        
        prefixed <- paste0(sparql.prefixes, "\n", prepre, "\n")
        
        cat(prefixed)
        
        sparql.res.list <- SPARQL(
          url =  select.endpoint,
          query = prefixed,
          ns = c(
            'dc',
            '<http://purl.org/dc/elements/1.1/>',
            'rdfs',
            '<http://www.w3.org/2000/01/rdf-schema#>',
            'mydata',
            '<http://example.com/resource/>',
            'owl',
            '<http://www.w3.org/2002/07/owl#>',
            'skos',
            '<http://www.w3.org/2004/02/skos/core#>'
          ),
          curl_args = list(
            userpwd = paste0(api.user, ":", api.pass),
            httpauth = 1
            # 'Accept-Encoding' = 'gzip, deflate'
          )
        )
        
        temp <- sparql.res.list$results
        if (is.data.frame(temp)) {
          if (nrow(temp) > 0) {
            return(temp)
          }
        }
      })
    inner <- do.call(rbind.data.frame, inner)
    return(inner)
    return(0)
  })
outer <- do.call(rbind.data.frame, outer)

setdiff(outer$icdCodes, icdlist$X1)
setdiff(icdlist$X1, outer$icdCodes)

temp <- table(outer$icdCodes)
temp <- cbind.data.frame(names(temp), as.numeric(temp))

sort(temp$`names(temp)`[temp$`as.numeric(temp)` != 1])

write_csv(outer, "anurag_icd_codes_to_terms.csv")

really.bare <- sub(pattern = "^<", replacement = "", x = outer$icdTerms)
really.bare <- sub(pattern = ">$", replacement = "", x = really.bare)

write.table(
  x = really.bare,
  file =  "anurag_icd_codes_to_really_bare_unquoted_terms.txt",
  row.names = FALSE,
  col.names = FALSE, quote = FALSE
)
