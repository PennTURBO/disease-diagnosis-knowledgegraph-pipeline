options(java.parameters = "-Xmx6g")
library(rrdf)
library(igraph)

# load recent "legacy" mappings... good semantics, but no tie breaking
associations <- read.csv("associations.csv")

associations$MonDO.term <- as.character(associations$MonDO.term)
associations$ICD.code <- as.character(associations$ICD.code)

unique.associations <-
  unique(associations[, c("ICD.code", "ICD.label", "MonDO.term", "MonDO.label")])

# mapped, not requested
icd.list <- unique(associations$ICD.code)
mapped.icds.count <- length(icd.list)

# mondo.list <- unique(associations$MonDO.term)

icds.per.mondo <- table(unique.associations$MonDO.term)
icds.per.mondo <-
  cbind.data.frame(names(icds.per.mondo), as.numeric(icds.per.mondo))
names(icds.per.mondo) <- c("MonDO.term", "icds.mapped.count")

icds.per.mondo$information <-
  mapped.icds.count / icds.per.mondo$icds.mapped.count

unique.associations <-
  merge(x = unique.associations, y = icds.per.mondo)

# aggdata <- aggregate(
#   unique.associations$information,
#   by = list(unique.associations$ICD.code),
#   FUN = max,
#   na.rm = TRUE
# )
# names(aggdata) <- c("ICD.code", "information")
#
# merged <- merge(x = unique.associations, y = aggdata)

# nbest <- table(merged$ICD.code)
# nbest <-
#   cbind.data.frame(names(nbest), as.numeric(nbest))
# names(nbest) <- c("ICD.code", "nbest")
#
# merged <- merge(x = merged, y = nbest)
#
# nbest.tab <- table(nbest$nbest)
# nbest.tab <-
#   cbind.data.frame(names(nbest.tab), as.numeric(nbest.tab))
# names(nbest.tab) <- c("ICD.code", "nbest")

my.query <- '
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX obo: <http://purl.obolibrary.org/obo/>
prefix mydata: <http://example.com/resource/>
PREFIX oboInOwl: <http://www.geneontology.org/formats/oboInOwl#>
select ?sid ?oid where {
    graph <http://example.com/resource/mondoDiseaseSubclasses> {
        ?s rdfs:subClassOf ?o .
    }
    graph obo:mondo.owl {
        ?s oboInOwl:id ?sid .
        ?o oboInOwl:id ?oid .
    }
}'

my.endpint <- "http://localhost:7200/repositories/mondo"

my.result <-
  sparql.remote(endpoint = my.endpint,
                sparql = my.query,
                jena = TRUE)

my.result <- as.data.frame(my.result)

# my.result$p <- "subClassOf"

# my.result$s <-
#   sub(pattern = "http://purl.obolibrary.org/obo/",
#       replacement = "",
#       x = my.result$s)
# my.result$o <-
#   sub(pattern = "http://purl.obolibrary.org/obo/",
#       replacement = "",
#       x = my.result$o)


mrg <- igraph::graph_from_data_frame(my.result)

mrg.dists <- t(shortest.paths(graph = mrg, v = "MONDO:0000001"))
mrg.dists <- as.data.frame(mrg.dists)
mrg.dists$MonDO.term <- rownames(mrg.dists)

# disease.dists <- mrg.dists[,which(colnames(mrg.dists) == "MONDO_0000001")]
# disease.dists <- cbind.data.frame(names(disease.dists), as.numeric(disease.dists))
# names(disease.dists) <- c(","")

# mrgd.melt <- reshape2::melt(mrg.dists)

merged <- merge(x = unique.associations, y = mrg.dists)

merged$iXd <- merged$information * merged$`MONDO:0000001`
