library(stringr)
library(data.table)
library(readr)

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

chunk.size <- 250

the.chunks <-
  split(icdlist$X1, ceiling(seq_along(icdlist$X1) / chunk.size))

# does the ordering of query lines
#  or {} grouping of the query matter for performance?
# can we give hints?

# omit snomed transitivity for now

# filter?


# snomed.transitive.query.templates <- list(
#   "mondo->icd" = 'select
# distinct ?m ?rewriteGraph ?assertedPredicate (concat("ICD", ?icdVer, "CM:") as ?versionedIcd) ?icdCode ?ipl ("mondo->icd" as ?pathFamily)
# where {
#     values ?icdCode { ${current.assembled} }
#     graph <http://example.com/resource/MondoTransitiveSubClasses> {
#         ?m rdfs:subClassOf <http://purl.obolibrary.org/obo/MONDO_0000001> .
#     }
#     graph ?rewriteGraph {
#         ?m ?assertedPredicate ?icd
#     }
#     {
#         {
#             graph <http://purl.bioontology.org/ontology/ICD10CM/> {
#                 ?icd skos:notation ?icdCode ;
#                      skos:prefLabel ?ipl . .
#             }
#             bind(10 as ?icdVer)
#         }
#         union
#         {
#             graph <http://purl.bioontology.org/ontology/ICD9CM/> {
#                 ?icd skos:notation ?icdCode ;
#                      skos:prefLabel ?ipl .
#             }
#             bind(9 as ?icdVer)
#         }
#     }
# }',
#   "mondo->CUI->icd" = 'select
# distinct ?m ?rewriteGraph ?assertedPredicate (concat("ICD", ?icdVer, "CM:") as ?versionedIcd) ?icdCode ?ipl ("mondo->CUI->icd" as ?pathFamily)
# where {
#     values ?icdCode { ${current.assembled} }
#     graph <http://example.com/resource/MondoTransitiveSubClasses> {
#         ?m rdfs:subClassOf <http://purl.obolibrary.org/obo/MONDO_0000001> .
#     }
#     graph ?rewriteGraph {
#         ?m ?assertedPredicate ?cui
#     }
#     graph <http://example.com/resource/materializedCui> {
#         ?cui a mydata:materializedCui .
#         ?icd mydata:materializedCui ?cui .
#     }
#     {
#         {
#             graph <http://purl.bioontology.org/ontology/ICD10CM/> {
#                 ?icd skos:notation ?icdCode ;
#                      skos:prefLabel ?ipl . .
#             }
#             bind(10 as ?icdVer)
#         }
#         union
#         {
#             graph <http://purl.bioontology.org/ontology/ICD9CM/> {
#                 ?icd skos:notation ?icdCode ;
#                      skos:prefLabel ?ipl .
#             }
#             bind(9 as ?icdVer)
#         }
#     }
# }',
#   "mondo->trasntivie snomed->CUI->icd" = 'select distinct
# ?m
# # ?ml
# ?rewriteGraph ?assertedPredicate ?icdVer ?icdCode ?ipl
# # ?ipl
# ("mondo->snomed->CUI->icd" as ?pathFamily)
# where {
#     values ?icdCode { ${current.assembled} }
#     {
#         {
#             graph <http://purl.bioontology.org/ontology/ICD10CM/> {
#                 ?icd skos:notation ?icdCode ;
#                      skos:prefLabel ?ipl .
#             }
#             bind(10 as ?icdVer)
#         }
#         union
#         {
#             graph <http://purl.bioontology.org/ontology/ICD9CM/> {
#                 ?icd skos:notation ?icdCode ;
#                      skos:prefLabel ?ipl .
#             }
#             bind(9 as ?icdVer)
#         }
#     }
#     graph <http://example.com/resource/materializedCui> {
#         ?icd mydata:materializedCui ?cui .
#         ?snomed mydata:materializedCui ?cui .
#     }
#     graph <http://purl.bioontology.org/ontology/SNOMEDCT_US/> {
#         ?snomed a owl:Class
#     }
#     graph <http://example.com/resource/SnomedDiseaseTransitiveSubClasses> {
#         ?snomed rdfs:subClassOf ?presnomed
#     }
#     graph ?rewriteGraph {
#         ?m ?assertedPredicate ?presnomed
#     }
#     graph <http://example.com/resource/MondoTransitiveSubClasses> {
#         ?m rdfs:subClassOf <http://purl.obolibrary.org/obo/MONDO_0000001> .
#     }
#     graph <http://purl.obolibrary.org/obo/mondo.owl> {
#         ?m rdfs:label ?ml
#     }
# }',
#   "mondo->trasntivie snomed->NLM mappings->icd9" = 'select
# distinct
# ?m ?rewriteGraph ?assertedPredicate (concat("ICD", ?icdVer, "CM:") as ?versionedIcd) ?icdCode ?ipl ("mondo->snomed->NLM mappings->icd9" as ?pathFamily)
# where {
#     values ?icdCode { ${current.assembled} }
#   {
#             graph <http://purl.bioontology.org/ontology/ICD9CM/> {
#                 ?icd skos:notation ?icdCode ;
#                      skos:prefLabel ?ipl .
#             }
#             bind(9 as ?icdVer)
#   }
#       graph <https://www.nlm.nih.gov/research/umls/mapping_projects/icd9cm_to_snomedct.html> {
#         # this grpah has lots of filterable properties like
#         # mydata:AVG_USAGE, mydata:CORE_USAGE, mydata:IN_CORE, mydata:IS_1-1MAP
#         ?icd9cm_to_snomedct mydata:SNOMED_CID ?CID ;
#                             mydata:ICD_CODE ?icdCode .
#       }
#         graph <http://purl.bioontology.org/ontology/SNOMEDCT_US/> {
#         ?snomed a owl:Class ;
#                 skos:notation ?CID .
#         }
#         graph <http://example.com/resource/SnomedDiseaseTransitiveSubClasses> {
#         ?snomed rdfs:subClassOf ?presnomed
#         }
#         graph ?rewriteGraph {
#         ?m ?assertedPredicate ?presnomed
#     }
#
#     graph <http://example.com/resource/MondoTransitiveSubClasses> {
#         ?m rdfs:subClassOf <http://purl.obolibrary.org/obo/MONDO_0000001> .
#     }
# }'
# )


###   ###   ###


query.templates <- list(
  "mondo->icd" = 'select distinct ?mid ?ml
  ("mondo->icd" as ?pathFamily) ?assertionOrientation ?assertedPredicate
  (concat("ICD", str(?icdVer), "CM:",?icdCode) as ?versionedIcd)  (str(?ipl) as ?iplstr)
where {
    values ?icdCode { ${current.assembled} }
    graph <http://example.com/resource/MondoTransitiveSubClasses> {
        ?m rdfs:subClassOf <http://purl.obolibrary.org/obo/MONDO_0000001> .
    }
    graph <http://purl.obolibrary.org/obo/mondo.owl> {
        ?m rdfs:label ?ml ;
           <http://www.geneontology.org/formats/oboInOwl#id> ?mid
    }
    graph ?rewriteGraph {
        ?m ?assertedPredicate ?icd
    }
    graph <http://example.com/resource/AssertionOrientations> {
        ?rewriteGraph rdfs:label ?assertionOrientation .
    }
    {
        {
            graph <http://purl.bioontology.org/ontology/ICD10CM/> {
                ?icd skos:notation ?icdCode ;
                     skos:prefLabel ?ipl  .
            }
            bind(10 as ?icdVer)
        }
        union
        {
            graph <http://purl.bioontology.org/ontology/ICD9CM/> {
                ?icd skos:notation ?icdCode ;
                     skos:prefLabel ?ipl  .
            }
            bind(9 as ?icdVer)
        }
    }
}',
  "mondo->CUI->icd" = 'select distinct ?mid ?ml
  ("mondo->CUI->icd" as ?pathFamily) ?assertionOrientation ?assertedPredicate
  (concat("ICD", str(?icdVer), "CM:",?icdCode) as ?versionedIcd)  (str(?ipl) as ?iplstr)
where {
    values ?icdCode { ${current.assembled} }
    graph <http://example.com/resource/MondoTransitiveSubClasses> {
        ?m rdfs:subClassOf <http://purl.obolibrary.org/obo/MONDO_0000001> .
    }
    graph <http://purl.obolibrary.org/obo/mondo.owl> {
        ?m rdfs:label ?ml ;
           <http://www.geneontology.org/formats/oboInOwl#id> ?mid
    }
    graph ?rewriteGraph {
        ?m ?assertedPredicate ?cui
    }
    graph <http://example.com/resource/AssertionOrientations> {
        ?rewriteGraph rdfs:label ?assertionOrientation .
    }
    graph <http://example.com/resource/materializedCui> {
        ?cui a mydata:materializedCui .
        ?icd mydata:materializedCui ?cui .
    }
    {
        {
            graph <http://purl.bioontology.org/ontology/ICD10CM/> {
                ?icd skos:notation ?icdCode ;
                     skos:prefLabel ?ipl  .
            }
            bind(10 as ?icdVer)
        }
        union
        {
            graph <http://purl.bioontology.org/ontology/ICD9CM/> {
                ?icd skos:notation ?icdCode ;
                     skos:prefLabel ?ipl  .
            }
            bind(9 as ?icdVer)
        }
    }
}',
  "mondo->snomed->CUI->icd" = 'select distinct ?mid ?ml
  ("mondo->snomed->CUI->icd" as ?pathFamily) ?assertionOrientation ?assertedPredicate
  (concat("ICD", str(?icdVer), "CM:",?icdCode) as ?versionedIcd)  (str(?ipl) as ?iplstr)
where {
    values ?icdCode { ${current.assembled} }
    {
        {
            graph <http://purl.bioontology.org/ontology/ICD10CM/> {
                ?icd skos:notation ?icdCode ;
                     skos:prefLabel ?ipl .
            }
            bind(10 as ?icdVer)
        }
        union
        {
            graph <http://purl.bioontology.org/ontology/ICD9CM/> {
                ?icd skos:notation ?icdCode ;
                     skos:prefLabel ?ipl .
            }
            bind(9 as ?icdVer)
        }
    }
    graph <http://example.com/resource/materializedCui> {
        ?icd mydata:materializedCui ?cui .
        ?snomed mydata:materializedCui ?cui .
    }
    graph <http://purl.bioontology.org/ontology/SNOMEDCT_US/> {
        ?snomed a owl:Class
    }
    graph ?rewriteGraph {
        ?m ?assertedPredicate ?snomed
    }
    graph <http://example.com/resource/AssertionOrientations> {
        ?rewriteGraph rdfs:label ?assertionOrientation .
    }
    graph <http://example.com/resource/MondoTransitiveSubClasses> {
        ?m rdfs:subClassOf <http://purl.obolibrary.org/obo/MONDO_0000001> .
    }
    graph <http://purl.obolibrary.org/obo/mondo.owl> {
        ?m rdfs:label ?ml ;
           <http://www.geneontology.org/formats/oboInOwl#id> ?mid
    }
}',
  "mondo->snomed->NLM mappings->icd9" = 'select distinct ?mid ?ml
  ("mondo->snomed->NLM mappings->icd9" as ?pathFamily) ?assertionOrientation ?assertedPredicate
  (concat("ICD", str(?icdVer), "CM:", ?icdCode) as ?versionedIcd)  (str(?ipl) as ?iplstr)
where {
    values ?icdCode { ${current.assembled} }
  {
            graph <http://purl.bioontology.org/ontology/ICD9CM/> {
                ?icd skos:notation ?icdCode ;
                     skos:prefLabel ?ipl  .
            }
            bind(9 as ?icdVer)
  }
      graph <https://www.nlm.nih.gov/research/umls/mapping_projects/icd9cm_to_snomedct.html> {
        # this grpah has lots of filterable properties like
        # mydata:AVG_USAGE, mydata:CORE_USAGE, mydata:IN_CORE, mydata:IS_1-1MAP
        ?icd9cm_to_snomedct mydata:SNOMED_CID ?CID ;
                            mydata:ICD_CODE ?icdCode .
      }
        graph <http://purl.bioontology.org/ontology/SNOMEDCT_US/> {
        ?snomed a owl:Class ;
                skos:notation ?CID .
        }
        graph ?rewriteGraph {
        ?m ?assertedPredicate ?snomed
        }
    graph <http://example.com/resource/AssertionOrientations> {
        ?rewriteGraph rdfs:label ?assertionOrientation .
    }

    graph <http://example.com/resource/MondoTransitiveSubClasses> {
        ?m rdfs:subClassOf <http://purl.obolibrary.org/obo/MONDO_0000001> .
    }
    graph <http://purl.obolibrary.org/obo/mondo.owl> {
        ?m rdfs:label ?ml ;
           <http://www.geneontology.org/formats/oboInOwl#id> ?mid
    }
}'
)

chunk.count <- length(the.chunks)


outer <-
  lapply(names(query.templates), function(current.template.name) {
    # current.template.name <- "mondo->icd"
    # print(current.template.name)
    
    # 1:chunk.count
    inner <-
      lapply(1:chunk.count, function(chunk.index) {
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
          )
        )
        
        return(sparql.res.list$results)
      })
    inner <- do.call(rbind.data.frame, inner)
    return(inner)
  })

outer <- do.call(rbind.data.frame, outer)

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

hist(mappings.per.path$Freq, breaks = 99)
