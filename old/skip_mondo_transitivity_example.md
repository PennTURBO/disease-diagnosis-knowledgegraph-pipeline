Typical quad from `Hayden_diseaseToDiagnosis`:
obo:MONDO_0001770 <http://graphBuilder.org/mapsTo> <http://purl.bioontology.org/ontology/ICD10CM/C25.4> <http://graphBuilder.org/mondoToIcdMappingsFullSemantics>

Map to literals instead of entity URIs for more manageable visualizations?

## Notes
- repo `disease_diagnosis_20190617_add_mapsTo` on http://turbo-prd-db01:7200
- Using `mydata:mapsTo` instead of `http://graphBuilder.org/mapsTo`
- Using different graph names compared to repo `Hayden_diseaseToDiagnosis`
- As Hayden does for `Hayden_diseaseToDiagnosis`, I didn't initially materialize transitively over MonDO subclasses OR test for excludable rare/syndromic diseases 

## Next steps
- Try with the other paths
- Add the MonDO transitivity and rare/syndomic filtering after the fact
- Are SNOMED path results the same for all of the following predicates? 
    - oboInOwl:hasDbXref
	- owl:equivalentClass
	- skos:closeMatch

```
PREFIX mondo: <http://purl.obolibrary.org/obo/mondo#>
PREFIX mydata: <http://example.com/resource/>
PREFIX obo: <http://purl.obolibrary.org/obo/>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
PREFIX owl: <http://www.w3.org/2002/07/owl#>
insert {
    graph mydata:m-eqClass-snomed-shared_cui-i9 {
        ?mondo  mydata:mapsTo ?subIcd
    }
} 
where {
    graph <http://purl.obolibrary.org/obo/mondo.owl> {
        ?mondo  rdfs:subClassOf+ <http://purl.obolibrary.org/obo/MONDO_0000001> .
    }
    graph <http://example.com/resource/rewrites> {
        ?mondo owl:equivalentClass ?code .
    } 
    graph <http://purl.bioontology.org/ontology/SNOMEDCT/> {
        ?subcode rdfs:subClassOf* ?code ;
                                skos:prefLabel ?subCodeLabel .
    }
    graph mydata:materializedCui {
        ?subcode mydata:materializedCui ?materializedCui .
        ?icd mydata:materializedCui ?materializedCui .
    } graph <http://purl.bioontology.org/ontology/ICD9CM/> {
        ?icd a owl:Class .
        ?subIcd rdfs:subClassOf* ?icd .
    }
}
```

> Added 96548 statements. Update took 2m 50s, minutes ago. 

## Now materialize transitively and filter out inherited diseases

- Will have to add more filters later
- Note that SNOMED filters would have to be written separately
    - SNOMED disease = http://purl.bioontology.org/ontology/SNOMEDCT/64572001
    - for example: <http://purl.bioontology.org/ontology/SNOMEDCT/occurs_in> <http://purl.bioontology.org/ontology/SNOMEDCT/255399007> (Congenital)

```
PREFIX mondo: <http://purl.obolibrary.org/obo/mondo#>
PREFIX mydata: <http://example.com/resource/>
PREFIX obo: <http://purl.obolibrary.org/obo/>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
PREFIX owl: <http://www.w3.org/2002/07/owl#>
insert {
    graph mydata:m-ms-eqClass-snomed-shared_cui-i9 {
        ?mondo  mydata:mapsTo ?subIcd
    }
} 
where {
    graph <http://purl.obolibrary.org/obo/mondo.owl> {
        ?mondoSub rdfs:subClassOf+ ?mondo .
    }
    graph mydata:m-eqClass-snomed-shared_cui-i9 {
        ?mondoSub  mydata:mapsTo ?subIcd
    }
    minus {
        graph <http://example.com/resource/materializedMondoAxioms> {
            ?mondoSub obo:RO_0002573 obo:MONDO_0021152 .
        }
    }
}
```

> Added 228971 statements. Update took 48m 42s, yesterday at 22:18. 

**Duh, we'll have to do the MonDO transitivity part for many/all routes... do that separately from even then inheritance of ICD codes?**

```
PREFIX mondo: <http://purl.obolibrary.org/obo/mondo#>
PREFIX mydata: <http://example.com/resource/>
PREFIX obo: <http://purl.obolibrary.org/obo/>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
PREFIX owl: <http://www.w3.org/2002/07/owl#>
insert {
    graph mydata:filteredMondoTransitiveSubClasses {
        ?mondoSub rdfs:subClassOf ?mondo .
    }
} 
where {
    graph <http://purl.obolibrary.org/obo/mondo.owl> {
        ?mondoSub rdfs:subClassOf+ ?mondo .
    }
    minus {
        graph <http://example.com/resource/materializedMondoAxioms> {
            ?mondoSub obo:RO_0002573 obo:MONDO_0021152 .
        }
    }
}
```

> Added 300278 statements. Update took 32m 52s, today at 07:08. 

----

```
PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
PREFIX mydata: <http://example.com/resource/>
insert {
    graph mydata:ICD9DiseaseInjuryTransitiveSubClasses {
        ?sub rdfs:subClassOf ?s .
    }
}
where {
    graph <http://purl.bioontology.org/ontology/ICD9CM/> {
        # + or * ?
        ?s rdfs:subClassOf* <http://purl.bioontology.org/ontology/ICD9CM/001-999.99> .
        ?sub rdfs:subClassOf* ?s .
    }
}
```

> Added 81980 statements. Update took 14s, moments ago. 

---

```
PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
PREFIX mydata: <http://example.com/resource/>
insert {
    graph mydata:ICD10TransitiveSubClasses {
        ?sub rdfs:subClassOf ?s .
    }
}
where {
    graph <http://purl.bioontology.org/ontology/ICD9CM/> {
        # + or * ?
        ?s rdfs:subClassOf+ owl:Thing .
        ?sub rdfs:subClassOf* ?s .
    }
}
```

> Added 564084 statements. Update took 1m 18s, minutes ago

---

```
PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
PREFIX mydata: <http://example.com/resource/>
insert {
    graph mydata:SnomedDiseaseTransitiveSubClasses {
        ?sub rdfs:subClassOf ?s .
    }
}
where {
    graph <https://bioportal.bioontology.org/ontologies/SNOMEDCT> {
        # + or * ?
        ?s rdfs:subClassOf* <http://purl.bioontology.org/ontology/SNOMEDCT/64572001> .
        ?sub rdfs:subClassOf* ?s .
    }
}
```

> Added 1500248 statements. Update took 3m 17s, moments ago. 

---

```
PREFIX mydata: <http://example.com/resource/>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
select ?p ?t (count(?sub) as ?count) 
where {
    graph mydata:SnomedDiseaseTransitiveSubClasses {
        ?sub rdfs:subClassOf <http://purl.bioontology.org/ontology/SNOMEDCT/64572001>
    }
    graph <http://purl.bioontology.org/ontology/SNOMEDCT/> {
        ?sub ?p ?o .
    }
    optional {
        ?p a ?t
    }
}
group by ?p ?t
order by desc(count(?sub))
```

> Showing results from 1 to 41 of 41. Query took 26s, minutes ago. 

| p                                     | t                    | count   | interesting | notes                 |
|---------------------------------------|----------------------|---------|-------------|-----------------------|
| umls:cui                              |                      | 80037   | FALSE       |                       |
| umls:tui                              |                      | 79635   | FALSE       |                       |
| rdf:type                              |                      | 79169   | FALSE       | all owl:Class, right? |
| skos:altLabel                         |                      | 137567  | FALSE       |                       |
| skos:definition                       |                      | 3935    | FALSE       |                       |
| skos:notation                         |                      | 79169   | FALSE       |                       |
| skos:prefLabel                        |                      | 79169   | FALSE       |                       |
| snomed:ACTIVE                         | owl:DatatypeProperty | 79169   | FALSE       |                       |
| snomed:CASE_SIGNIFICANCE_ID           | owl:DatatypeProperty | 96948   | FALSE       |                       |
| snomed:CTV3ID                         | owl:DatatypeProperty | 75365   | FALSE       |                       |
| snomed:DEFINITION_STATUS_ID           | owl:DatatypeProperty | 79169   | FALSE       |                       |
| snomed:EFFECTIVE_TIME                 | owl:DatatypeProperty | 79169   | FALSE       |                       |
| snomed:INACTIVATION_INDICATOR         | owl:DatatypeProperty | 1991    | FALSE       |                       |
| snomed:MODULE_ID                      | owl:DatatypeProperty | 3974    | FALSE       |                       |
| snomed:SUBSET_MEMBER                  | owl:DatatypeProperty | 1813640 | FALSE       |                       |
| snomed:TYPE_ID                        | owl:DatatypeProperty | 158338  | FALSE       |                       |
| umls:hasSTY                           | owl:ObjectProperty   | 79635   | maybe       |                       |
| rdfs:subClassOf                       |                      | 160191  | **maybe**       |                       |
| snomed:associated_finding_of          | owl:ObjectProperty   | 1684    | maybe       |                       |
| snomed:associated_with                | owl:ObjectProperty   | 2736    | maybe       |                       |
| snomed:cause_of                       | owl:ObjectProperty   | 3923    | maybe       |                       |
| snomed:definitional_manifestation_of  | owl:ObjectProperty   | 7       | maybe       |                       |
| snomed:due_to                         | owl:ObjectProperty   | 6013    | maybe       |                       |
| snomed:during                         | owl:ObjectProperty   | 44      | maybe       |                       |
| snomed:focus_of                       | owl:ObjectProperty   | 1282    | maybe       |                       |
| snomed:has_associated_morphology      | owl:ObjectProperty   | 60231   | maybe       |                       |
| snomed:has_causative_agent            | owl:ObjectProperty   | 17958   | maybe       |                       |
| snomed:has_clinical_course            | owl:ObjectProperty   | 3822    | maybe       |                       |
| snomed:has_definitional_manifestation | owl:ObjectProperty   | 13      | maybe       |                       |
| snomed:has_finding_informer           | owl:ObjectProperty   | 286     | maybe       |                       |
| snomed:has_finding_method             | owl:ObjectProperty   | 315     | maybe       |                       |
| snomed:has_finding_site               | owl:ObjectProperty   | 77114   | maybe       |                       |
| snomed:has_interpretation             | owl:ObjectProperty   | 2889    | maybe       |                       |
| snomed:has_pathological_process       | owl:ObjectProperty   | 15861   | maybe       |                       |
| snomed:has_realization                | owl:ObjectProperty   | 1       | maybe       |                       |
| snomed:has_severity                   | owl:ObjectProperty   | 26      | maybe       |                       |
| snomed:interprets                     | owl:ObjectProperty   | 4934    | maybe       |                       |
| snomed:occurs_after                   | owl:ObjectProperty   | 2209    | maybe       |                       |
| snomed:occurs_before                  | owl:ObjectProperty   | 863     | maybe       |                       |
| snomed:occurs_in                      | owl:ObjectProperty   | 12065   | maybe       |                       |
| snomed:temporally_related_to          | owl:ObjectProperty   | 25      | maybe       |                       |

```
PREFIX mydata: <http://example.com/resource/>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
select ?p ?o ?l (count(?sub) as ?count) 
where {
    graph mydata:SnomedDiseaseTransitiveSubClasses {
        ?sub rdfs:subClassOf <http://purl.bioontology.org/ontology/SNOMEDCT/64572001> 
    }
    graph <http://purl.bioontology.org/ontology/SNOMEDCT/> {
        ?sub ?p ?o .
        ?p a owl:ObjectProperty .
        ?o skos:prefLabel ?l .
    }
}
group by ?p ?o ?l
order by desc(count(?sub))
```

*1,000 of 23,454 in 4 seconds*

---

```
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
select ?mondo ?l (count( ?mondoSub )  as ?count ) where {
    graph <http://example.com/resource/filteredMondoTransitiveSubClasses> {
        ?mondoSub rdfs:subClassOf ?mondo .
        filter(isuri(?mondo))
        filter(isuri(?mondoSub))
    }
    ?mondo rdfs:label ?l .
}
group by ?mondo ?l
order by desc(count( ?mondoSub ))
```

| mondo                                        | l                                                                         | count |
|----------------------------------------------|---------------------------------------------------------------------------|-------|
| obo:MONDO_0000001 | disease or disorder                                                       | 12691 |
| obo:MONDO_0021199 | disease by anatomical system                                              | 10690 |
| obo:MONDO_0024505 | disorder by anatomical region                                             | 4672  |
| obo:MONDO_0045024 | cell proliferation disorder                                               | 4141  |
| obo:MONDO_0023370 | neoplastic disease or syndrome                                            | 4115  |
| obo:MONDO_0005070 | neoplasm (disease)                                                        | 4104  |
| obo:MONDO_0005071 | nervous system disorder                                                   | 3663  |
| obo:MONDO_0004992 | cancer                                                                    | 2108  |
| obo:MONDO_0021059 | head or neck disease/disorder                                             | 1940  |
| obo:MONDO_0005042 | head disease                                                              | 1788  |
| obo:MONDO_0002081 | musculoskeletal system disease                                            | 1753  |
| obo:MONDO_0002602 | central nervous system disease                                            | 1571  |
| obo:MONDO_0021147 | disorder of development or morphogenesis                                  | 1557  |
| obo:MONDO_0004335 | digestive system disease                                                  | 1488  |
| obo:MONDO_0005626 | epithelial neoplasm                                                       | 1386  |
| obo:MONDO_0005151 | endocrine system disease                                                  | 1316  |
| obo:MONDO_0005128 | sensory system disease                                                    | 1283  |
| obo:MONDO_0002254 | syndromic disease                                                         | 1273  |
| obo:MONDO_0003900 | connective tissue disease                                                 | 1216  |
| obo:MONDO_0044987 | face disease                                                              | 1189  |
| obo:MONDO_0021145 | disease of genitourinary system                                           | 1173  |
| obo:MONDO_0005560 | brain disease                                                             | 1154  |
| obo:MONDO_0005039 | reproductive system disease                                               | 1149  |
| obo:MONDO_0021194 | disease by subcellular system affected                                    | 1143  |
| obo:MONDO_0005046 | immune system disease                                                     | 1134  |
| obo:MONDO_0002051 | integumentary system disease                                              | 1131  |
| obo:MONDO_0000839 | congenital abnormality                                                    | 1126  |
| obo:MONDO_0019755 | developmental defect during embryogenesis                                 | 1107  |
| obo:MONDO_0005172 | skeletal system disease                                                   | 1105  |
| obo:MONDO_0004995 | cardiovascular disease                                                    | 1098  |
| obo:MONDO_0021166 | inflammatory disease                                                      | 1076  |
| obo:MONDO_0024458 | disease of visual system                                                  | 1054  |
| obo:MONDO_0005550 | infectious disease                                                        | 1042  |
| obo:MONDO_0002022 | disease of orbital region                                                 | 1031  |
| obo:MONDO_0000651 | thoracic disease                                                          | 1031  |
| obo:MONDO_0005328 | eye disease                                                               | 998   |
| obo:MONDO_0004993 | carcinoma                                                                 | 952   |
| obo:MONDO_0044965 | abdominal and pelvic region disorder                                      | 884   |
| obo:MONDO_0005381 | bone disease                                                              | 854   |
| obo:MONDO_0021248 | nervous system neoplasm                                                   | 852   |
| obo:MONDO_0005093 | skin disease                                                              | 827   |
| obo:MONDO_0005570 | hematologic disease                                                       | 807   |
| obo:MONDO_0021223 | digestive system neoplasm                                                 | 752   |
| obo:MONDO_0002263 | female reproductive system disease                                        | 722   |
| obo:MONDO_0005385 | vascular disease                                                          | 707   |
| obo:MONDO_0005087 | respiratory system disease                                                | 680   |
| obo:MONDO_0003620 | peripheral nervous system disease                                         | 662   |
| obo:MONDO_0025370 | urogenital neoplasm                                                       | 623   |
| obo:MONDO_0021197 | disease by cellular component affected                                    | 621   |
| obo:MONDO_0006054 | reproductive system neoplasm                                              | 621   |
| obo:MONDO_0005165 | benign neoplasm                                                           | 620   |
| obo:MONDO_0002118 | urinary system disease                                                    | 593   |
| obo:MONDO_0002320 | congenital nervous system disorder                                        | 578   |
| obo:MONDO_0005586 | head and neck neoplasm                                                    | 536   |
| obo:MONDO_0002025 | psychiatric disorder                                                      | 524   |
| obo:MONDO_0021195 | disease by cellular process disrupted                                     | 511   |
| obo:MONDO_0002082 | endocrine gland neoplasm                                                  | 511   |
| obo:MONDO_0021581 | connective tissue neoplasm                                                | 497   |
| obo:MONDO_0005020 | intestinal disease                                                        | 497   |
| obo:MONDO_0005244 | peripheral neuropathy                                                     | 476   |
| obo:MONDO_0002334 | hematopoietic and lymphoid system neoplasm                                | 472   |
| obo:MONDO_0005218 | muscular disease                                                          | 472   |
| obo:MONDO_0021148 | female reproductive system neoplasm                                       | 460   |
| obo:MONDO_0003939 | muscle tissue disease                                                     | 459   |
| obo:MONDO_0024276 | glandular cell neoplasm                                                   | 452   |
| obo:MONDO_0002516 | digestive system cancer                                                   | 446   |
| obo:MONDO_0005084 | mental disorder                                                           | 423   |
| obo:MONDO_0021350 | neoplasm of thorax                                                        | 413   |
| obo:MONDO_0005240 | kidney disease                                                            | 412   |
| obo:MONDO_0006130 | central nervous system neoplasm                                           | 401   |
| obo:MONDO_0000605 | hypersensitivity reaction disease                                         | 400   |
| obo:MONDO_0005113 | bacterial infectious disease                                              | 398   |
| obo:MONDO_0044881 | hematopoietic and lymphoid cell neoplasm                                  | 395   |
| obo:MONDO_0004970 | adenocarcinoma                                                            | 386   |
| obo:MONDO_0005497 | bone development disease                                                  | 383   |
| obo:MONDO_0020006 | rare hematologic disease                                                  | 381   |
| obo:MONDO_0002149 | reproductive systen cancer                                                | 378   |
| obo:MONDO_0044334 | connective and soft tissue neoplasm                                       | 374   |
| obo:MONDO_0005872 | nervous system cancer                                                     | 367   |
| obo:MONDO_0019044 | tumor of hematopoietic and lymphoid tissues                               | 363   |
| obo:MONDO_0005267 | heart disease                                                             | 359   |
| obo:MONDO_0000270 | lower respiratory tract disease                                           | 355   |
| obo:MONDO_0018230 | primary bone dysplasia                                                    | 347   |
| obo:MONDO_0044979 | disease by cell type                                                      | 338   |
| obo:MONDO_0024297 | nutritional or metabolic disease                                          | 332   |
| obo:MONDO_0002259 | gonadal disease                                                           | 330   |
| obo:MONDO_0000637 | musculoskeletal system cancer                                             | 330   |
| obo:MONDO_0005503 | developmental disorder of mental health                                   | 321   |
| obo:MONDO_0024623 | otorhinolaryngologic disease                                              | 321   |
| obo:MONDO_0019056 | neuromuscular disease                                                     | 317   |
| obo:MONDO_0000462 | eye adnexa disease                                                        | 315   |
| obo:MONDO_0019060 | bone neoplasm                                                             | 310   |
| obo:MONDO_0005089 | sarcoma                                                                   | 300   |
| obo:MONDO_0007179 | autoimmune disease                                                        | 299   |
| obo:MONDO_0005275 | lung disease                                                              | 296   |
| obo:MONDO_0006424 | soft tissue neoplasm                                                      | 291   |
| obo:MONDO_0005066 | metabolic disease                                                         | 290   |
| obo:MONDO_0006181 | digestive system carcinoma                                                | 280   |
| obo:MONDO_0003150 | male reproductive system disease                                          | 280   |
| obo:MONDO_0002531 | skin neoplasm                                                             | 278   |
| obo:MONDO_0001416 | female reproductive organ cancer                                          | 275   |
| obo:MONDO_0002616 | mesenchymal cell neoplasm                                                 | 273   |
| obo:MONDO_0002515 | hepatobiliary disease                                                     | 270   |
| obo:MONDO_0005027 | epilepsy                                                                  | 266   |
| obo:MONDO_0001071 | intellectual disability                                                   | 265   |
| obo:MONDO_0021069 | malignant endocrine neoplasm                                              | 264   |
| obo:MONDO_0005627 | head and neck cancer                                                      | 259   |
| obo:MONDO_0000508 | syndromic intellectual disability                                         | 257   |
| obo:MONDO_0005108 | viral infectious disease                                                  | 257   |
| obo:MONDO_0003274 | thoracic cancer                                                           | 256   |
| obo:MONDO_0020012 | systemic or rheumatic disease                                             | 253   |
| obo:MONDO_0005040 | germ cell tumor                                                           | 251   |
| obo:MONDO_0021118 | intestinal neoplasm                                                       | 248   |
| obo:MONDO_0015757 | lymphoid hemopathy                                                        | 247   |
| obo:MONDO_0006858 | mouth disease                                                             | 247   |
| obo:MONDO_0002176 | connective tissue cancer                                                  | 244   |
| obo:MONDO_0020022 | central nervous system malformation                                       | 242   |
| obo:MONDO_0005157 | lymphoid neoplasm                                                         | 238   |
| obo:MONDO_0004805 | leukocyte disease                                                         | 235   |
| obo:MONDO_0024637 | malignant soft tissue neoplasm                                            | 232   |
| obo:MONDO_0036976 | benign epithelial neoplasm                                                | 231   |
| obo:MONDO_0002654 | uterine disease                                                           | 231   |
| obo:MONDO_0018078 | soft tissue sarcoma                                                       | 228   |
| obo:MONDO_0024634 | large intestine disease                                                   | 225   |
| obo:MONDO_0005062 | lymphoma                                                                  | 222   |
| obo:MONDO_0024239 | congenital anomaly of cardiovascular system                               | 220   |
| obo:MONDO_0019496 | neuroendocrine neoplasm                                                   | 219   |
| obo:MONDO_0021066 | urinary system neoplasm                                                   | 218   |
| obo:MONDO_0021193 | neuroepithelial neoplasm                                                  | 216   |
| obo:MONDO_0024757 | cardiovascular neoplasm                                                   | 213   |
| obo:MONDO_0020683 | acute disease                                                             | 208   |
| obo:MONDO_0019063 | vascular anomaly                                                          | 208   |
| obo:MONDO_0020641 | respiratory tract neoplasm                                                | 205   |
| obo:MONDO_0020120 | skeletal muscle disease                                                   | 205   |
| obo:MONDO_0021211 | brain neoplasm                                                            | 202   |
| obo:MONDO_0019512 | congenital heart malformation                                             | 199   |
| obo:MONDO_0020010 | infectious disease of the nervous system                                  | 192   |
| obo:MONDO_0000314 | primary bacterial infectious disease                                      | 190   |
| obo:MONDO_0005135 | parasitic infection                                                       | 189   |
| obo:MONDO_0005154 | liver disease                                                             | 187   |
| obo:MONDO_0000473 | arterial disorder                                                         | 186   |
| obo:MONDO_0043218 | neurovascular disease                                                     | 186   |
| obo:MONDO_0002129 | bone cancer                                                               | 185   |
| obo:MONDO_0000376 | respiratory system cancer                                                 | 183   |
| obo:MONDO_0000653 | integumentary system cancer                                               | 182   |
| obo:MONDO_0044974 | disease of supramolecular complex                                         | 179   |
| obo:MONDO_0015938 | systemic disease                                                          | 179   |
| obo:MONDO_0019042 | multiple congenital anomalies/dysmorphic syndrome                         | 178   |
| obo:MONDO_0005336 | myopathy                                                                  | 178   |
| obo:MONDO_0002714 | central nervous system cancer                                             | 177   |
| obo:MONDO_0003382 | eyelid disease                                                            | 177   |
| obo:MONDO_0024296 | vascular neoplasm                                                         | 177   |
| obo:MONDO_0015118 | rare pulmonary disease                                                    | 176   |
| obo:MONDO_0002657 | breast disease                                                            | 174   |
| obo:MONDO_0001406 | peripheral nervous system neoplasm                                        | 170   |
| obo:MONDO_0005335 | colorectal neoplasm                                                       | 169   |
| obo:MONDO_0015159 | multiple congenital anomalies/dysmorphic syndrome-intellectual disability | 169   |
| obo:MONDO_0002532 | squamous cell neoplasm                                                    | 169   |
| obo:MONDO_0024654 | skull disorder                                                            | 166   |
| obo:MONDO_0021353 | tumor of uterus                                                           | 166   |
| obo:MONDO_0000621 | immune system cancer                                                      | 164   |
| obo:MONDO_0005558 | ovarian disease                                                           | 163   |
| obo:MONDO_0002356 | pancreas disease                                                          | 163   |
| obo:MONDO_0003225 | bone marrow disease                                                       | 161   |
| obo:MONDO_0021080 | blood vessel neoplasm                                                     | 158   |
| obo:MONDO_0002406 | dermatitis                                                                | 156   |
| obo:MONDO_0015475 | rare head and neck malformation                                           | 156   |
| obo:MONDO_0021669 | post-infectious disorder                                                  | 154   |
| obo:MONDO_0005096 | squamous cell carcinoma                                                   | 153   |
| obo:MONDO_0000636 | musculoskeletal system benign neoplasm                                    | 152   |
| obo:MONDO_0021100 | breast neoplasm                                                           | 149   |
| obo:MONDO_0003778 | primary immunodeficiency disease                                          | 149   |
| obo:MONDO_0006295 | malignant urinary system neoplasm                                         | 147   |
| obo:MONDO_0002514 | hepatobiliary neoplasm                                                    | 146   |
| obo:MONDO_0005554 | rheumatologic disorder                                                    | 145   |
| obo:MONDO_0015923 | acquired peripheral neuropathy                                            | 144   |
| obo:MONDO_0021635 | neurocristopathy                                                          | 144   |
| obo:MONDO_0024653 | skull neoplasm                                                            | 143   |
| obo:MONDO_0020145 | developmental defect of the eye                                           | 141   |
| obo:MONDO_0004972 | adenoma                                                                   | 139   |
| obo:MONDO_0003569 | cranial nerve neuropathy                                                  | 139   |
| obo:MONDO_0044986 | lymphoid system disease                                                   | 138   |
| obo:MONDO_0000942 | corneal disease                                                           | 137   |
| obo:MONDO_0006290 | malignant germ cell tumor                                                 | 137   |
| obo:MONDO_0005374 | bone marrow neoplasm                                                      | 136   |
| obo:MONDO_0021068 | ovarian neoplasm                                                          | 136   |
| obo:MONDO_0015925 | interstitial lung disease                                                 | 134   |
| obo:MONDO_0005516 | osteochondrodysplasia                                                     | 133   |
| obo:MONDO_0024236 | degenerative disorder                                                     | 132   |
| obo:MONDO_0005814 | intestinal cancer                                                         | 132   |
| obo:MONDO_0021096 | papillary epithelial neoplasm                                             | 132   |
| obo:MONDO_0002510 | germ cell and embryonal cancer                                            | 131   |
| obo:MONDO_0024582 | male reproductive system neoplasm                                         | 131   |
| obo:MONDO_0002898 | skin cancer                                                               | 131   |
| obo:MONDO_0002038 | head and neck carcinoma                                                   | 130   |
| obo:MONDO_0004867 | upper respiratory tract disease                                           | 130   |
| obo:MONDO_0021220 | eye neoplasm                                                              | 128   |
| obo:MONDO_0024481 | skin appendage disease                                                    | 128   |
| obo:MONDO_0005564 | embryonal neoplasm                                                        | 127   |
| obo:MONDO_0021042 | glioma                                                                    | 126   |
| obo:MONDO_0005559 | neurodegenerative disease                                                 | 125   |
| obo:MONDO_0003240 | thyroid gland disease                                                     | 124   |
| obo:MONDO_0005833 | lymphatic system disease                                                  | 123   |
| obo:MONDO_0018908 | non-Hodgkin lymphoma                                                      | 123   |
| obo:MONDO_0019722 | glomerular disease                                                        | 122   |
| obo:MONDO_0002715 | uterine cancer                                                            | 122   |
| obo:MONDO_0002409 | auditory system disease                                                   | 121   |
| obo:MONDO_0021674 | post-viral disorder                                                       | 121   |
| obo:MONDO_0021634 | epithelial skin neoplasm                                                  | 120   |
| obo:MONDO_0005156 | encephalomyelitis                                                         | 119   |
| obo:MONDO_0000649 | sensory system cancer                                                     | 119   |
| obo:MONDO_0004868 | biliary tract disease                                                     | 118   |
| obo:MONDO_0000629 | cardiovascular organ benign neoplasm                                      | 117   |
| obo:MONDO_0019038 | rare maxillo-facial surgical disease                                      | 117   |
| obo:MONDO_0020665 | high grade malignant neoplasm                                             | 116   |
| obo:MONDO_0018201 | extragonadal germ cell tumor                                              | 115   |
| obo:MONDO_0005059 | leukemia (disease)                                                        | 115   |
| obo:MONDO_0100070 | neuroendocrine disease                                                    | 115   |
| obo:MONDO_0003409 | colonic disease                                                           | 113   |
| obo:MONDO_0004721 | liver neoplasm                                                            | 113   |
| obo:MONDO_0021079 | childhood neoplasm                                                        | 110   |
| obo:MONDO_0021656 | nongerminomatous germ cell tumor                                          | 110   |
| obo:MONDO_0005583 | non-human animal disease                                                  | 109   |
| obo:MONDO_0001176 | lens disease                                                              | 106   |
| obo:MONDO_0002661 | uveal disease                                                             | 106   |
| obo:MONDO_0005170 | myeloid neoplasm                                                          | 105   |
| obo:MONDO_0002545 | spinal cord disease                                                       | 103   |
| obo:MONDO_0021205 | disease of ear                                                            | 102   |
| obo:MONDO_0000652 | integumentary system benign neoplasm                                      | 102   |
| obo:MONDO_0017341 | virus associated tumor                                                    | 102   |
| obo:MONDO_0000383 | benign reproductive system neoplasm                                       | 101   |
| obo:MONDO_0001933 | endocrine pancreas disease                                                | 101   |
| obo:MONDO_0024294 | skin disease caused by infection                                          | 101   |
| obo:MONDO_0020676 | disease of central nervous system or retinal vasculature                  | 100   |
| obo:MONDO_0021163 | kidney neoplasm                                                           | 100   |
| obo:MONDO_0021143 | melanocytic neoplasm                                                      | 100   |

---

```
PREFIX mondo: <http://purl.obolibrary.org/obo/mondo#>
PREFIX mydata: <http://example.com/resource/>
PREFIX obo: <http://purl.obolibrary.org/obo/>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
PREFIX owl: <http://www.w3.org/2002/07/owl#>
insert {
    graph mydata:m-dbxr-snomed-shared_cui-i9 {
        ?mondo mydata:mapsTo ?subIcd
    }
} 
#select distinct ?mondo ?ml ?subIcd ?isl
where {
    graph <http://purl.obolibrary.org/obo/mondo.owl> {
        ?mondo rdfs:subClassOf+ obo:MONDO_0005071 ;
                              rdfs:label ?ml .
    }
    graph <http://example.com/resource/filteredMondoTransitiveSubClasses> {
        ?mondoSub rdfs:subClassOf ?mondo .
    }
    graph <http://purl.obolibrary.org/obo/mondo.owl> {
        ?mondoSub rdfs:label ?msl .
    }
    graph <http://example.com/resource/rewrites> {
        ?mondo mydata:mdbxr ?code .
    } 
    graph <http://purl.bioontology.org/ontology/SNOMEDCT/> {
        ?code a owl:Class ;
              skos:prefLabel ?sl .
    }
    graph <http://example.com/resource/SnomedDiseaseTransitiveSubClasses> {
        ?subcode rdfs:subClassOf ?code
    }
    graph <http://purl.bioontology.org/ontology/SNOMEDCT/> {
        ?subcode skos:prefLabel ?ssl .
    }
    graph mydata:materializedCui {
        ?subcode mydata:materializedCui ?materializedCui .
        ?icd mydata:materializedCui ?materializedCui .
    } 
    graph <http://purl.bioontology.org/ontology/ICD9CM/> {
        ?icd a owl:Class ;
             skos:prefLabel ?il .
    }
    graph <http://example.com/resource/ICD9DiseaseInjuryTransitiveSubClasses>    {
        ?subIcd rdfs:subClassOf ?icd .
    }
    graph <http://purl.bioontology.org/ontology/ICD9CM/> {
        ?subIcd skos:prefLabel ?isl .
    }
}
```


> Added 10483 statements. Update took 20m 27s, moments ago.
