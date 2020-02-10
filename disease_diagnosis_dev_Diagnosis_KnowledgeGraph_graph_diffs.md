```R
> print(disease_diagnosis_dev_only)
[1] "http://example.com/resource/ICD10CM_siblings"  "http://example.com/resource/ICD9CM_siblings"  
[3] "http://example.com/resource/mondoOriginals"    "http://example.com/resource/undefinedRewrites"
```

OK, these are all for non-destructive housekeeping

----

```R
> print(Diagnosis_KnowledgeGraph_only)
[1] "http://example.com/resource/AssertionOrientations"
```

Gives labels to the two orientation-wise graphs. Implementation: 

```SPARQL
PREFIX mydata: <http://example.com/resource/>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
insert data {
    graph mydata:AssertionOrientations {
        mydata:rewrites_MonDO_object rdfs:label "reverse" .
        mydata:rewrites_MonDO_subject rdfs:label "forward" .
    }
}
```
                                          
```R
[2] "http://example.com/resource/MondoTransitiveSimpleScoEqcAxioms"                                                                                   
[4] "http://example.com/resource/materializedVerySimpleMondoEquivalenceAxioms"
```
Look for separate script or SPARQL snippet ....`materializedVerySimpleMondoEquivalenceAxioms` is a supplement to `http://example.com/resource/materializedSimpleMondoAxioms`, and ...`MondoTransitiveSimpleScoEqcAxioms` applies the axiom materializations (including rare, syndromic, congenital...) to disease subclasses.

- OneNote
- GitHub
- local files
    - R
    - md
    - rq / sparql

```Bash
Mark Miller@DESKTOP-LA54B7U MINGW64 ~/disease_to_diagnosis_code (master)
$ ls *.R -lSrh
-rw-r--r-- 1 Mark Miller 197121  398 Jan 16 16:55 matrix_entropy.R
-rw-r--r-- 1 Mark Miller 197121 3.0K Dec 10 15:16 labeled_axiom_counts.R
-rw-r--r-- 1 Mark Miller 197121 3.9K Dec 11 15:10 turbo_graphdb_setup.R
-rw-r--r-- 1 Mark Miller 197121 4.4K Dec 11 15:10 deltas.R
-rw-r--r-- 1 Mark Miller 197121 4.5K Dec 11 15:10 notation_to_term.R
-rw-r--r-- 1 Mark Miller 197121 6.7K Dec  9 09:29 simple_mondo_axiom_list.R
-rw-r--r-- 1 Mark Miller 197121  13K Dec 10 15:16 dd_batched_values_reverse.R
-rw-r--r-- 1 Mark Miller 197121  15K Dec 10 15:16 dd_batched_values_reconcile.R
-rw-r--r-- 1 Mark Miller 197121  19K Dec 11 15:10 dd_batched_values.R
-rw-r--r-- 1 Mark Miller 197121  34K Dec  9 09:29 disease_diagnosis_dev.R
```


```R
[3] "http://example.com/resource/diseaseDepth"  
```
Executed with `https://github.com/PennTURBO/disease_to_diagnosis_code/blob/master/dist_from_MonDO_disease_root.R`... make sure this still works with the same configuration yaml file as `disease_diagnosis_dev`

```R                      
[5] "http://www.itmat.upenn.edu/biobank/cached_mondo_icd_mappings"                                  
[6] "http://www.itmat.upenn.edu/biobank/cached_mondo_icd_mappings_LEAFONLY"                         
[7] "http://www.itmat.upenn.edu/biobank/cached_mondo_icd_mappings_depthTimesMappingCountFormulaOnly"
[8] "http://www.itmat.upenn.edu/biobank/countIcdMappingsPerMondoTerm"
```

See Hayden, esp. for `http://www.itmat.upenn.edu/biobank/countIcdMappingsPerMondoTerm` 
