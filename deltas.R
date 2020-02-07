library(readr)

load("~/icd_input_results_201912081757.Rdata")

obj.list <- ls()
obj.list <- setdiff(obj.list, "outer")
rm(list = obj.list)

lung_cancer_axioms <-
  read_csv("lung_cancer_axioms.csv")

lungCancerMappings_withCSR <-
  read_csv("lungCancerMappings_withCSR.csv.csv")

# based on arnurag's icd input
simple_mondo_axiom_list_tidied <-
  read_csv("simple_mondo_axiom_list_tidied.csv")

anurag_icd_sparqlResults <-
  read_csv("~/anurag_icd_sparqlResults.csv")

anurag_icd_sparqlResults$versionedIcd <-
  sub(pattern = "http://graphBuilder.org/",
      replacement = "",
      x = anurag_icd_sparqlResults$icdVer)

anurag_icd_sparqlResults$versionedIcd <-
  paste0(toupper(anurag_icd_sparqlResults$versionedIcd), "CM:")

anurag_icd_sparqlResults$versionedIcd <-
  paste0(anurag_icd_sparqlResults$versionedIcd,
         anurag_icd_sparqlResults$icdCode)

anurag_icd_sparqlResults$mid <-
  sub(pattern = "http://purl.obolibrary.org/obo/MONDO_",
      replacement = "MONDO:",
      x = anurag_icd_sparqlResults$mondoSub)


icd_code_list <-
  read_delim(file = "Anurag/icd_code_list.txt",
             delim = "\t",
             col_names = FALSE)

requests <- sort(unique(as.character(icd_code_list$X1)))

h.delivered <-
  sort(unique(as.character(anurag_icd_sparqlResults$icdCode)))

h.intersect <- intersect(requests, h.delivered)

hr.only <- setdiff(requests, h.delivered)
hd.only <- setdiff(h.delivered, requests)

m.delivered <- sort(unique(as.character(outer$versionedIcd)))
m.delivered <-
  sub(pattern = "^.*:",
      replacement = "",
      x = m.delivered)

m.intersect <- intersect(requests, m.delivered)

mr.only <- setdiff(requests, m.delivered)
md.only <- setdiff(m.delivered, requests)


length(requests)
length(hr.only)
length(h.delivered)
length(h.intersect)
length(hd.only)
length(mr.only)
length(m.delivered)
length(m.intersect)
length(md.only)

# write_csv(outer, "MAM_Anurag_icds_to_mondos_2019.csv")

# i renamed icd_report.rar as icd_report_Hayden_ICD_input_201912111155.rar
icd_report <- read.csv("~/icd_report.csv", stringsAsFactors = FALSE)

icd_report$mid <-
  sub(pattern = "http://purl.obolibrary.org/obo/MONDO_",
      replacement = "MONDO:",
      x = icd_report$mondoSub)


icd_report$versionedIcd <-
  sub(pattern = "http://purl.bioontology.org/ontology/",
      replacement = "",
      x = icd_report$icdLeaf)

icd_report$versionedIcd <-
  sub(pattern = "/",
      replacement = ":",
      x = icd_report$versionedIcd)

icd_report$bareIcd <-
  sub(pattern = "^.*:",
      replacement = "",
      x = icd_report$versionedIcd)


# icd_report$versionedIcd <-
#   paste0(toupper(icd_report$versionedIcd), "CM:")
#
# icd_report$versionedIcd <-
#   sub(pattern = "http://graphBuilder.org/",
#       replacement = "",
#       x = icd_report$icdVer)

requests <- sort(unique(as.character(icd_code_list$X1)))

h.delivered <-
  sort(unique(as.character(icd_report$bareIcd)))

icd_report$versionedIcd <-
  paste0(icd_report$versionedIcd, icd_report$bareIcd)

h.intersect <- intersect(requests, h.delivered)

hr.only <- setdiff(requests, h.delivered)
hd.only <- setdiff(h.delivered, requests)

m.delivered <- sort(unique(as.character(outer$versionedIcd)))
m.delivered <-
  sub(pattern = "^.*:",
      replacement = "",
      x = m.delivered)

m.intersect <- intersect(requests, m.delivered)

mr.only <- setdiff(requests, m.delivered)
md.only <- setdiff(m.delivered, requests)


length(requests)
length(hr.only)
length(h.delivered)
length(h.intersect)
length(hd.only)
length(mr.only)
length(m.delivered)
length(m.intersect)
length(md.only)

h.frame <-
  unique(icd_report[, c("mid", "versionedIcd")])
h.frame <- h.frame[order(h.frame$versionedIcd, h.frame$mid), ]

m.frame <- unique(outer[, c("mid", "versionedIcd")])
m.frame <- m.frame[order(m.frame$versionedIcd, m.frame$mid), ]

write_csv(h.frame, "h_mappings.csv")
write_csv(m.frame, "m_mappings.csv")

m.h.joined.anti <- unique(dplyr::anti_join(m.frame, h.frame))
h.m.joined.anti <- unique(dplyr::anti_join(h.frame, m.frame))

nrow(m.h.joined.anti)
nrow(h.m.joined.anti)

h.only <- unique(dplyr::left_join(joined.anti, h.frame))
m.only <- unique(dplyr::left_join(joined.anti, m.frame))
