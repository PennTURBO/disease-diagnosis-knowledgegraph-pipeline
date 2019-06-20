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
    - SNOMED disease = http://purl.bioontology.org/ontology/SNOMEDCT/64572001
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
    graph mydata:ICD9TransitiveDiseaseInjurySubClasses {
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


