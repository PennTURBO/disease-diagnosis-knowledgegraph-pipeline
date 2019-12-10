library(stringr)
library(data.table)
library(readr)
library(dplyr)
library(RPostgres)
library(data.table)
library(DBI)

source("turbo_graphdb_setup.R")

selected.postgres.configuration <-
  config::get(config = "dd_postgres_reverse",
              file = "disease_diagnosis.yaml")

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

query.templates <- list(
  "mondo->icd" = 'select
distinct
?mid ?ml ?approxDepth
("mondo->icd" as ?pathFamily) ?assertionOrientation ?assertedPredicate
(concat(?icdVer,?icdCode) as ?versionedIcd)  (str(?ipl) as ?iplstr)
where {
    values ?mRequest { ${current.assembled} }
    graph <http://example.com/resource/MondoTransitiveSubClasses> {
        ?m rdfs:subClassOf ?mRequest
    }
    graph <http://purl.obolibrary.org/obo/mondo.owl> {
        ?m <http://www.geneontology.org/formats/oboInOwl#id> ?mid ;
           rdfs:label ?ml .
    }
    graph mydata:mondoHopCounts {
        ?m mydata:hopCount ?approxDepth
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
    {
        {
            graph <http://purl.bioontology.org/ontology/ICD9CM/> {
                ?icd a owl:Class
            }
            graph <http://example.com/resource/ICD9DiseaseInjuryTransitiveSubClasses> {
                ?icdLeaf rdfs:subClassOf ?icd
            }
            graph <http://purl.bioontology.org/ontology/ICD9CM/> {
                ?icdLeaf skos:notation ?icdCode ;
                         skos:prefLabel ?ipl .
            }
            bind("ICD9CM:" as ?icdVer)
        }
        union
        {
            graph <http://purl.bioontology.org/ontology/ICD10CM/> {
                ?icd a owl:Class
            }
            graph <http://example.com/resource/ICD10TransitiveSubClasses> {
                ?icdLeaf rdfs:subClassOf ?icd
            }
            graph <http://purl.bioontology.org/ontology/ICD10CM/> {
                ?icdLeaf skos:notation ?icdCode ;
                         skos:prefLabel ?ipl .
            }
            bind("ICD10CM:" as ?icdVer)
        }
    }
}',
  "mondo->CUI->icd" = 'select
distinct
?mid ?ml ?approxDepth
("mondo->CUI->icd" as ?pathFamily) ?assertionOrientation ?assertedPredicate
(concat(?icdVer,?icdCode) as ?versionedIcd)  (str(?ipl) as ?iplstr)
where {
    values ?mRequest { ${current.assembled} }
    graph <http://example.com/resource/MondoTransitiveSubClasses> {
        ?m rdfs:subClassOf ?mRequest
    }
    graph <http://purl.obolibrary.org/obo/mondo.owl> {
        ?m <http://www.geneontology.org/formats/oboInOwl#id> ?mid ;
           rdfs:label ?ml .
    }
    graph mydata:mondoHopCounts {
        ?m mydata:hopCount ?approxDepth
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
    graph <http://example.com/resource/materializedCui> {
        ?icd mydata:materializedCui ?cui .
    }
    {
        {
            graph <http://purl.bioontology.org/ontology/ICD9CM/> {
                ?icd a owl:Class
            }
            graph <http://example.com/resource/ICD9DiseaseInjuryTransitiveSubClasses> {
                ?icdLeaf rdfs:subClassOf ?icd
            }
            graph <http://purl.bioontology.org/ontology/ICD9CM/> {
                ?icdLeaf skos:notation ?icdCode ;
                         skos:prefLabel ?ipl .
            }
            bind("ICD9CM:" as ?icdVer)
        }
        union
        {
            graph <http://purl.bioontology.org/ontology/ICD10CM/> {
                ?icd a owl:Class
            }
            graph <http://example.com/resource/ICD10TransitiveSubClasses> {
                ?icdLeaf rdfs:subClassOf ?icd
            }
            graph <http://purl.bioontology.org/ontology/ICD10CM/> {
                ?icdLeaf skos:notation ?icdCode ;
                         skos:prefLabel ?ipl .
            }
            bind("ICD10CM:" as ?icdVer)
        }
    }
}',
  "mondo->snomed->CUI->icd" = 'select
distinct
?mid ?ml ?approxDepth
("mondo->snomed->CUI->icd" as ?pathFamily) ?assertionOrientation ?assertedPredicate
(concat(?icdVer,?icdCode) as ?versionedIcd) (str(?ipl) as ?iplstr)
# these wouldnt be reported
# just for qc
#?snomed  ?sParent
where {
    values ?mRequest { ${current.assembled} }
    graph <http://example.com/resource/MondoTransitiveSubClasses> {
        ?m rdfs:subClassOf ?mRequest
    }
    graph <http://purl.obolibrary.org/obo/mondo.owl> {
        ?m <http://www.geneontology.org/formats/oboInOwl#id> ?mid ;
           rdfs:label ?ml .
    }
    graph mydata:mondoHopCounts {
        ?m mydata:hopCount ?approxDepth
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
    graph <http://purl.bioontology.org/ontology/SNOMEDCT_US/> {
        ?sParent a owl:Class .
    }
    graph <http://example.com/resource/SnomedDiseaseTransitiveSubClasses> {
        ?snomed rdfs:subClassOf ?sParent .
    }
    graph <http://example.com/resource/materializedCui> {
        ?snomed mydata:materializedCui ?cui .
        ?icd mydata:materializedCui ?cui .
    }
    {
        {
            graph <http://purl.bioontology.org/ontology/ICD9CM/> {
                ?icd a owl:Class
            }
            graph <http://example.com/resource/ICD9DiseaseInjuryTransitiveSubClasses> {
                ?icdLeaf rdfs:subClassOf ?icd
            }
            graph <http://purl.bioontology.org/ontology/ICD9CM/> {
                ?icdLeaf skos:notation ?icdCode ;
                         skos:prefLabel ?ipl .
            }
            bind("ICD9CM:" as ?icdVer)
        }
        union
        {
            graph <http://purl.bioontology.org/ontology/ICD10CM/> {
                ?icd a owl:Class
            }
            graph <http://example.com/resource/ICD10TransitiveSubClasses> {
                ?icdLeaf rdfs:subClassOf ?icd
            }
            graph <http://purl.bioontology.org/ontology/ICD10CM/> {
                ?icdLeaf skos:notation ?icdCode ;
                         skos:prefLabel ?ipl .
            }
            bind("ICD10CM:" as ?icdVer)
        }
    }
}',
  "mondo->snomed,transitive->NLM mappings->icd9" = 'select
  distinct
?mid ?ml ?approxDepth
("mondo->snomed,transitive->NLM mappings->icd9" as ?pathFamily) ?assertionOrientation ?assertedPredicate
(concat(?icdVer,?icdCode) as ?versionedIcd) (str(?ipl) as ?iplstr)
# these wouldnt be reported
  # just for qc
  #?snomed  ?sParent
  where {
    values ?mRequest { ${current.assembled} }
    graph <http://example.com/resource/MondoTransitiveSubClasses> {
      ?m rdfs:subClassOf ?mRequest
    }
    graph <http://purl.obolibrary.org/obo/mondo.owl> {
      ?m <http://www.geneontology.org/formats/oboInOwl#id> ?mid ;
      rdfs:label ?ml .
    }
    graph mydata:mondoHopCounts {
      ?m mydata:hopCount ?approxDepth
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
    graph <http://purl.bioontology.org/ontology/SNOMEDCT_US/> {
      ?sParent a owl:Class .
    }
    graph <http://example.com/resource/SnomedDiseaseTransitiveSubClasses> {
      ?snomed rdfs:subClassOf ?sParent .
    }
    graph <https://www.nlm.nih.gov/research/umls/mapping_projects/icd9cm_to_snomedct.html> {
      ?icd <https://www.nlm.nih.gov/research/umls/mapping_projects/icd9cm_to_snomedct.html> ?snomed
    }
    {
      graph <http://purl.bioontology.org/ontology/ICD9CM/> {
        ?icd a owl:Class
      }
      graph <http://example.com/resource/ICD9DiseaseInjuryTransitiveSubClasses> {
        ?icdLeaf rdfs:subClassOf ?icd
      }
      graph <http://purl.bioontology.org/ontology/ICD9CM/> {
        ?icdLeaf skos:notation ?icdCode ;
        skos:prefLabel ?ipl .
      }
      bind("ICD9CM:" as ?icdVer)
    }
  }'
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

outer <-
  lapply(names(query.templates), function(current.template.name) {
    # current.template.name <- "mondo->icd"
    # print(current.template.name)
    
    print(paste0(Sys.time(),
                 ": ",
                 current.template.name))
    current.assembled <-
      "<http://purl.obolibrary.org/obo/MONDO_0008903>"
    
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
        write.result <-
          dbWriteTable(pg.RPostgres,
                       dd.table.name,
                       temp,
                       overwrite = FALSE,
                       append = TRUE)
        
      }
    }
    
  })

outer <-
  dbGetQuery(pg.RPostgres, paste0("select * from ", dd.table.name))

write.csv(outer, "lm-ao-lung-cancers-mam.csv")

lungCancerMappings_withCSR <-
  read_csv("lungCancerMappings_withCSR.csv.csv")
lungCancerMappings_withCSR$versionedIcd <-
  paste0(lungCancerMappings_withCSR$icdVer,
         ":",
         lungCancerMappings_withCSR$icdCode)

lungCancerMappings_withCSR$mid <-
  sub(pattern = "http://purl.obolibrary.org/obo/MONDO_",
      replacement = "MONDO:",
      x = lungCancerMappings_withCSR$mondoSub)

h.frame <-
  unique(lungCancerMappings_withCSR[, c("mid", "versionedIcd")])

m.frame <- unique(outer[, c("mid", "versionedIcd")])

joined.anti <- unique(anti_join(m.frame, h.frame))

ja.icds <- unique(joined.anti$versionedIcd)

h.disputed <-
  lungCancerMappings_withCSR[lungCancerMappings_withCSR$versionedIcd %in% ja.icds , ]

m.disputed <- outer[outer$versionedIcd %in% ja.icds , ]

h.icds <-
  sort(unique(as.character(
    lungCancerMappings_withCSR$versionedIcd
  )))

m.icds  <-
  sort(unique(as.character(outer$versionedIcd)))

setdiff(h.icds, m.icds)
setdiff(m.icds, h.icds)


write.csv(h.disputed, "h_disputed.csv")
write.csv(m.disputed, "m_disputed.csv")
