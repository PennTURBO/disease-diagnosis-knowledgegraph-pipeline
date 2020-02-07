N <- nrow(unique.associations)
m.freqs <- MonDO.table
m.freqs$m.freq <- m.freqs$m / (sum(m.freqs$m))

i.freqs <- table(unique.associations$ICD.code)
i.freqs <-
  cbind.data.frame(names(i.freqs), as.numeric(i.freqs))
names(i.freqs) <- c("ICD.code", "count")
i.freqs$i.freq <- i.freqs$count / (sum(i.freqs$count))

merged <- merge(unique.associations, m.freqs)

merged <- merge(merged, i.freqs)

merged$std.resid <-
  (1 - (N * merged$i.freq * merged$m.freq)) / sqrt(N)

merged <-
  merged[, c("ICD.code",
             "MonDO.term",
             "ICD.label",
             "MonDO.label",
             "std.resid")]

aggdata <- aggregate(
  merged$std.resid,
  by = list(outer.result$ICD.code),
  FUN = max,
  na.rm = TRUE
)
names(aggdata) <- c("ICD.code", "std.resid")

highest.resid <- merge(x = merged, y = aggdata)


crossref <-
  merge(
    x = outer.result,
    y = merged,
    by.x = c("ICD.code", "MonDO.term"),
    by.y = c("ICD.code", "MonDO.term")
  )
