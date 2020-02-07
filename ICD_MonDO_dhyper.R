

library(stringdist)

###   ###   ###

associations <- read.csv("associations.csv")

associations$MonDO.term <- as.character(associations$MonDO.term)
associations$ICD.code <- as.character(associations$ICD.code)

unique.associations <-
  unique(associations[, c("ICD.code", "ICD.label", "MonDO.term", "MonDO.label")])

urn.ball.count <- length(unique(unique.associations$ICD.code))

MonDO.table <- table(unique.associations$MonDO.term)
MonDO.table <-
  cbind.data.frame(names(MonDO.table), as.numeric(MonDO.table))
names(MonDO.table) <- c("MonDO.term", "m")
MonDO.table$MonDO.term <- as.character(MonDO.table$MonDO.term)
MonDO.table$n <- urn.ball.count - MonDO.table$m

ICD.list <- sort(unique(unique.associations$ICD.code))

outer.result <- lapply(ICD.list, function(current.i) {
  # current.i <- "ICD9CM:250.4"
  print(paste0(current.i))
  filtered <-
    unique.associations[unique.associations$ICD.code == current.i , ]
  filtered$MonDO.term <- as.character(filtered$MonDO.term)
  filtered$ICD.code <- as.character(filtered$ICD.code)
  if (is.data.frame(filtered) && nrow(filtered) > 0) {
    MonDO.list <- unique(as.character(filtered$MonDO.term))
    
    # # sorting fouls up the reults ?!
    # m.list <- sort(m.list)
    inner.result <- lapply(MonDO.list, function(current.m) {
      # current.m <- "MONDO:0005619"
      
      # drawing one ICD term... k will aways be 1
      # currently using unqiue associations... x will always be 1
      k <- 1
      x <- 1
      m <- MonDO.table$m[MonDO.table$MonDO.term == current.m]
      n <- MonDO.table$n[MonDO.table$MonDO.term == current.m]
      
      dval <- dhyper(
        x = x,
        m = m,
        n = n,
        k = k,
        log = TRUE
      )
      return(dval)
    })
    
  }
  
  if (length(inner.result) > 0) {
    inner.result <- do.call(rbind.data.frame, inner.result)
    inner.result <-
      cbind.data.frame(filtered$MonDO.term , inner.result)
    names(inner.result) <- c("MonDO.term", "hyperg.density")
    inner.result$ICD.code <- current.i
    
    return(inner.result)
  }
  
})

outer.result <- do.call(rbind.data.frame, outer.result)

temp <-
  unique(unique.associations[, c("MonDO.term", "MonDO.label")])

outer.result <- merge(x = outer.result, y = temp)

temp <- unique(unique.associations[, c("ICD.code", "ICD.label")])

outer.result <- merge(x = outer.result, y = temp)


###   ###   ###

aggdata <- aggregate(
  outer.result$hyperg.density,
  by = list(outer.result$ICD.code),
  FUN = min,
  na.rm = TRUE
)
names(aggdata) <- c("ICD.code", "hyperg.density")

lowest.density <- merge(x = outer.result, y = aggdata)

###   ###   ###

n.best <- table(lowest.density$ICD.code)
n.best <- cbind.data.frame(names(n.best), as.numeric(n.best))
names(n.best) <- c("ICD.code", "eq.best.mondo.ct")

n.best.summary <- table(n.best$eq.best.mondo.ct)
n.best.summary <-
  cbind.data.frame(as.numeric(as.character(names(n.best.summary))), as.numeric(n.best.summary))
names(n.best.summary) <- c("mapping.count", "icd.count")

lowest.density <- merge(x = lowest.density, y = n.best)

###   ###   ###

unique.label.pairs <-
  unique(unique.associations[, c("ICD.label", "MonDO.label")])
unique.label.pairs$ICD.label <-
  tolower(as.character(unique.label.pairs$ICD.label))
unique.label.pairs$MonDO.label <-
  tolower(as.character(unique.label.pairs$MonDO.label))

# doesn't take into consideration synonymy
distances <- stringdist(unique.label.pairs$ICD.label, unique.label.pairs$MonDO.label, method = "osa")

unique.label.pairs$distances <- distances

# Method name	Description
# osa	
#   Optimal string aligment, (restricted Damerau-Levenshtein distance).
# lv	
#   Levenshtein distance (as in R's native adist).
# dl	
#   Full Damerau-Levenshtein distance.
# hamming	
#   Hamming distance (a and b must have same nr of characters).
# lcs	
#   Longest common substring distance.
# qgram	
#    q-gram distance.
# cosine	
#   cosine distance between q-gram profiles
# jaccard	
#   Jaccard distance between q-gram profiles
# jw	
#   Jaro, or Jaro-Winker distance.

# apply this to multiple nodes?
# https://stackoverflow.com/questions/23510851/how-to-get-least-common-subsumer-in-ontology-using-sparql-query
