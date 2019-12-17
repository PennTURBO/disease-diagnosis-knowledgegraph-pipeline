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

col2vec <-
  c(
    "M10.00",
    "M10.011",
    "M10.012",
    "M10.019",
    "M10.021",
    "M10.022",
    "M10.029",
    "M10.031",
    "M10.032",
    "M10.039",
    "M10.041",
    "M10.042",
    "M10.049",
    "M10.061",
    "M10.062",
    "M10.069",
    "M10.071",
    "M10.072",
    "M10.079",
    "M10.09",
    "M10.10",
    "M10.242",
    "M10.261",
    "M10.262",
    "M10.269",
    "M10.271",
    "M10.272",
    "M10.29",
    "M10.30",
    "M10.331",
    "M10.341",
    "M10.361",
    "M10.362",
    "M10.369",
    "M10.371",
    "M10.372",
    "M10.379",
    "M10.39",
    "M10.40",
    "M10.439",
    "M10.449",
    "M10.461",
    "M10.471",
    "M10.472",
    "M10.479",
    "M10.9",
    "195.0",
    "239",
    "646.50",
    "646.51",
    "646.53",
    "780.93",
    "786.6",
    "790.99",
    "995.22",
    "D28.7",
    "D49.0",
    "D49.2",
    "D49.3",
    "D49.4",
    "D49.5",
    "D49.511",
    "D49.512",
    "D49.519",
    "D49.59",
    "D49.6",
    "D49.7",
    "D49.81",
    "D49.89",
    "D49.9",
    "E850.3",
    "E850.5",
    "E850.6",
    "E851",
    "E852.2",
    "E853.0",
    "E853.2",
    "E853.8",
    "E854.0",
    "E854.1",
    "E854.2",
    "E854.3",
    "E855.0",
    "E855.2",
    "E855.5",
    "E855.6",
    "E858.0",
    "E858.3",
    "E858.6",
    "E860.0",
    "E861.4",
    "E863.6",
    "E863.7",
    "E868.2",
    "E868.9",
    "E869.3",
    "E887",
    "R41.89",
    "V08",
    "V09.1",
    "V09.50",
    "V09.80",
    "V09.81",
    "V09.91",
    "V10.29",
    "V11.9",
    "V12.60",
    "V12.79",
    "V13.51",
    "V14.0",
    "V14.1",
    "V14.7",
    "V14.8",
    "V14.9",
    "V15.03",
    "V15.05",
    "V15.07",
    "V15.08",
    "V15.09",
    "V17.2",
    "V17.89",
    "V18.19",
    "V18.59",
    "V19.8",
    "V22.2",
    "V41.5",
    "V41.7",
    "V43.61",
    "V43.64",
    "V43.65",
    "V43.66",
    "V43.69",
    "V45.11",
    "V45.69",
    "V45.71",
    "V45.72",
    "V45.73",
    "V45.74",
    "V45.75",
    "V45.76",
    "V45.77",
    "V45.78",
    "V45.79",
    "V45.89",
    "V47.3",
    "V47.4",
    "V48.4",
    "V49.1",
    "V49.62",
    "V49.70",
    "V49.89",
    "V56.0",
    "V58.65",
    "V58.67",
    "V58.69",
    "V62.1",
    "V62.89",
    "V77.7",
    "V83.89",
    "V84.01",
    "V86.1",
    "V88.01",
    "V88.02"
  )

the.chunks <-
  split(col2vec, ceiling(seq_along(col2vec) / chunk.size))

# does the ordering of query lines
#  or {} grouping of the query matter for performance?
# can we give hints?

# snomed and ICD transitivity required to replicate anurag_icd_mondo_report_1
# whether subClasOf* or materialized subclasses is better is unclear!

# filter?

query.templates <- list(
  "mondo->icd" = 'select
  #distinct
  ?mid ?ml ?approxDepth
  ("mondo->icd" as ?pathFamily) ?assertionOrientation ?assertedPredicate
  (concat(?icdVer,?icdCode) as ?versionedIcd)  (str(?ipl) as ?iplstr)
where {
    values ?icdCode { ${current.assembled} }
    {
        {
            graph <http://purl.bioontology.org/ontology/ICD10CM/> {
                ?icdLeaf skos:notation ?icdCode ;
#                         rdfs:subClassOf* ?icd ;
                         skos:prefLabel ?ipl  .
            }
            graph <http://example.com/resource/ICD10TransitiveSubClasses> {
                ?icdLeaf rdfs:subClassOf ?icd
            }
            bind("ICD10CM:" as ?icdVer)
        }
        union
        {
            graph <http://purl.bioontology.org/ontology/ICD9CM/> {
                ?icdLeaf skos:notation ?icdCode ;
#                         rdfs:subClassOf* ?icd ;
                         skos:prefLabel ?ipl  .
            }
            graph <http://example.com/resource/ICD9DiseaseInjuryTransitiveSubClasses> {
                ?icdLeaf rdfs:subClassOf ?icd
            }
            bind("ICD9CM:" as ?icdVer)
        }
    }
    {
        {
            graph <http://example.com/resource/rewrites_MonDO_subject> {
                ?m ?assertedPredicate ?icd .
            }
            bind("forward" as ?assertionOrientation)
        }
        union
        {
            graph <http://example.com/resource/rewrites_MonDO_object> {
                ?m ?assertedPredicate ?icd .
            }
            bind("reverse" as ?assertionOrientation)
        }
    }
    graph <http://purl.obolibrary.org/obo/mondo.owl> {
        ?m rdfs:label ?ml ;
           <http://www.geneontology.org/formats/oboInOwl#id> ?mid
    }
    graph mydata:mondoHopCounts {
        ?m mydata:hopCount  ?approxDepth
    }
}',
  "mondo->CUI->icd" = 'select
  #distinct
  ?mid ?ml ?approxDepth
  ("mondo->CUI->icd" as ?pathFamily) ?assertionOrientation ?assertedPredicate
  (concat(?icdVer,?icdCode) as ?versionedIcd)  (str(?ipl) as ?iplstr)
where {
    values ?icdCode { ${current.assembled} }
    {
        {
            graph <http://purl.bioontology.org/ontology/ICD10CM/> {
                ?icdLeaf skos:notation ?icdCode ;
#                         rdfs:subClassOf* ?icd ;
                         skos:prefLabel ?ipl  .
            }
            graph <http://example.com/resource/ICD10TransitiveSubClasses> {
                ?icdLeaf rdfs:subClassOf ?icd
            }
            bind("ICD10CM:" as ?icdVer)
        }
        union
        {
            graph <http://purl.bioontology.org/ontology/ICD9CM/> {
                ?icdLeaf skos:notation ?icdCode ;
#                         rdfs:subClassOf* ?icd ;
                         skos:prefLabel ?ipl  .
            }
            graph <http://example.com/resource/ICD9DiseaseInjuryTransitiveSubClasses> {
                ?icdLeaf rdfs:subClassOf ?icd
            }
            bind("ICD9CM:" as ?icdVer)
        }
    }
        graph <http://example.com/resource/materializedCui> {
        ?cui a mydata:materializedCui .
        ?icd mydata:materializedCui ?cui .
    }
    {
        {
            graph <http://example.com/resource/rewrites_MonDO_subject> {
                ?m ?assertedPredicate ?cui .
            }
            bind("forward" as ?assertionOrientation)
        }
        union
        {
            graph <http://example.com/resource/rewrites_MonDO_object> {
                ?m ?assertedPredicate ?cui .
            }
            bind("reverse" as ?assertionOrientation)
        }
    }
    graph <http://purl.obolibrary.org/obo/mondo.owl> {
        ?m rdfs:label ?ml ;
           <http://www.geneontology.org/formats/oboInOwl#id> ?mid
    }
    graph mydata:mondoHopCounts {
        ?m mydata:hopCount  ?approxDepth
    }
}',
  "mondo->snomed->CUI->icd" = 'select
  #distinct
  ?mid ?ml ?approxDepth
  ("mondo->snomed->CUI->icd" as ?pathFamily) ?assertionOrientation ?assertedPredicate
  (concat(?icdVer,?icdCode) as ?versionedIcd)  (str(?ipl) as ?iplstr)
where {
    values ?icdCode { ${current.assembled} }
    {
        {
            graph <http://purl.bioontology.org/ontology/ICD10CM/> {
                ?icdLeaf skos:notation ?icdCode ;
#                         rdfs:subClassOf* ?icd ;
                         skos:prefLabel ?ipl  .
            }
            graph <http://example.com/resource/ICD10TransitiveSubClasses> {
                ?icdLeaf rdfs:subClassOf ?icd
            }
            bind("ICD10CM:" as ?icdVer)
        }
        union
        {
            graph <http://purl.bioontology.org/ontology/ICD9CM/> {
                ?icdLeaf skos:notation ?icdCode ;
#                         rdfs:subClassOf* ?icd ;
                         skos:prefLabel ?ipl  .
            }
            graph <http://example.com/resource/ICD9DiseaseInjuryTransitiveSubClasses> {
                ?icdLeaf rdfs:subClassOf ?icd
            }
            bind("ICD9CM:" as ?icdVer)
        }
    }
    graph <http://example.com/resource/materializedCui> {
        ?icd mydata:materializedCui ?cui .
        ?snomed mydata:materializedCui ?cui .
    }
#    graph <http://purl.bioontology.org/ontology/SNOMEDCT_US/> {
#        ?snomed a owl:Class ;
#                rdfs:subClassOf* ?sParent .
#    }
   graph <http://example.com/resource/SnomedDiseaseTransitiveSubClasses> {
        ?snomed rdfs:subClassOf ?sParent .
     }
    {
        {
            graph <http://example.com/resource/rewrites_MonDO_subject> {
                ?m ?assertedPredicate ?sParent .
            }
            bind("forward" as ?assertionOrientation)
        }
        union
        {
            graph <http://example.com/resource/rewrites_MonDO_object> {
                ?m ?assertedPredicate ?sParent .
            }
            bind("reverse" as ?assertionOrientation)
        }
    }
    graph <http://purl.obolibrary.org/obo/mondo.owl> {
        ?m rdfs:label ?ml ;
           <http://www.geneontology.org/formats/oboInOwl#id> ?mid
    }
    graph mydata:mondoHopCounts {
        ?m mydata:hopCount  ?approxDepth
    }
}',
  "mondo->snomed,transitive->NLM mappings->icd9" = 'select
  #distinct
  ?mid ?ml ?approxDepth
  ("mondo->snomed,transitive->NLM mappings->icd9" as ?pathFamily) ?assertionOrientation ?assertedPredicate
  (concat(?icdVer,?icdCode) as ?versionedIcd)  (str(?ipl) as ?iplstr)
where {
    values ?icdCode { ${current.assembled} }
    {
         graph <http://purl.bioontology.org/ontology/ICD9CM/> {
                ?icdLeaf skos:notation ?icdCode ;
#                         rdfs:subClassOf* ?icd ;
                         skos:prefLabel ?ipl  .
            }
            graph <http://example.com/resource/ICD9DiseaseInjuryTransitiveSubClasses> {
                ?icdLeaf rdfs:subClassOf ?icd
            }
            bind("ICD9CM:" as ?icdVer)
    }
    graph <https://www.nlm.nih.gov/research/umls/mapping_projects/icd9cm_to_snomedct.html> {
        ?icd <https://www.nlm.nih.gov/research/umls/mapping_projects/icd9cm_to_snomedct.html> ?snomed
    }
#    graph <http://purl.bioontology.org/ontology/SNOMEDCT_US/> {
#        ?snomed a owl:Class ;
#                rdfs:subClassOf* ?sParent .
#    }
   graph <http://example.com/resource/SnomedDiseaseTransitiveSubClasses> {
        ?snomed rdfs:subClassOf ?sParent .
     }
    {
        {
            graph <http://example.com/resource/rewrites_MonDO_subject> {
                ?m ?assertedPredicate ?sParent .
            }
            bind("forward" as ?assertionOrientation)
        }
        union
        {
            graph <http://example.com/resource/rewrites_MonDO_object> {
                ?m ?assertedPredicate ?sParent .
            }
            bind("reverse" as ?assertionOrientation)
        }
    }
    graph <http://purl.obolibrary.org/obo/mondo.owl> {
        ?m <http://www.geneontology.org/formats/oboInOwl#id> ?mid ;
           rdfs:label ?ml .
    }
    graph mydata:mondoHopCounts {
        ?m mydata:hopCount  ?approxDepth
    }
}
#group by ?mid ?ml ?assertionOrientation ?assertedPredicate ?icdVer ?icdCode ?ipl'
)

# filter out root MonDO or SNOMED roots  after the fact?
# almost all of the slowness (1.5 minutes+ per chunk of 200)
# even when they have been uniqified
# in the NLM mappings query is from transport of the results over localhost
#   AND PARSING in R

# larger memory on turbo-prd-db01 does not help ?!
# haven't been able to get http compression to work in SAPRQL::
# limit to deepest mapping in sparql?

# # may be too deep/overly specific on the mondo side sometimes?
# see typhoid vs gi disorder?

chunk.count <- length(the.chunks)

dd.table.name <- "m10check"


outer <-
  lapply(names(query.templates), function(current.template.name) {
    # current.template.name <- "mondo->icd"
    # print(current.template.name)
    
    # 1:chunk.count
    inner <-
      lapply(1:chunk.count, function(chunk.index) {
        # lapply(65:70, function(chunk.index) {
        # current.chunk <- the.chunks[[1]]
        # current.chunk <- list("137.4 ")
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
        
        # cat(prefixed)
        
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
            temp$chunk <- chunk.index
            
            write.result <-
              dbWriteTable(pg.RPostgres,
                           dd.table.name,
                           temp,
                           overwrite = FALSE,
                           append = TRUE)
            
            # doesn't help... no woking over all environments?
            gc()
            
            objects.sizes <- lapply(ls(), function(current.obj) {
              the.size <- object.size(current.obj)
              return(list(current.obj, the.size))
            })
            
            objects.sizes <-
              do.call(rbind.data.frame, objects.sizes)
            names(objects.sizes) <- c("object", "size")
            objects.sizes <-
              objects.sizes[order(objects.sizes$size, decreasing = TRUE),]
            print(head(objects.sizes))
            
          }
          
          
        }
        
        return(0)
        
        # return(sparql.res.list$results)
      })
    # inner <- do.call(rbind.data.frame, inner)
    # return(inner)
    return(0)
  })
# outer <- do.call(rbind.data.frame, outer)

outer <-
  dbGetQuery(pg.RPostgres, paste0("select * from ", dd.table.name))

keepers <- setdiff(names(outer), "chunk")

outer <- unique(outer[, keepers])

temp <- unique(outer[, c("mid", "ml")])
temp <- temp[order(temp$ml),]

# tablulate the mondo classes after the fact?
# # "deepest" alone may be too deep/overly specific on the mondo side sometimes?

mondo.count <- table(outer$mid)
mondo.count <-
  cbind.data.frame(names(mondo.count), as.numeric(mondo.count))
names(mondo.count) <- c("mid","count")

outer <- left_join(outer, mondo.count)
outer$dcr <- outer$approxDepth/outer$count

deepest <-
  outer %>% group_by(versionedIcd) %>% top_n(1, dcr)

### historical comparison

requested <- unique(icdlist$X1)

anurag_icd_mondo_report_1 <-
  read_csv("Anurag/anurag_icd_mondo_report_1.csv")

anurag_icd_mondo_report_1$bare.icd <-
  sub(pattern = 'http://purl.bioontology.org/ontology/ICD[0-9]{1,2}CM/',
      replacement = '',
      x = anurag_icd_mondo_report_1$ICD)

delivered <- anurag_icd_mondo_report_1$bare.icd

previous.successes <-
  intersect(requested, delivered)

previous.unmapped <- setdiff(requested, delivered)

previous.unrequested <- setdiff(delivered, requested)

### QC

delivered.new <- unique(outer$versionedIcd)

delivered.new <- sub(pattern = "^.*:",
                     replacement = "",
                     x = delivered.new)

ps.dn.overlap <- intersect(previous.successes, delivered.new)
ps.only <- setdiff(previous.successes, delivered.new)
dn.only <- setdiff(delivered.new, previous.successes)

insights <-
  anurag_icd_mondo_report_1[anurag_icd_mondo_report_1$bare.icd %in% ps.only , ]
insight.paths <- insights$mapping_method
insight.paths <- strsplit(insight.paths, split = ";")
insight.paths <- unlist(insight.paths)
insight.paths <-
  gsub(pattern = '"',
       replacement = '',
       x = insight.paths)
insight.paths <- table(insight.paths)
insight.paths <-
  cbind.data.frame(names(insight.paths), as.numeric(insight.paths))

# #not really necessary if the disjoints are small
# lost.mondos <- table(insights$MONDO_label)
# lost.mondos <-
#   cbind.data.frame(names(lost.mondos), as.numeric(lost.mondos))
#
# lost.icd9s <-
#   insights$bare.icd[grep(pattern = "http://purl.bioontology.org/ontology/ICD9CM/", x = insights$ICD)]
# lost.icd9.sample <-
#   sort(sample(sort(lost.icd9s), size = 200, replace = FALSE))

### tables
# running out of memory, when processing the un-deepestified "outer" with 16 GB

paths.per.mapping <-
  as.data.frame(table(deepest$mid, deepest$versionedIcd))
# Error: cannot allocate vector of size 1008.8 Mb
paths.per.mapping <-
  paths.per.mapping[paths.per.mapping$Freq > 0 ,]
hist(paths.per.mapping$Freq)

paths.per.mapping.table <- table(paths.per.mapping$Freq)
paths.per.mapping.table <-
  cbind.data.frame(as.numeric(names(paths.per.mapping.table)), as.numeric(paths.per.mapping.table))
names(paths.per.mapping.table) <- c("path.count", "mappings.count")

mappings.per.path <-
  as.data.frame(
    table(
      deepest$pathFamily,
      deepest$assertionOrientation,
      deepest$assertedPredicate
    )
  )
mappings.per.path <-
  mappings.per.path[mappings.per.path$Freq > 0 ,]

# # hist(mappings.per.path$Freq, breaks = 99)
#
# write.csv(mappings.per.path, "mappings_per_path.csv")
# write.csv(paths.per.mapping, "paths_per_mapping.csv")
# write.csv(paths.per.mapping.table, "paths_per_mapping.csv")

# ### for daignosing apparent broken links from NLM snomed icd9 mapping
#
# ICD9CM_SNOMED_MAP_1TO1_201812 <-
#   read_delim(
#     "ICD9CM_SNOMED_MAP_1TO1_201812.txt",
#     "\t",
#     escape_double = FALSE,
#     trim_ws = TRUE
#   )
#
# ICD9CM_SNOMED_MAP_1TOM_201812 <-
#   read_delim(
#     "ICD9CM_SNOMED_MAP_1TOM_201812.txt",
#     "\t",
#     escape_double = FALSE,
#     trim_ws = TRUE
#   )
#
# ICD9CM_SNOMED_MAP_201812 <-
#   rbind.data.frame(ICD9CM_SNOMED_MAP_1TO1_201812,
#                    ICD9CM_SNOMED_MAP_1TOM_201812)

### beautify

#  dput(names(deepest))


names(deepest) <-
  c(
    "MonDO Term",
    "MonDO Label",
    "Approx. Depth",
    "Path Family",
    "MonDO Assertion Direction",
    "Asserted Predicate",
    "ICD Code",
    "ICD Label",
    "MonDO Count",
    "D/C ratio"
  )

deepest <- deepest[, c(
  "MonDO Term",
  "MonDO Label",
  "Path Family",
  "Asserted Predicate",
  "MonDO Assertion Direction",
  "ICD Code",
  "ICD Label",
  "D/C ratio",
  "Approx. Depth",
  "MonDO Count"
)]

write.csv(deepest, "lm_ao_anurag_verbose_report_dcr_filtered.csv")

length(setdiff(requested, delivered.new))

length(setdiff(delivered.new, requested))

length(intersect(delivered.new, requested))

length(intersect(delivered.new, requested))/length(unique(c(requested, delivered.new)))



length(intersect(delivered, requested))/length(unique(c(requested, delivered)))
