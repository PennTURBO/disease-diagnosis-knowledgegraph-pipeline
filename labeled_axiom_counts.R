library(stringr)
library(data.table)
library(readr)
library(dplyr)
library(RPostgres)
library(data.table)
library(DBI)

source("turbo_graphdb_setup.R")

sparql.ns <- c(
  'dc',
  '<http://purl.org/dc/elements/1.1/>',
  'rdfs',
  '<http://www.w3.org/2000/01/rdf-schema#>',
  'mydata',
  '<http://example.com/resource/>',
  'owl',
  '<http://www.w3.org/2002/07/owl#>',
  'skos',
  '<http://www.w3.org/2004/02/skos/core#>',
  # 'dhmf',
  # '<http://purl.obolibrary.org/obo/mondo#disease_has_major_feature>',
  'obo',
  '<http://purl.obolibrary.org/obo/>',
  'hgnc',
  '<http://identifiers.org/hgnc/>'
)

# this assumes that something like dd_batched_values_reverse.R
#   has already been run, creating a datafame 'outer'
#   with mondo ids in coli=umn 'mid'
m.terms.for.axioms <- sort(unique(as.character(outer$mid)))

current.assembled <-
  paste0(sapply(m.terms.for.axioms, function(x)
    toString(dQuote(x, q = FALSE))), collapse = " ")

axQuery.template <- 'select
distinct ?mid ?ml ?axProp  ?axVal
where {
    graph obo:mondo.owl {
        values ?mid { ${current.assembled} }
        ?m <http://www.geneontology.org/formats/oboInOwl#id> ?mid ;
        rdfs:label ?ml .
    }
    graph <http://example.com/resource/MondoTransitiveSimpleScoEqcAxioms> {
        ?m ?axProp ?axVal .
    }
}'

axQuery <- str_interp(axQuery.template)

prefixed <- (paste0(sparql.prefixes, "\n", axQuery, "\n"))

ax.res.list <- SPARQL(
  url =  select.endpoint,
  query = prefixed,
  ns = sparql.ns,
  curl_args = list(
    userpwd = paste0(api.user, ":", api.pass),
    httpauth = 1
    # 'Accept-Encoding' = 'gzip, deflate'
  )
)

ax.res.frame <- ax.res.list$results

ax.terms <- sort(unique(c(ax.res.frame$axProp, ax.res.frame$axVal)))
mondo.pred.flag <-
  grepl(pattern = "obo:mondo#", x = ax.terms, fixed = TRUE)
ax.terms <- ax.terms[!mondo.pred.flag]


current.assembled <- paste0(ax.terms, collapse = " ")

label.query.template <-
  'select
distinct ?t (lcase(str(?l)) as ?lst)
where {
    values ?t { ${current.assembled} }
    {
        ?t rdfs:label ?l .
    }
    filter((lang(?l) = "en") || (lang(?l) = ""))
}'

label.query <- str_interp(label.query.template)

label.query <-
  gsub(pattern = " +",
       replacement = " ",
       x = label.query)

prefixed.label.query <-
  paste0(sparql.prefixes, "\n", label.query, "\n")


label.result.list <-
  SPARQL(url =  "http://sparql.hegroup.org/sparql/",
         query = prefixed.label.query,
         ns = sparql.ns)

label.result.frame <- label.result.list$results

label.result.frame <-
  aggregate(lst ~ t, data = label.result.frame, paste, collapse = "|")

joined <-
  left_join(
    ax.res.frame,
    label.result.frame,
    by = c("axProp" = "t"),
    suffix = c("", ".props")
  )


joined <-
  left_join(
    joined,
    label.result.frame,
    by = c("axVal" = "t"),
    suffix = c("", ".vals")
  )


# cat(prefixed.label.query)

write.csv(joined, "lung_cancer_axioms.csv")

