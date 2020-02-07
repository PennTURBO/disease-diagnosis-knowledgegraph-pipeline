# "outer" is all mappings,
#   by Mark's Hayden-like, but non-materialized query
#   and is NOT leaf constrained
#   ie it includes all mondo terms up to but not including "diseases and disorders"
load("~/icd_input_results_201912081757.Rdata")
rm(list = setdiff(ls(), "outer"))

# mid = mondo id
# ml = mondo label
# iplstr = icd lablel

# I'm defining the backgorund as all of the unique pairing from an icd input to a mondo result
unique.maps <-
  unique(outer[, c("mid",  "ml", "versionedIcd", "iplstr")])

urn.ball.count <- nrow(unique.maps)

# here I count how often given mondo term appears in the background
#  ie for how many icd terms does it appear
m.tab <- table(unique.maps$mid)
m.tab <- cbind.data.frame(names(m.tab), as.numeric(m.tab))
names(m.tab) <- c("m.term", "i.count")
m.tab$m.term <- as.character(m.tab$m.term)

# if a given mondo term is the white ball in a given iteration,
#  then calculate the black balls
m.tab$remainder <- urn.ball.count - m.tab$i.count

# i.tab <- table(unique.maps$versionedIcd)
# i.tab <- cbind.data.frame(names(i.tab), as.numeric(i.tab))
# names(i.tab) <- c("i.term", "m.count")
# i.tab$remainder <- urn.ball.count - i.tab$m.count

icd.list <- sort(unique.maps$versionedIcd)

icd.list <- c("ICD9CM:002.0" , "ICD9CM:250.4")

loop.over.icds <-
  lapply(icd.list, function(current.i) {
    # current.i <- "ICD9CM:002.0"
    # current.i <- "ICD9CM:250.4"
    filtered <-
      unique.maps[unique.maps$versionedIcd == current.i ,]
    
    # what is the chance that a particular mondo term
    #   would be mapped to a given icd term
    #   by chance alone?
    loop.over.mondo <-
      lapply(sort(filtered$mid), function(current.m) {
        print(paste0(current.i, " vs ", current.m))
        m <- m.tab$i.count[m.tab$m.term == current.m]
        n <- m.tab$remainder[m.tab$m.term == current.m]
        k <- nrow(filtered)
        pval  <- phyper(
          q = 1,
          m = m,
          n = n,
          k = k,
          lower.tail = FALSE,
          log.p = FALSE
        )
        return(pval)
      })
    
    loop.over.mondo <- do.call(rbind.data.frame, loop.over.mondo)
    loop.over.mondo <-
      cbind.data.frame(filtered$mid , loop.over.mondo)
    names(loop.over.mondo) <- c("mid", "raw.lt.p")
    loop.over.mondo$versionedIcd <- current.i
    return(loop.over.mondo)
    
  })

# loop.over.icds <- loop.over.mondo

loop.over.icds  <- do.call(rbind.data.frame, loop.over.icds)

temp <- unique(unique.maps[, c("mid", "ml")])

loop.over.icds <- merge(x = loop.over.icds, y = temp)

temp <- unique(unique.maps[, c("versionedIcd", "iplstr")])

loop.over.icds <- merge(x = loop.over.icds, y = temp)
