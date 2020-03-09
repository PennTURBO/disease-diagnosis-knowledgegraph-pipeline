
install.packages("rJava") # if not present already
library(rJava)
install.packages("devtools") # if not present already
library(devtools)
install_github("egonw/rrdf", subdir="rrdflibs")
install_github("egonw/rrdf", subdir="rrdf", build_vignettes = FALSE)