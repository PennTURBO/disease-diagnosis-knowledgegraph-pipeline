# Building TURBO disease diagnosis knowledge graph



## Prequisities 

This knowledge graph was last built with the following version of R

`R version 3.6.2 (2019-12-12) -- "Dark and Stormy Night"`

The script explicitly imports the following packages:

- library(config)
- library(httr)
- library(igraph)
- library(SPARQL)

The table below provides an elaboration on the dependencies of those explicit imports, in terms of base R and additional packages

| Package | Version | Depends    | Imports                                                      | License            | Built |
| ------- | ------- | ---------- | ------------------------------------------------------------ | ------------------ | ----- |
| config  | 0.3     | NA         | yaml (>= 2.1.13)                                             | GPL-3              | 3.6.2 |
| httr    | 1.4.1   | R (>= 3.2) | curl (>= 3.0.0), jsonlite, mime, openssl (>= 0.8), R6        | MIT + file LICENSE | 3.6.2 |
| igraph  | 1.2.4.2 | methods    | graphics, grDevices, magrittr, Matrix, pkgconfig (>= 2.0.0),stats, utils | GPL (>= 2)         | 3.6.0 |
| SPARQL  | 1.16    | XML, RCurl | NA                                                           | GPL-3              | 3.6.2 |

