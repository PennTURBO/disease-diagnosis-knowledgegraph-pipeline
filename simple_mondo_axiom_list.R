library(readr)
library(data.table)
library(dplyr)
# library()

# requires setup from disease_diagnosis_dev.R

# 5+ minutes for query
# ~ 4 additional minutes for local socket "download" and parse into R data structure
#   might be faster with more RAM?

sparql.query <- "
select
distinct
#?m ?rewriteGraph ?assertedPredicate ?i10code
?m ?axPred ?apl ?axVal ?avl
where {
    graph <http://example.com/resource/MondoTransitiveSubClasses> {
        ?m rdfs:subClassOf <http://purl.obolibrary.org/obo/MONDO_0000001> .
    }
    graph <http://example.com/resource/MondoTransitiveSubClasses> {
        ?m rdfs:subClassOf ?msuper .
    }
    graph <http://example.com/resource/materializedSimpleMondoAxioms> {
        ?msuper ?axPred ?axVal
    }
    graph <http://purl.obolibrary.org/obo/mondo.owl> {
        optional {
            ?axPred rdfs:label ?apl .
        }
        optional {
            ?axVal rdfs:label ?avl .
        }
    }
}
"

sparql.query <- paste0(sparql.prefixes, sparql.query, "\n")

sparql.result <-
  SPARQL(
    url =  select.endpoint,
    query = sparql.query,
    curl_args = list(
      userpwd = paste0(api.user, ":", api.pass),
      httpauth = 1
    )
  )

sparql.result.results <- sparql.result$results

# tabulate (cast/melt acceptable efficiency?)

axcast <-
  dcast(
    data = setDT(sparql.result.results),
    formula =   axVal ~ axPred,
    fun.aggregate = length,
    value.var = 'm'
  )

ax.ranked.melt <- data.table::melt(axcast)

ax.ranked.melt <- ax.ranked.melt[ax.ranked.melt$value > 0 ,]

# tabulate source ontologies
# count data lost here
# but can be approximately recreated by tabulation
ax.terms <-
  unique(c(
    as.character(ax.ranked.melt$axVal),
    as.character(ax.ranked.melt$variable)
  ))

source.finder <- cbind.data.frame(
  c(
    "<http://purl.obolibrary.org/obo/UBERON",
    "<http://purl.obolibrary.org/obo/HP",
    "<http://purl.obolibrary.org/obo/GO",
    "<http://purl.obolibrary.org/obo/NCBITaxon",
    "<http://purl.obolibrary.org/obo/MONDO",
    "<http://purl.obolibrary.org/obo/CL",
    "<http://purl.obolibrary.org/obo/CHEBI",
    "<http://purl.obolibrary.org/obo/PR",
    "<http://purl.obolibrary.org/obo/ECTO",
    "<http://purl.obolibrary.org/obo/PATO",
    "<http://purl.obolibrary.org/obo/NCIT",
    "<http://purl.obolibrary.org/obo/ENVO",
    "<http://purl.obolibrary.org/obo/MFOMD",
    "<http://purl.obolibrary.org/obo/MF",
    "<http://purl.obolibrary.org/obo/NBO",
    "<http://purl.obolibrary.org/obo/SO",
    "<http://purl.obolibrary.org/obo/MFOEM",
    "<http://purl.obolibrary.org/obo/FOODON",
    "<http://identifiers.org/hgnc/",
    "<http://purl.obolibrary.org/obo/RO"
  ),
  c(
    "UBERON",
    "HP",
    "GO",
    "NCBITaxon",
    "MONDO",
    "CL",
    "CHEBI",
    "PR",
    "ECTO",
    "PATO",
    "NCIT",
    "ENVO",
    "MFOMD",
    "MF",
    "NBO",
    "SO",
    "MFOEM",
    "FOODON",
    "hgnc",
    "RO"
  )
)
names(source.finder) <- c("root", "abbreviation")

found.sources <-
  apply(
    X = source.finder,
    MARGIN = 1,
    FUN = function(current.fnr) {
      print(current.fnr[[1]])
      print(current.fnr[[2]])
      ax.terms <<- sub(
        pattern = paste0(current.fnr[[1]], ".*"),
        replacement = current.fnr[[2]],
        x = ax.terms
      )
    }
  )

at.table <- table(ax.terms)
at.table <- cbind.data.frame(names(at.table), as.numeric(at.table))


# fruit = http://purl.obolibrary.org/obo/PO_0009001
# realized in = http://purl.obolibrary.org/obo/BFO_0000054
# feces osmolality = http://purl.obolibrary.org/obo/OBA_1001084
# <http://identifiers.org/hgnc/6342> "KIT proto-oncogene, receptor tyrosine kinase" appears in 24 axioms

# Class: KIT
#
# Term IRI: http://purl.obolibrary.org/obo/OGG_3000003815
# Annotations
# has GO association: GO_0000187 (EC: IDA); GO_0001541 (EC: ISS); GO_0001669 (EC: IEA); GO_0002020 (EC: IEA); GO_0002318 (EC: IEA); GO_0002320 (EC: IEA); GO_0002327 (EC: ISS); GO_0002371 (EC: ISS); GO_0002551 (EC: IDA); GO_0004713 (EC: TAS, PMID: 1717985); GO_0004714 (EC: IDA); GO_0004716 (EC: IEA); GO_0005020 (EC: IEA); GO_0005515 (EC: IPI, PMID: 10377264); GO_0005524 (EC: IEA); GO_0005615 (EC: IDA, PMID: 14625290); GO_0005886 (EC: TAS); GO_0006687 (EC: IEA); GO_0006954 (EC: ISS); GO_0007165 (EC: TAS, PMID: 9990072); ... (Note: Only 20 GO IDs shown. See more from web page source or RDF output.)"
# has PubMed association: PMID: 1279499; 1279971; 1370874; 1371879; 1373482; 1375232; 1376329; 1377810; 1381360; 1712644; 1715789; 1717985; 1720553; 1721869; 2448137; 2474787; 3360448; 7479840; 7505199; 7506076; 7506248; 7507133; 7509796; 7514064; 7514077; 7520444; 7523381; 7523489; 7526158; 7527392; 7536744; 7537096; 7539802; 7680037; 7684496; 7687267; 7691885; 7693453; 8527164; 8589724; 8611693; 8647802; 8680409; 8751459; 8757502; 8950973; 9027509; 9029028; 9038210; 9092574; ... (Note: Only 50 PMIDs shown. See more from web page source or RDF output.)
# definition editor: Bin Zhao, Yue Liu, Oliver He
# NCBI GeneID: 3815
# alternative term: C-Kit; PBT; SCFR; CD117
# chromosome ID of gene: 4
# database_cross_reference: MIM:164920; Vega:OTTHUMG00000128713; HGNC:6342; Ensembl:ENSG00000157404; HPRD:01287

# label (query ontobee?)
label.results <-
  lapply(source.finder$abbreviation, function(current.abbreviation) {
    print(paste0(
      '<http://purl.obolibrary.org/obo/merged/',
      current.abbreviation,
      '>'
    ))
    sparql.query <- paste0(
      '
  select *
  where {
    graph <http://purl.obolibrary.org/obo/merged/',
      current.abbreviation,
      '> {
      ?s <http://www.w3.org/2000/01/rdf-schema#label> ?l
      bind(str(?l) as ?lstr)
    }}'
    )
    
    sparql.result <-
      SPARQL(url =  "http://sparql.hegroup.org/sparql/",
             query = sparql.query)
    
    temp <- sparql.result$results
    
    return(temp)
    
  })

label.results <- do.call(rbind.data.frame, label.results)
dput(names(label.results))
label.results <- unique(label.results[, c("s", "lstr")])

print(nrow(label.results))
print(length(unique(label.results$s)))
## QC
hist(log10(ax.ranked.melt$value), breaks = 99)

# limit to 10+?

ax.ranked.melt <- ax.ranked.melt[ax.ranked.melt$value > 10 , ]
names(ax.ranked.melt) <- c("axVal", "axProp", "count")
ax.ranked.melt$axProp <- as.character(ax.ranked.melt$axProp)
ax.ranked.melt <- ax.ranked.melt[, c("axProp", "axVal", "count")]

# post-prefix terms?

joined <-
  left_join(
    ax.ranked.melt,
    label.results,
    by = c("axProp" = "s"),
    suffix = c("", ".prop")
  )


joined <-
  left_join(
    joined,
    label.results,
    by = c("axVal" = "s"),
    suffix = c("", ".val")
  )
