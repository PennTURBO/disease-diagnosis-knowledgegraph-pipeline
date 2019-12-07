library(stringr)
library(data.table)
library(readr)
library(dplyr)

source("turbo_graphdb_setup.R")

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
# 200-300 seems OK

# too big -> un-parsable result or failed distinct operation
# just do the distinct externally?
chunk.size <- 200

the.chunks <-
  split(icdlist$X1, ceiling(seq_along(icdlist$X1) / chunk.size))

# does the ordering of query lines
#  or {} grouping of the query matter for performance?
# can we give hints?

# snomed transitivity?

# filter?



query.templates <- list(
  "mondo->icd" = 'select
  #distinct
  ?mid ?ml ?approxDepth
  ("mondo->icd" as ?pathFamily) ?assertionOrientation ?assertedPredicate
  (concat("ICD", str(?icdVer), "CM:",?icdCode) as ?versionedIcd)  (str(?ipl) as ?iplstr)
where {
    values ?icdCode { ${current.assembled} }
    {
        {
            graph <http://purl.bioontology.org/ontology/ICD10CM/> {
                ?icdLeaf skos:notation ?icdCode ;
                         rdfs:subClassOf* ?icd ;
                         skos:prefLabel ?ipl  .
            }
#            graph <http://example.com/resource/ICD10TransitiveSubClasses> {
#                ?icdLeaf rdfs:subClassOf ?icd
#            }
            bind(10 as ?icdVer)
        }
        union
        {
            graph <http://purl.bioontology.org/ontology/ICD9CM/> {
                ?icdLeaf skos:notation ?icdCode ;
                         rdfs:subClassOf* ?icd ;
                         skos:prefLabel ?ipl  .
            }
#            graph <http://example.com/resource/ICD9DiseaseInjuryTransitiveSubClasses> {
#                ?icdLeaf rdfs:subClassOf ?icd
#            }
            bind(9 as ?icdVer)
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
  (concat("ICD", str(?icdVer), "CM:",?icdCode) as ?versionedIcd)  (str(?ipl) as ?iplstr)
where {
    values ?icdCode { ${current.assembled} }
    {
        {
            graph <http://purl.bioontology.org/ontology/ICD10CM/> {
                ?icdLeaf skos:notation ?icdCode ;
                         rdfs:subClassOf* ?icd ;
                         skos:prefLabel ?ipl  .
            }
#            graph <http://example.com/resource/ICD10TransitiveSubClasses> {
#                ?icdLeaf rdfs:subClassOf ?icd
#            }
            bind(10 as ?icdVer)
        }
        union
        {
            graph <http://purl.bioontology.org/ontology/ICD9CM/> {
                ?icdLeaf skos:notation ?icdCode ;
                         rdfs:subClassOf* ?icd ;
                         skos:prefLabel ?ipl  .
            }
#            graph <http://example.com/resource/ICD9DiseaseInjuryTransitiveSubClasses> {
#                ?icdLeaf rdfs:subClassOf ?icd
#            }
            bind(9 as ?icdVer)
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
("mondo->snomed,transitive->CUI->icd" as ?pathFamily) ?assertionOrientation ?assertedPredicate
(concat(?icdVer,?icdCode) as ?versionedIcd)  (str(?ipl) as ?iplstr)
where {
    values ?icdCode { ${current.assembled} }
    {
        {
            graph <http://purl.bioontology.org/ontology/ICD10CM/> {
                ?icdLeaf skos:notation ?icdCode ;
                         rdfs:subClassOf* ?icd ;
                         skos:prefLabel ?ipl  .
            }
#            graph <http://example.com/resource/ICD10TransitiveSubClasses> {
#                ?icdLeaf rdfs:subClassOf ?icd
#            }
            bind(10 as ?icdVer)
        }
        union
        {
            graph <http://purl.bioontology.org/ontology/ICD9CM/> {
                ?icdLeaf skos:notation ?icdCode ;
                         rdfs:subClassOf* ?icd ;
                         skos:prefLabel ?ipl  .
            }
#            graph <http://example.com/resource/ICD9DiseaseInjuryTransitiveSubClasses> {
#                ?icdLeaf rdfs:subClassOf ?icd
#            }
            bind(9 as ?icdVer)
        }
    }

    graph <http://example.com/resource/materializedCui> {
        ?icd mydata:materializedCui ?cui .
        ?snomed mydata:materializedCui ?cui .
    }
    graph <http://purl.bioontology.org/ontology/SNOMEDCT_US/> {
        ?snomed a owl:Class ;
                rdfs:subClassOf* ?sParent .
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
        ?m mydata:hopCount ?approxDepth
    }
}',
  "mondo->snomed,transitive->NLM mappings->icd9" = 'select
# distinct
?mid ?ml
?approxDepth
#(max(?approxDepth) as ?approxMaxDepth)
("mondo->snomed,transitive->NLM mappings->icd9" as ?pathFamily) ?assertionOrientation ?assertedPredicate
(concat(?icdVer,?icdCode) as ?versionedIcd) (str(?ipl) as ?iplstr)
where {
    values ?icdCode { ${current.assembled} }
    {
        graph <http://purl.bioontology.org/ontology/ICD9CM/> {
            ?icdLeaf skos:notation ?icdCode ;
                     rdfs:subClassOf* ?icd ;
                                    skos:prefLabel ?ipl  .
        }
        #            graph <http://example.com/resource/ICD9DiseaseInjuryTransitiveSubClasses> {
        #                ?icdLeaf rdfs:subClassOf ?icd
        #            }
        bind(9 as ?icdVer)
    }
    graph <https://www.nlm.nih.gov/research/umls/mapping_projects/icd9cm_to_snomedct.html> {
        ?icd <https://www.nlm.nih.gov/research/umls/mapping_projects/icd9cm_to_snomedct.html> ?snomed
    }
    graph <http://purl.bioontology.org/ontology/SNOMEDCT_US/> {
        ?snomed a owl:Class ;
                rdfs:subClassOf* ?sParent .
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
        ?m mydata:hopCount ?approxDepth
    }
}
#group by ?mid ?ml ?assertionOrientation ?assertedPredicate ?icdVer ?icdCode ?ipl'
)

# filter out root MonDO or SNOMED roots  after the fact?
# almost all of the slowness (1 minute per chunk of 250)
# n the last query is from transport of the results
# even though they have been uniqified
# larger memory on turbo-prd-db01 does not help
# limit to deepest mapping in sparql?


chunk.count <- length(the.chunks)


outer <-
  lapply(names(query.templates), function(current.template.name) {
    # current.template.name <- "mondo->icd"
    # print(current.template.name)
    
    # 1:chunk.count
    inner <-
      lapply(1:3, function(chunk.index) {
        # lapply(65:70, function(chunk.index) {
        # current.chunk <- the.chunks[[1]]
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
        
        return(sparql.res.list$results)
      })
    inner <- do.call(rbind.data.frame, inner)
    return(inner)
  })

outer <- do.call(rbind.data.frame, outer)

outer <- unique(outer)

# may be too deep/overly specific on the mondo side sometimes?
deepest <-
  outer %>% group_by(versionedIcd) %>% top_n(1, approxDepth)

### tables

paths.per.mapping <-
  as.data.frame(table(outer$mid, outer$versionedIcd))
paths.per.mapping <-
  paths.per.mapping[paths.per.mapping$Freq > 0 ,]
hist(paths.per.mapping$Freq)

mappings.per.path <-
  as.data.frame(table(
    outer$pathFamily,
    outer$assertionOrientation,
    outer$assertedPredicate
  ))
mappings.per.path <-
  mappings.per.path[mappings.per.path$Freq > 0 , ]

# hist(mappings.per.path$Freq, breaks = 99)

# write.csv(mappings.per.path, "mappings_per_path.csv")
# write.csv(paths.per.mapping, "paths_per_mapping.csv")

paths.per.mapping.table <- table(paths.per.mapping$Freq)
paths.per.mapping.table <-
  cbind.data.frame(as.numeric(names(paths.per.mapping.table)), as.numeric(paths.per.mapping.table))
names(paths.per.mapping.table) <- c("path.count", "mappings.count")

# write.csv(paths.per.mapping.table, "paths_per_mapping.csv")


### historical comparison


requested <- unique(icdlist$X1)

anurag_icd_mondo_report_1$bare.icd <-
  sub(pattern = 'http://purl.bioontology.org/ontology/ICD[0-9]{1,2}CM/',
      replacement = '',
      x = anurag_icd_mondo_report_1$ICD)

previous.successes <-
  intersect(requested, anurag_icd_mondo_report_1$bare.icd)


###


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




# delivered.only <- setdiff(delivered, requested)
#
# requested.only <- setdiff(requested, delivered)
#
# sort(requested)
# sort(delivered)
# sort(requested.only)
#
# # 003.1 : Salmonella septicemia
#
# length(unique(outer$versionedIcd))
#
# anurag_icd_mondo_report_1 <- read_csv("Anurag/anurag_icd_mondo_report_1.csv")
#
# length(unique(anurag_icd_mondo_report_1$ICD))





new.failures <- setdiff(previous.successes, delivered)

sort(new.failures)

insights <-
  anurag_icd_mondo_report_1[anurag_icd_mondo_report_1$bare.icd %in% new.failures , ]
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

lost.mondos <- table(insights$MONDO_label)
lost.mondos <-
  cbind.data.frame(names(lost.mondos), as.numeric(lost.mondos))

lost.icd9s <-
  insights$bare.icd[grep(pattern = "http://purl.bioontology.org/ontology/ICD9CM/", x = insights$ICD)]

lost.icd9.sample <-
  sort(sample(sort(lost.icd9s), size = 200, replace = FALSE))

### for daignosis apparent broken links from nlm snomed icd9 mapping

ICD9CM_SNOMED_MAP_1TO1_201812 <-
  read_delim(
    "ICD9CM_SNOMED_MAP_1TO1_201812.txt",
    "\t",
    escape_double = FALSE,
    trim_ws = TRUE
  )

ICD9CM_SNOMED_MAP_1TOM_201812 <-
  read_delim(
    "ICD9CM_SNOMED_MAP_1TOM_201812.txt",
    "\t",
    escape_double = FALSE,
    trim_ws = TRUE
  )

ICD9CM_SNOMED_MAP_201812 <-
  rbind.data.frame(ICD9CM_SNOMED_MAP_1TO1_201812,
                   ICD9CM_SNOMED_MAP_1TOM_201812)
