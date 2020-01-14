options(java.parameters = "- Xmx6g")

library(SPARQL)
library(config)
library(httr)
library(igraph)
library(rrdf)
library(stringr)

options(java.parameters = "- Xmx6g")

config.yaml.file <- "dd_on_pmacs.yaml"

config.bootstrap <-
  config::get(file = config.yaml.file)

selected.gdb.configuration <-
  config::get(config = config.bootstrap$selected.gdb.configuration,
              file = config.yaml.file)

graphdb.address.port <-
  selected.gdb.configuration$graphdb.address.port
selected.repo <- selected.gdb.configuration$selected.repo
api.user <- selected.gdb.configuration$api.user
api.pass <- selected.gdb.configuration$api.pass


saved.authentication <-
  authenticate(api.user, api.pass, type = "basic")

update.endpoint <-
  paste0(graphdb.address.port,
         "/repositories/",
         selected.repo,
         "/statements")

select.endpoint <-
  paste0(graphdb.address.port, "/repositories/", selected.repo)

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

mrg <- igraph::graph_from_data_frame(result.frame)

mrg.dists <- t(shortest.paths(graph = mrg, v = "MONDO:0000001"))
mrg.dists <- as.data.frame(mrg.dists)
mrg.dists$MonDO.term <- rownames(mrg.dists)
mrg.dists <- mrg.dists[is.finite(mrg.dists$`MONDO:0000001`),]

mrg.dists <- mrg.dists[order(mrg.dists$MonDO.term), ]


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
