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

