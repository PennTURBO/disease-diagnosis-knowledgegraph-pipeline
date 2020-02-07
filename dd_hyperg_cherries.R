# PRE december 11th
#I should make sure I'm using the right files/same files that you are expecting...
# input = icd_code_list.txt with 26450 lines
#your newest output for Anurag: 
# anurag_icd_sparqlResults.csv with 347342 lines
# Hayden Freedman: Pretty sure we used different input, I used the ICD code list from the report, not the text file
# icd_report.csv

###


# rm(list = ls())

# "outer" is all mappings,
#   by Mark's Hayden-like, but non-materialized query
#   and is NOT leaf constrained
#   ie it includes all mondo terms up to but not including "diseases and disorders"
# load("~/icd_input_results_201912081757.Rdata")
# rm(list = setdiff(ls(), "outer"))
# save.image("mam_outer_mappings.Rdata")

load("mam_outer_mappings.Rdata")

outer$mid <- as.character(outer$mid)
outer$versionedIcd <- as.character(outer$versionedIcd)

the.maps <- outer[, c("mid",  "versionedIcd")]

real.unique.maps <-
  unique(outer[, c("mid",  "ml", "versionedIcd", "iplstr")])

urn.ball.count <- nrow(the.maps)

urn.m.tab <- table(the.maps$mid)
urn.m.tab <-
  cbind.data.frame(names(urn.m.tab), as.numeric(urn.m.tab))
names(urn.m.tab) <- c("m.term", "i.count")
urn.m.tab$m.term <- as.character(urn.m.tab$m.term)
urn.m.tab$remainder <- urn.ball.count - urn.m.tab$i.count

# str(urn.m.tab)

# i.tab <- table(the.maps$versionedIcd)
# i.tab <- cbind.data.frame(names(i.tab), as.numeric(i.tab))
# names(i.tab) <- c("i.term", "m.count")
# i.tab$remainder <- urn.ball.count - i.tab$m.count

# current.i <- "ICD9CM:250.4"
#
# # current.i <- "ICD9CM:002.0"

# i.list <- sort(as.character(
# c(
#   "ICD9CM:250.4" ,
#   "ICD9CM:002.0",
#   "ICD9CM:112.2",
#   "ICD9CM:112.X",
#   "ICD9CM:102.2"
# )
# ))

# i.list <-
#   sample(the.maps$versionedIcd,
#          size = 99999,
#          replace = FALSE)
#
# i.list <- unique(sort(c(
#   i.list,
#   c(
#     "ICD9CM:250.4" ,
#     "ICD9CM:002.0",
#     "ICD9CM:112.2",
#     "ICD9CM:112.X",
#     "ICD9CM:102.2"
#   )
# )))

# current.i <- "ICD9CM:112.X"

i.list <- sort(unique(the.maps$versionedIcd))

outerres <- lapply(i.list, function(current.i) {
  print(paste0(current.i))
  filtered <- the.maps[the.maps$versionedIcd == current.i , ]
  unique.filtered <- unique(filtered)
  filtered$mid <- as.character(filtered$mid)
  filtered$versionedIcd <- as.character(filtered$versionedIcd)
  if (is.data.frame(filtered) && nrow(filtered) > 0) {
    # print("hello")
    m.list <- unique(as.character(filtered$mid))
    
    local.table <- table(filtered$mid)
    local.table <-
      cbind.data.frame(names(local.table), as.numeric(local.table))
    names(local.table) <- c("m.term", "i.count")
    local.table$m.term <- as.character(local.table$m.term)
    
    # # sorting fouls up the reults ?!
    # m.list <- sort(m.list)
    applyres <- lapply(m.list, function(current.m) {
      # print(paste0(current.i, " vs ", current.m))
      
      # current.m <- "MONDO:0005619"
      
      q <- local.table$i.count[local.table$m.term == current.m]
      
      m <- urn.m.tab$i.count[urn.m.tab$m.term == current.m]
      n <- urn.m.tab$remainder[urn.m.tab$m.term == current.m]
      k <- nrow(filtered)
      pval <- phyper(
        q = 1,
        m = m,
        n = n,
        k = k,
        lower.tail = FALSE,
        log.p = FALSE
      )
      return(pval)
    })
    
  }
  
  if (length(applyres) > 0) {
    applyres <- do.call(rbind.data.frame, applyres)
    applyres <- cbind.data.frame(unique.filtered$mid , applyres)
    names(applyres) <- c("mid", "raw.lt.p")
    applyres$versionedIcd <- current.i
    
    return(applyres)
  }
  
})

outerres <- do.call(rbind.data.frame, outerres)

temp <- unique(real.unique.maps[, c("mid", "ml")])

outerres <- merge(x = outerres, y = temp)

temp <- unique(real.unique.maps[, c("versionedIcd", "iplstr")])

outerres <- merge(x = outerres, y = temp)

# all mappings with adj-p
outerres$fdr <- p.adjust(p = outerres$raw.lt.p, method = "fdr")

# lowest enrichment p-adj for each icd
aggdata <- aggregate(
  outerres$fdr,
  by = list(outerres$versionedIcd),
  FUN = min,
  na.rm = TRUE
)
names(aggdata) <- c("versionedIcd", "fdr")

merged <- merge(x = outerres, y = aggdata)

# highlights icds with multiple equally "good" mappings
n.best <- table(merged$versionedIcd)
n.best <- cbind.data.frame(names(n.best), as.numeric(n.best))
names(n.best) <- c("versionedIcd", "eq.best.mondo.ct")

n.best.summary <- table(n.best$eq.best.mondo.ct)
n.best.summary <-
  cbind.data.frame(as.numeric(as.character(names(n.best.summary))), as.numeric(n.best.summary))
names(n.best.summary) <- c("mapping.count", "icd.count")

# final with single best if possible
merged <- merge(x = merged, y = n.best)

###

icd_report <- read_csv("~/icd_report.csv")
icd_report$versionedIcd <-
  sub(pattern = "http://purl.bioontology.org/ontology/",
      replacement = "",
      x = icd_report$icdLeaf)

icd_report$versionedIcd <-
  sub(pattern = "/",
      replacement = ":",
      x = icd_report$versionedIcd)

icd_report$mid <-
  sub(pattern = "http://purl.obolibrary.org/obo/MONDO_",
      replacement = "MONDO:",
      x = icd_report$mondoSub)


icd_report <-
  icd_report[, c(
    "mondoLabel",
    "pathFamily",
    "assertionOrientation",
    "assertedPredicate",
    "icdLabel",
    "versionedIcd",
    "mid"
  )]

names(icd_report) <-
  c(
    "ml",
    "pathFamily",
    "assertionOrientation",
    "assertedPredicate",
    "iplstr",
    "versionedIcd",
    "mid"
  )

the.maps <- icd_report[, c("mid",  "versionedIcd")]

real.unique.maps <-
  unique(outer[, c("mid",  "ml", "versionedIcd", "iplstr")])