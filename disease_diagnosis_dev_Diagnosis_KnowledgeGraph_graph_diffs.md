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
Look for separate script or SPARQL snippet. These are probably refinements of `http://example.com/resource/materializedSimpleMondoAxioms`

```R
[3] "http://example.com/resource/diseaseDepth"  
```
Look for separate script or SPARQL snippet

```R                      
[5] "http://www.itmat.upenn.edu/biobank/cached_mondo_icd_mappings"                                  
[6] "http://www.itmat.upenn.edu/biobank/cached_mondo_icd_mappings_LEAFONLY"                         
[7] "http://www.itmat.upenn.edu/biobank/cached_mondo_icd_mappings_depthTimesMappingCountFormulaOnly"
[8] "http://www.itmat.upenn.edu/biobank/countIcdMappingsPerMondoTerm
```

See Hayden
