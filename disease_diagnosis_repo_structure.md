## Orientation to the named graphs

### MonDO

#### Class usage

```SPARQL
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
select
?o ?l (count(?s) as ?count)
where {
    graph <http://purl.obolibrary.org/obo/mondo.owl> {
        ?s rdf:type ?o .
        optional {
            ?o rdfs:label ?l
        }
    }
}
group by ?o ?l
order by desc(count(distinct ?s)) ?o
```

**o**|**l**|**count**
:-----|:-----|-----:
owl:Axiom| |263471
owl:Class| |117778
owl:Restriction| |22425
owl:AnnotationProperty| |70
owl:ObjectProperty| |27
owl:Ontology| |1
owl:TransitiveProperty| |1

#### Predicate usage

```SPARQL
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
select
?p ?l (count(distinct ?s) as ?count)
where {
    graph <http://purl.obolibrary.org/obo/mondo.owl> {
        ?s ?p ?o .
        optional {
            ?p rdfs:label ?l
        }
    }
}
group by ?p ?l
order by desc(count(distinct ?s))
```

**p**|**l**|**count**
:-----:|:-----:|-----:
rdf:type| |403772
owl:annotatedProperty| |263471
owl:annotatedSource| |263471
owl:annotatedTarget| |263471
oboInOwl:source| |148839
oboInOwl:hasDbXref|database\_cross\_reference|136711
owl:equivalentClass| |65043
rdfs:label| |23556
oboInOwl:id| |23535
owl:onProperty| |22425
owl:someValuesFrom| |22425
rdfs:subClassOf| |22027
skos:exactMatch| |21577
oboInOwl:hasExactSynonym|has\_exact\_synonym|17642
obo:IAO\_0000115|definition|15442
rdf:first| |15358
rdf:rest| |15358
oboInOwl:hasRelatedSynonym|has\_related\_synonym|11375
oboInOwl:inSubset|in\_subset|10945
owl:intersectionOf| |7452
skos:closeMatch| |7110
rdfs:seeAlso|seeAlso|3042
owl:deprecated| |1781
obo:IAO\_0100001|term replaced by|1554
rdfs:comment| |996
oboInOwl:hasSynonymType|has\_synonym\_type|860
mondo:excluded\_subClassOf|excluded subClassOf|776
oboInOwl:hasNarrowSynonym|has\_narrow\_synonym|290
oboInOwl:hasBroadSynonym|has\_broad\_synonym|262
oboInOwl:consider|consider|119
obo:IAO\_0000231| |113
oboInOwl:hasAlternativeId|has\_alternative\_id|111
owl:disjointWith| |68
dc:date| |55
dc:creator| |54
rdfs:subPropertyOf| |34
oboInOwl:shorthand|shorthand|17
oboInOwl:created\_by| |16
owl:unionOf| |11
skos:broadMatch| |11
skos:narrowMatch| |10
mondo:excluded\_synonym| |7
owl:propertyChainAxiom| |7
oboInOwl:is\_metadata\_tag| |4
oboInOwl:notes| |3
oboInOwl:is\_class\_level| |2
oboInOwl:hasOBOFormatVersion|has\_obo\_format\_version|1
mondo:may\_be\_merged\_into|may\_be\_merged\_into|1
obo:RO\_0002161|never in taxon|1
mondo:pathogenesis| |1
mondo:related| |1
dc:title| |1
terms:description| |1
terms:license| |1
terms:source| |1
oboInOwl:creation\_date| |1
oboInOwl:modified\_by| |1
oboInOwl:severity| |1
owl:imports| |1
owl:versionIRI| |1
foaf:homepage| |1

### Predicate usage on `owl:Axiom`s

```SPARQL
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX owl: <http://www.w3.org/2002/07/owl#>
select
?p ?l (count(distinct ?s) as ?count)
where {
    graph <http://purl.obolibrary.org/obo/mondo.owl> {
        ?s a owl:Axiom ;
           ?p ?o .
        optional {
            ?p rdfs:label ?l
        }
    }
}
group by ?p ?l
order by desc(count(distinct ?s)) ?p
```

**p**|**l**|**count**
:-----|:-----|-----:
rdf:type| |263471
owl:annotatedProperty| |263471
owl:annotatedSource| |263471
owl:annotatedTarget| |263471
oboInOwl:source| |148839
oboInOwl:hasDbXref|database\_cross\_reference|114619
oboInOwl:hasSynonymType|has\_synonym\_type|860
rdfs:comment| |11
oboInOwl:notes| |3
obo:IAO\_0000115|definition|1
oboInOwl:hasExactSynonym|has\_exact\_synonym|1
oboInOwl:modified\_by| |1
oboInOwl:severity| |1

### Predicate usage on `owl:Restriction`s

```SPARQL
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX owl: <http://www.w3.org/2002/07/owl#>
select
?p ?l (count(distinct ?s) as ?count)
where {
    graph <http://purl.obolibrary.org/obo/mondo.owl> {
        ?s a owl:Restriction ;
           ?p ?o .
        optional {
            ?p rdfs:label ?l
        }
    }
}
group by ?p ?l
order by desc(count(distinct ?s)) ?p
```

**p**|**l**|**count**
:-----|:-----|-----:
rdf:type| |22425
owl:onProperty| |22425
owl:someValuesFrom| |22425

### Predicate usage on `owl:Class`es

```SPARQL
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX owl: <http://www.w3.org/2002/07/owl#>
select
?p ?l (count(distinct ?s) as ?count)
where {
    graph <http://purl.obolibrary.org/obo/mondo.owl> {
        ?s a owl:Class ;
           ?p ?o .
        optional {
            ?p rdfs:label ?l
        }
    }
}
group by ?p ?l
order by desc(count(distinct ?s)) ?p
```

**p**|**l**|**count**
:-----|:-----|-----:
rdf:type| |117778
owl:equivalentClass| |65043
oboInOwl:id| |23506
rdfs:label| |23506
oboInOwl:hasDbXref|database\_cross\_reference|22075
rdfs:subClassOf| |21951
skos:exactMatch| |21577
oboInOwl:hasExactSynonym|has\_exact\_synonym|17641
obo:IAO\_0000115|definition|15441
oboInOwl:hasRelatedSynonym|has\_related\_synonym|11375
oboInOwl:inSubset|in\_subset|10945
owl:intersectionOf| |7452
skos:closeMatch| |7110
rdfs:seeAlso|seeAlso|3042
owl:deprecated| |1781
obo:IAO\_0100001|term replaced by|1554
rdfs:comment| |957
mondo:excluded\_subClassOf|excluded subClassOf|776
oboInOwl:hasNarrowSynonym|has\_narrow\_synonym|290
oboInOwl:hasBroadSynonym|has\_broad\_synonym|262
oboInOwl:consider|consider|119
obo:IAO\_0000231| |113
oboInOwl:hasAlternativeId|has\_alternative\_id|111
owl:disjointWith| |68
dc:date| |55
dc:creator| |54
oboInOwl:created\_by| |16
owl:unionOf| |11
skos:broadMatch| |11
skos:narrowMatch| |10
mondo:excluded\_synonym| |7
obo:RO\_0002161|never in taxon|1
mondo:may\_be\_merged\_into|may\_be\_merged\_into|1
mondo:pathogenesis| |1
mondo:related| |1
oboInOwl:creation\_date| |1


### subClassOf patterns

```SPARQL
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX owl: <http://www.w3.org/2002/07/owl#>
select
?st ?ot ?isuri_o (count(distinct ?s) as ?count)
where {
    graph <http://purl.obolibrary.org/obo/mondo.owl> {
        ?s rdfs:subClassOf ?o .
        optional {
            ?s a ?st .
        }
        optional {
            ?o a ?ot .
        }
    }
    bind(isuri(?o) as ?isuri_o)
}
group by ?st ?ot ?isuri_o
order by desc(count(distinct ?s))
```

**st**|**ot**|**isuri\_o**|**count**
:-----|:-----|:-----|-----:
owl:Class|owl:Class|true|21857
owl:Class|owl:Restriction|false|7929
owl:Class| |true|102
. |owl:Class|true|76

### equivalentClass patterns

```SPARQL
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX owl: <http://www.w3.org/2002/07/owl#>
select
?st ?ot ?isuri_o (count(distinct ?s) as ?count)
where {
    graph <http://purl.obolibrary.org/obo/mondo.owl> {
        ?s owl:equivalentClass ?o .
        optional {
            ?s a ?st .
        }
        optional {
            ?o a ?ot .
        }
    }
    bind(isuri(?o) as ?isuri_o)
}
group by ?st ?ot ?isuri_o
order by desc(count(distinct ?s))
```

**st**|**ot**|**isuri\_o**|**count**
:-----|:-----|:-----|-----:
owl:Class|owl:Class|true|64721
owl:Class|owl:Class|false|7334

### ICD9CM_TO_SNOMEDCT_DIAGNOSIS_201812.zip

(Ontorefine instantiation of two CSV files from [https://www.nlm.nih.gov/research/umls/mapping_projects/icd9cm_to_snomedct.html](https://www.nlm.nih.gov/research/umls/mapping_projects/icd9cm_to_snomedct.html))

_Based on input from Anurag Verma, we are not using the General Equivalence Mappings from_ [https://www.cms.gov/Medicare/Coding/ICD10/index?redirect=/ICD10/01_Overview.asp#TopOfPage](https://www.cms.gov/Medicare/Coding/ICD10/index?redirect=/ICD10/01_Overview.asp#TopOfPage)

```SPARQL
select 
?p (count(?s) as ?count)
where {
    graph <https://www.nlm.nih.gov/research/umls/mapping_projects/icd9cm_to_snomedct.html> {
        ?s ?p ?o .
    }
}
group by ?p 
order by desc(count(?s))
```

> Showing results from 1 to 15 of 15. Query took 1.3s, minutes ago.

**p**|**count**
:-----|-----:
mydata:AVG\_USAGE|46645
mydata:CORE\_USAGE|46645
mydata:File|46645
mydata:ICD\_CODE|46645
mydata:ICD\_NAME|46645
mydata:IN\_CORE|46645
mydata:IP\_USAGE|46645
mydata:IS\_1-1MAP|46645
mydata:IS\_CURRENT\_ICD|46645
mydata:IS\_NEC|46645
mydata:OP\_USAGE|46645
mydata:SNOMED\_CID|46645
mydata:SNOMED\_FSN|46645
rdf:type|46645
https://www.nlm.nih.gov/research/umls/mapping\_projects/icd9cm\_to\_snomedct.html|45598

_Why is the mapping predicate used 45598 times, but the others are all only used 46645 times?_

_Note that the mapping predicate and graph name have been written with a trailing slash in some places and without in others. Standardize to WITHOUT_


## Actions performed by [disease_diagnosis_dev.R](https://github.com/PennTURBO/disease_to_diagnosis_code/blob/master/disease_diagnosis_dev.R) script

###  Materialize CUIs

- later... check if CUIs asserted by MonDO are actually claimed by any UMLS->BioPortal terms?
- see source predicate, destination graph, destination predicate and destination subject template below

```SPARQL
PREFIX mydata: <http://example.com/resource/>
PREFIX umls: <http://bioportal.bioontology.org/ontologies/umls/>
insert {
    graph <http://example.com/resource/materializedCui> {
        ?c a  <http://example.com/resource/materializedCui> .
        ?s <http://example.com/resource/materializedCui> ?c
    }
} where {
    ?s umls:cui ?o .
    bind(uri(concat("http://example.com/cui/", ?o)) as ?c)
}
```

> Added 939750 statements. Update took 30s, minutes ago.

### Rewrite subjects of "reverse" MonDO assertions

"Reverse" means a MonDO term is the object. "Rewriting" means aligning the URI structure with the ICD and SNOMED URIs used by BioPortal, and our CUI materializations.

This doesn't guarantee that the subject term is actually defined by the ICDs or SNOMED, or that it is a valid CUI. ICD9 ranges may need to be removed or isolated at a later point.

_In previous disease/diagnosis repos, forward and reverse rewrites kept MonDO's native orientation and were put in a single named graph,_ `<http://example.com/resource/rewrites>` 

```SPARQL
PREFIX mydata: <http://example.com/resource/>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
PREFIX owl: <http://www.w3.org/2002/07/owl#>
# remove icd9 ranges LATER?, even if they are defined ?rewrite a ?t
insert {
    graph <http://example.com/resource/rewrites_MonDO_object> {
        ?mondo ?p ?rewrite
    }
}
where {
    graph <http://purl.obolibrary.org/obo/mondo.owl> {
        values ?p {
            skos:exactMatch
            skos:closeMatch
            # skos:narrowMatch
            owl:equivalentClass
        }
        values (?mondoPattern ?rewritePattern) {
            ("http://linkedlifedata.com/resource/umls/id/" "http://example.com/cui/")
            ("http://identifiers.org/snomedct/" "http://purl.bioontology.org/ontology/SNOMEDCT/")
            ("http://purl.obolibrary.org/obo/SCTID_" "http://purl.bioontology.org/ontology/SNOMEDCT/")
            ("http://purl.obolibrary.org/obo/ICD10_" "http://purl.bioontology.org/ontology/ICD10CM/")
            ("http://purl.obolibrary.org/obo/ICD9_" "http://purl.bioontology.org/ontology/ICD9CM/")
        }
        ?external  ?p ?mondo .
        filter(strstarts(str(?external),?mondoPattern))
        filter(strstarts(str(?mondo),"http://purl.obolibrary.org/obo/MONDO_"))
        bind(uri(concat(?rewritePattern,strafter(str(?external),?mondoPattern))) as ?rewrite)
        #        ?rewrite a ?t
    }
}
```

> Added 19609 statements. Update took 5s, minutes ago.

### Rewrite subjects of "forward" MonDO assertions

```SPARQL
PREFIX mydata: <http://example.com/resource/>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
PREFIX owl: <http://www.w3.org/2002/07/owl#>
# remove icd9 ranges LATER?, even if they are defined ?rewrite a ?t
insert {
    graph <http://example.com/resource/rewrites_MonDO_subject> {
        ?mondo ?p ?rewrite
    }
}
where {
    graph <http://purl.obolibrary.org/obo/mondo.owl> {
        values ?p {
            skos:exactMatch
            skos:closeMatch
            # skos:narrowMatch
            owl:equivalentClass
        }
        values (?mondoPattern ?rewritePattern) {
            ("http://linkedlifedata.com/resource/umls/id/" "http://example.com/cui/")
            ("http://identifiers.org/snomedct/" "http://purl.bioontology.org/ontology/SNOMEDCT/")
            ("http://purl.obolibrary.org/obo/SCTID_" "http://purl.bioontology.org/ontology/SNOMEDCT/")
            ("http://purl.obolibrary.org/obo/ICD10_" "http://purl.bioontology.org/ontology/ICD10CM/")
            ("http://purl.obolibrary.org/obo/ICD9_" "http://purl.bioontology.org/ontology/ICD9CM/")
        }
        ?mondo ?p ?external .
        filter(strstarts(str(?external),?mondoPattern))
        filter(strstarts(str(?mondo),"http://purl.obolibrary.org/obo/MONDO_"))
        bind(uri(concat(?rewritePattern,strafter(str(?external),?mondoPattern))) as ?rewrite)
        #        ?rewrite a ?t
    }
}
```

> Added 50572 statements. Update took 8.3s, minutes ago.

### Materialize MonDO database cross references 

```SPARQL
PREFIX mydata: <http://example.com/resource/>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
PREFIX owl: <http://www.w3.org/2002/07/owl#>
# remove icd9 ranges, even if they are defined (?rewrite a ?t)
insert {
    graph <http://example.com/resource/rewrites_MonDO_subject> {
        ?mondo mydata:mdbxr ?rewrite
    }
}
where {
    graph <http://purl.obolibrary.org/obo/mondo.owl> {
        values (?mondoPattern ?rewritePattern) {
            ("UMLS:" "http://example.com/cui/")
            ("SCTID:" "http://purl.bioontology.org/ontology/SNOMEDCT/")
            ("ICD10:" "http://purl.bioontology.org/ontology/ICD10CM/")
            ("ICD9:" "http://purl.bioontology.org/ontology/ICD9CM/")
        }
        ?mondo <http://www.geneontology.org/formats/oboInOwl#hasDbXref> ?external .
        filter(strstarts(?external,?mondoPattern))
        filter(strstarts(str(?mondo),"http://purl.obolibrary.org/obo/MONDO_"))
        bind(uri(concat(?rewritePattern,strafter(str(?external),?mondoPattern))) as ?rewrite)
        #        ?rewrite a ?t
    }
}
```

> Added 43154 statements. Update took 6.5s, moments ago.

### Isolate undefined rewrites

```SPARQL
insert {
    graph <http://example.com/resource/undefinedRewrites> {
        ?mondo ?p ?rewrite
    }
}
where {
    {
        {
            graph <http://example.com/resource/rewrites_MonDO_object> {
                ?mondo ?p ?rewrite
            }
        } 
        union {
            {
                graph <http://example.com/resource/rewrites_MonDO_subject> {
                    ?mondo ?p ?rewrite
                }
            }  
        }
    }
    minus {
        ?rewrite a ?t
    }
}
```

### Delete undefined reverse rewrites

```SPARQL
delete {
    graph <http://example.com/resource/rewrites_MonDO_object> {
        ?mondo ?p ?rewrite
    }
}
where {
    graph <http://example.com/resource/undefinedRewrites> {
        ?mondo ?p ?rewrite
    }
}
```

> Removed 9328 statements. Update took 0.6s, minutes ago.

### Delete undefined forward rewrites

```SPARQL
delete {
    graph <http://example.com/resource/rewrites_MonDO_subject> {
        ?mondo ?p ?rewrite
    }
}
where {
    graph <http://example.com/resource/undefinedRewrites> {
        ?mondo ?p ?rewrite
    }
}
```

> Removed 58530 statements. Update took 1.2s, moments ago.

### Isolate ICD9 ranges

```SPARQL
insert {
    graph <http://example.com/resource/icd9range> {
        ?mondo ?p ?rewrite
    }
}
where {
    {
        {
            graph <http://example.com/resource/rewrites_MonDO_object> {
                ?mondo ?p ?rewrite
            }
        } 
        union {
            {
                graph <http://example.com/resource/rewrites_MonDO_subject> {
                    ?mondo ?p ?rewrite
                }
            }  
        }
    }
    filter(strstarts(str( ?rewrite ),"http://purl.bioontology.org/ontology/ICD9CM/"))
    filter(contains(str( ?rewrite),"-"))
}
```

> Added 31 statements. Update took 0.4s, minutes ago.

### Delete forward ICD9 ranges

```SPARQL
delete {
    graph <http://example.com/resource/rewrites_MonDO_subject> {
        ?mondo ?p ?rewrite
    }
}
where {
    graph <http://example.com/resource/icd9range> {
        ?mondo ?p ?rewrite
    }
}
```

_Deleted all 31 of the isolated triples. Timing lost._



### Delete reverse ICD9 ranges

```SPARQL
delete {
    graph <http://example.com/resource/rewrites_MonDO_object> {
        ?mondo ?p ?rewrite
    }
}
where {
    graph <http://example.com/resource/icd9range> {
        ?mondo ?p ?rewrite
    }
}
```

_Deleted 0 of the isolated triples. Timing lost._

### Isolate re-writable external-link statements from MonDO

This leaves in place all `subClassOf` statements, and any `equivalentClass` statements that take a restriction, or other blank node as their object. 

```SPARQL
PREFIX mydata: <http://example.com/resource/>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
PREFIX owl: <http://www.w3.org/2002/07/owl#>
insert {
    graph <http://example.com/resource/mondoOriginals> {
        ?s ?p ?o
    }
}
where {
    graph <http://purl.obolibrary.org/obo/mondo.owl> {
        values ?p {
            skos:exactMatch
            skos:closeMatch
            # skos:narrowMatch
            owl:equivalentClass
        }
        ?s ?p ?o
        filter(isuri(?o))
    }
}
```

> Added 167354 statements. Update took 3.9s, minutes ago.

### Delete re-writable external-link statements from _MonDO named graph_

They're still available in the isolation graph above (unless a decision is made to clear it.)

```SPARQL
PREFIX mydata: <http://example.com/resource/>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
PREFIX owl: <http://www.w3.org/2002/07/owl#>
delete {
    graph <http://purl.obolibrary.org/obo/mondo.owl> {
        ?s ?p ?o
    }
}
where {
    graph <http://example.com/resource/mondoOriginals> {
        ?s ?p ?o
    }
}
```

> Removed 167354 statements. Update took 3.1s, moments ago.

### Tag ICD9->SNOMED predicates that should take a Boolean object

```SPARQL
PREFIX mondo: <http://purl.obolibrary.org/obo/mondo#>
PREFIX mydata: <http://example.com/resource/>
PREFIX obo: <http://purl.obolibrary.org/obo/>
PREFIX ontologies: <http://transformunify.org/ontologies/>
PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
PREFIX sm: <tag:stardog:api:mapping:>
PREFIX turbo: <http://transformunify.org/ontologies/>
PREFIX umls: <http://bioportal.bioontology.org/ontologies/umls/>
PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
insert data {
    graph <https://www.nlm.nih.gov/research/umls/mapping_projects/icd9cm_to_snomedct.html> {
        mydata:IS_CURRENT_ICD mydata:intPlaceholder true .
        mydata:IS_NEC mydata:intPlaceholder true .
        mydata:IS_1-1MAP mydata:intPlaceholder true .
        mydata:IN_CORE mydata:intPlaceholder true .
        <https://www.nlm.nih.gov/research/umls/mapping_projects/icd9cm_to_snomedct.html> rdfs:comment "NLM ICD9CM to SNOMED mapping, with predicates taking booleans tagged" .
    }
}
```

> Added 5 statements. Update took 0.1s, moments ago.


### Enforce (cast) Boolean objects

```SPARQL
PREFIX mondo: <http://purl.obolibrary.org/obo/mondo#>
PREFIX mydata: <http://example.com/resource/>
PREFIX obo: <http://purl.obolibrary.org/obo/>
PREFIX ontologies: <http://transformunify.org/ontologies/>
PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
PREFIX sm: <tag:stardog:api:mapping:>
PREFIX turbo: <http://transformunify.org/ontologies/>
PREFIX umls: <http://bioportal.bioontology.org/ontologies/umls/>
PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
insert {
    graph <https://www.nlm.nih.gov/research/umls/mapping_projects/icd9cm_to_snomedct.html_boolean> {
        ?s ?p ?boolean
    }
} where {
    graph <https://www.nlm.nih.gov/research/umls/mapping_projects/icd9cm_to_snomedct.html> {
        ?p mydata:intPlaceholder true .
        ?s ?p ?int .
        filter(datatype(?int)!=xsd:boolean)
        bind(if(?int = "1", true, false) as ?boolean)
    }
}
```

_This has already been applied to the_ `www_nlm_nih_gov_research_umls_mapping_projects_icd9cm_to_snomedct.ttl` _input file, so it may seem like no action is taking place. There's no harm in leaving these steps in, and they might be required if the two (CSV) ICD9->SNOMED mapping  files had to be re-instantiated with OntoRefine or some other technology._

Imported successfully in 18s.

> Added 5 statements. Update took 0.1s, moments ago.

### Delete the triples that have undesired integer objects

```SPARQL
PREFIX mondo: <http://purl.obolibrary.org/obo/mondo#>
PREFIX mydata: <http://example.com/resource/>
PREFIX obo: <http://purl.obolibrary.org/obo/>
PREFIX ontologies: <http://transformunify.org/ontologies/>
PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
PREFIX sm: <tag:stardog:api:mapping:>
PREFIX turbo: <http://transformunify.org/ontologies/>
PREFIX umls: <http://bioportal.bioontology.org/ontologies/umls/>
PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
delete {
    ?s ?p ?int .
} where {
    graph <https://www.nlm.nih.gov/research/umls/mapping_projects/icd9cm_to_snomedct.html> {
        ?p mydata:intPlaceholder true .
        ?s ?p ?int .
        filter(datatype(?int)!=xsd:boolean)
    }
}
```

>  The number of statements did not change

### Migrate the desired triples with Boolean objects out of the temporary graph

```SPARQL
PREFIX mondo: <http://purl.obolibrary.org/obo/mondo#>
PREFIX mydata: <http://example.com/resource/>
PREFIX obo: <http://purl.obolibrary.org/obo/>
PREFIX ontologies: <http://transformunify.org/ontologies/>
PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
PREFIX sm: <tag:stardog:api:mapping:>
PREFIX turbo: <http://transformunify.org/ontologies/>
PREFIX umls: <http://bioportal.bioontology.org/ontologies/umls/>
PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
insert {
    graph <https://www.nlm.nih.gov/research/umls/mapping_projects/icd9cm_to_snomedct.html> {
        ?s ?p ?boolean
    }
}
where {
    graph <https://www.nlm.nih.gov/research/umls/mapping_projects/icd9cm_to_snomedct.html_boolean> {
        ?s ?p ?boolean
    }
}
```

> The number of statements did not change

### Clear the temporary graph

```SPARQL
clear graph <https://www.nlm.nih.gov/research/umls/mapping_projects/icd9cm_to_snomedct.html_boolean>
```

> The number of statements did not change

### Materialize the ICD9->SNOMED mappings

```SPARQL
PREFIX mondo: <http://purl.obolibrary.org/obo/mondo#>
PREFIX mydata: <http://example.com/resource/>
PREFIX obo: <http://purl.obolibrary.org/obo/>
PREFIX ontologies: <http://transformunify.org/ontologies/>
PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
PREFIX sm: <tag:stardog:api:mapping:>
PREFIX turbo: <http://transformunify.org/ontologies/>
PREFIX umls: <http://bioportal.bioontology.org/ontologies/umls/>
PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
insert {
    graph <https://www.nlm.nih.gov/research/umls/mapping_projects/icd9cm_to_snomedct.html> {
        ?icd <https://www.nlm.nih.gov/research/umls/mapping_projects/icd9cm_to_snomedct.html> ?snomed
    }
} where {
    graph <https://www.nlm.nih.gov/research/umls/mapping_projects/icd9cm_to_snomedct.html> {
        ?s mydata:ICD_CODE    ?ICD_CODE    ;
           mydata:SNOMED_CID ?SNOMED_CID .
        bind(uri(concat("http://purl.bioontology.org/ontology/SNOMEDCT/", ?SNOMED_CID)) as ?snomed)
        bind(uri(concat("http://purl.bioontology.org/ontology/ICD9CM/", ?ICD_CODE)) as ?icd)
    }
    graph <http://purl.bioontology.org/ontology/SNOMEDCT/> {
        ?snomed a owl:Class
    }
    graph <http://purl.bioontology.org/ontology/ICD9CM/> {
        ?icd a owl:Class
    }
}
```

> The number of statements did not change

### _End of ICD9->SNOMED steps_

### Isolate statements about ICD10 siblings

_These statements don't add any knowledge over having a shared super-class, and they clutter up visualizations._

```SPARQL
PREFIX mondo: <http://purl.obolibrary.org/obo/mondo#>
PREFIX mydata: <http://example.com/resource/>
PREFIX obo: <http://purl.obolibrary.org/obo/>
PREFIX ontologies: <http://transformunify.org/ontologies/>
PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
PREFIX sm: <tag:stardog:api:mapping:>
PREFIX turbo: <http://transformunify.org/ontologies/>
PREFIX umls: <http://bioportal.bioontology.org/ontologies/umls/>
PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
insert  {
    graph <http://example.com/resource/ICD10CM_siblings> {
        ?s <http://purl.bioontology.org/ontology/ICD10CM/SIB> ?o
    }
}
where {
    graph <http://purl.bioontology.org/ontology/ICD10CM/> {
        ?s <http://purl.bioontology.org/ontology/ICD10CM/SIB> ?o
    }
}
```

> Added 458236 statements

_Lost the timing data_

### Delete siblings statements from ICD10 graph

```SPARQL
PREFIX mondo: <http://purl.obolibrary.org/obo/mondo#>
PREFIX mydata: <http://example.com/resource/>
PREFIX obo: <http://purl.obolibrary.org/obo/>
PREFIX ontologies: <http://transformunify.org/ontologies/>
PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
PREFIX sm: <tag:stardog:api:mapping:>
PREFIX turbo: <http://transformunify.org/ontologies/>
PREFIX umls: <http://bioportal.bioontology.org/ontologies/umls/>
PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
delete  {
    graph <http://purl.bioontology.org/ontology/ICD10CM/> {
        ?s <http://purl.bioontology.org/ontology/ICD10CM/SIB> ?o
    }
}
where {
    graph <http://purl.bioontology.org/ontology/ICD10CM/> {
        ?s <http://purl.bioontology.org/ontology/ICD10CM/SIB> ?o
    }
}
```

> Removed 458236 statements. Update took 8.8s, moments ago.


### Isolate statements about ICD9 siblings

_These statements don't add any knowledge over having a shared super-class, and they clutter up visualizations._

```SPARQL
PREFIX mondo: <http://purl.obolibrary.org/obo/mondo#>
PREFIX mydata: <http://example.com/resource/>
PREFIX obo: <http://purl.obolibrary.org/obo/>
PREFIX ontologies: <http://transformunify.org/ontologies/>
PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
PREFIX sm: <tag:stardog:api:mapping:>
PREFIX turbo: <http://transformunify.org/ontologies/>
PREFIX umls: <http://bioportal.bioontology.org/ontologies/umls/>
PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
insert  {
    graph <http://example.com/resource/ICD9CM_siblings> {
        ?s <http://purl.bioontology.org/ontology/ICD9CM/SIB> ?o
    }
}
where {
    graph <http://purl.bioontology.org/ontology/ICD9CM/> {
        ?s <http://purl.bioontology.org/ontology/ICD9CM/SIB> ?o
    }
}
```

> Added 138124 statements. Update took 2.7s, minutes ago.


### Delete siblings statements from ICD9 graph

```SPARQL
PREFIX mondo: <http://purl.obolibrary.org/obo/mondo#>
PREFIX mydata: <http://example.com/resource/>
PREFIX obo: <http://purl.obolibrary.org/obo/>
PREFIX ontologies: <http://transformunify.org/ontologies/>
PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
PREFIX sm: <tag:stardog:api:mapping:>
PREFIX turbo: <http://transformunify.org/ontologies/>
PREFIX umls: <http://bioportal.bioontology.org/ontologies/umls/>
PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
delete  {
    graph <http://purl.bioontology.org/ontology/ICD9CM/> {
        ?s <http://purl.bioontology.org/ontology/ICD9CM/SIB> ?o
    }
}
where {
    graph <http://purl.bioontology.org/ontology/ICD9CM/> {
        ?s <http://purl.bioontology.org/ontology/ICD9CM/SIB> ?o
    }
}
```

> Removed 138124 statements. Update took 2.5s, moments ago.

### Assert the named graph in which terms are defined

```SPARQL
PREFIX mondo: <http://purl.obolibrary.org/obo/mondo#>
PREFIX mydata: <http://example.com/resource/>
PREFIX obo: <http://purl.obolibrary.org/obo/>
PREFIX ontologies: <http://transformunify.org/ontologies/>
PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
PREFIX sm: <tag:stardog:api:mapping:>
PREFIX turbo: <http://transformunify.org/ontologies/>
PREFIX umls: <http://bioportal.bioontology.org/ontologies/umls/>
PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
insert {
    graph <http://example.com/resource/definedIn> {
        ?s <http://example.com/resource/definedIn> ?g
    }
} where {
    graph ?g {
        ?s a owl:Class
    }
}
```

> Added 593053 statements. Update took 15s, moments ago.

### Materialize simple MonDO disease axioms

_This only acts on subclasses of simple `owl:Restriction`s. It (probably?) won't act on `rdfs:subClassOf` statements whose object is a  blank node, intersection, etc. Same thing for any `owl:equivalentClass` statements, although they tend to have those complex objects anyway._

```SPARQL
PREFIX mondo: <http://purl.obolibrary.org/obo/mondo#>
PREFIX mydata: <http://example.com/resource/>
PREFIX obo: <http://purl.obolibrary.org/obo/>
PREFIX ontologies: <http://transformunify.org/ontologies/>
PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
PREFIX sm: <tag:stardog:api:mapping:>
PREFIX turbo: <http://transformunify.org/ontologies/>
PREFIX umls: <http://bioportal.bioontology.org/ontologies/umls/>
PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
insert {
    graph mydata:materializedSimpleMondoAxioms {
        ?term ?op ?valSource
    }
}
where {
    graph obo:mondo.owl {
        ?term rdfs:subClassOf* ?restr .
        # ?term rdfs:label ?termlab .
        ?restr a owl:Restriction ;
               owl:onProperty ?op ;
               owl:someValuesFrom ?valSource .
        # ?op rdfs:label ?opl .
        # ?valSource rdfs:label ?vsl .
        filter(isuri( ?term ))
    }
}
```

> Added 213298 statements. Update took 1m 26s, moments ago.

### What are the roots of the ICD9CM taxonomy?

```SPARQL
PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
select 
distinct ?s ?l
where {
    graph <http://purl.bioontology.org/ontology/ICD9CM/> {
        ?s a owl:Class .
        optional {
            ?s skos:prefLabel ?l
        }
        minus {
            ?s rdfs:subClassOf ?parent
        }
    }
}
```

> Showing results from 1 to 2 of 2. Query took 0.4s, minutes ago.

**s**|**l**
:-----|-----:
http://purl.bioontology.org/ontology/STY/T051|Event
http://purl.bioontology.org/ontology/STY/T071|Entity

#### BioPortal says

- [DISEASES AND INJURIES](https://bioportal.bioontology.org/ontologies/ICD9CM/?p=classes&conceptid=http%3A%2F%2Fpurl.bioontology.org%2Fontology%2FICD9CM%2F001-999.99)
  -  ICD9CM:001-999.99
- [PROCEDURES](https://bioportal.bioontology.org/ontologies/ICD9CM/?p=classes&conceptid=http%3A%2F%2Fpurl.bioontology.org%2Fontology%2FICD9CM%2F00-99.99)
  -   ICD9CM:00-99.99
- [SUPPLEMENTARY CLASSIFICATION OF EXTERNAL CAUSES OF INJURY AND POISONING](https://bioportal.bioontology.org/ontologies/ICD9CM/?p=classes&conceptid=http%3A%2F%2Fpurl.bioontology.org%2Fontology%2FICD9CM%2FE000-E999.9)
  -   ICD9CM:E000-E999.9
- [SUPPLEMENTARY CLASSIFICATION OF FACTORS INFLUENCING HEALTH STATUS AND CONTACT WITH HEALTH SERVICES](https://bioportal.bioontology.org/ontologies/ICD9CM/?p=classes&conceptid=http%3A%2F%2Fpurl.bioontology.org%2Fontology%2FICD9CM%2FV01-V91.99)
  - ICD9CM:V01-V91.99

### Transitively materialize sub-classes of ICD9 Diseases and Injuries

```SPARQL
PREFIX mondo: <http://purl.obolibrary.org/obo/mondo#>
PREFIX mydata: <http://example.com/resource/>
PREFIX obo: <http://purl.obolibrary.org/obo/>
PREFIX ontologies: <http://transformunify.org/ontologies/>
PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
PREFIX sm: <tag:stardog:api:mapping:>
PREFIX turbo: <http://transformunify.org/ontologies/>
PREFIX umls: <http://bioportal.bioontology.org/ontologies/umls/>
PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
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

> Added 81980 statements. Update took 12s, minutes ago.

### What are the roots of the ICD10CM taxonomy?

```SPARQL
PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
select 
distinct ?s ?l
where {
    graph <http://purl.bioontology.org/ontology/ICD10CM/> {
        ?s a owl:Class .
        optional {
            ?s skos:prefLabel ?l
        }
        minus {
            ?s rdfs:subClassOf ?parent
        }
    }
}
```

> Showing results from 1 to 3 of 3. Query took 1.2s, moments ago.

**s**|**l**
:-----|:-----
http://purl.bioontology.org/ontology/STY/T051|Event
http://purl.bioontology.org/ontology/STY/T071|Entity
http://purl.bioontology.org/ontology/ICD10CM/ICD-10-CM|ICD-10-CM TABULAR LIST of DISEASES and INJURIES

#### BioPortal says

- [Certain conditions originating in the perinatal period (P00-P96)](https://bioportal.bioontology.org/ontologies/ICD10CM/?p=classes&conceptid=http%3A%2F%2Fpurl.bioontology.org%2Fontology%2FICD10CM%2FP00-P96)
- [Certain infectious and parasitic diseases (A00-B99)](https://bioportal.bioontology.org/ontologies/ICD10CM/?p=classes&conceptid=http%3A%2F%2Fpurl.bioontology.org%2Fontology%2FICD10CM%2FA00-B99)
- [Congenital malformations, deformations and chromosomal abnormalities (Q00-Q99)](https://bioportal.bioontology.org/ontologies/ICD10CM/?p=classes&conceptid=http%3A%2F%2Fpurl.bioontology.org%2Fontology%2FICD10CM%2FQ00-Q99)
- [Diseases of the blood and blood-forming organs and certain disorders involving the immune mechanism (D50-D89)](https://bioportal.bioontology.org/ontologies/ICD10CM/?p=classes&conceptid=http%3A%2F%2Fpurl.bioontology.org%2Fontology%2FICD10CM%2FD50-D89)
- [Diseases of the circulatory system (I00-I99)](https://bioportal.bioontology.org/ontologies/ICD10CM/?p=classes&conceptid=http%3A%2F%2Fpurl.bioontology.org%2Fontology%2FICD10CM%2FI00-I99)
- [Diseases of the digestive system (K00-K95)](https://bioportal.bioontology.org/ontologies/ICD10CM/?p=classes&conceptid=http%3A%2F%2Fpurl.bioontology.org%2Fontology%2FICD10CM%2FK00-K95)
- [Diseases of the ear and mastoid process (H60-H95)](https://bioportal.bioontology.org/ontologies/ICD10CM/?p=classes&conceptid=http%3A%2F%2Fpurl.bioontology.org%2Fontology%2FICD10CM%2FH60-H95)
- [Diseases of the eye and adnexa (H00-H59)](https://bioportal.bioontology.org/ontologies/ICD10CM/?p=classes&conceptid=http%3A%2F%2Fpurl.bioontology.org%2Fontology%2FICD10CM%2FH00-H59)
- [Diseases of the genitourinary system (N00-N99)](https://bioportal.bioontology.org/ontologies/ICD10CM/?p=classes&conceptid=http%3A%2F%2Fpurl.bioontology.org%2Fontology%2FICD10CM%2FN00-N99)
- [Diseases of the musculoskeletal system and connective tissue (M00-M99)](https://bioportal.bioontology.org/ontologies/ICD10CM/?p=classes&conceptid=http%3A%2F%2Fpurl.bioontology.org%2Fontology%2FICD10CM%2FM00-M99)
- [Diseases of the nervous system (G00-G99)](https://bioportal.bioontology.org/ontologies/ICD10CM/?p=classes&conceptid=http%3A%2F%2Fpurl.bioontology.org%2Fontology%2FICD10CM%2FG00-G99)
- [Diseases of the respiratory system (J00-J99)](https://bioportal.bioontology.org/ontologies/ICD10CM/?p=classes&conceptid=http%3A%2F%2Fpurl.bioontology.org%2Fontology%2FICD10CM%2FJ00-J99)
- [Diseases of the skin and subcutaneous tissue (L00-L99)](https://bioportal.bioontology.org/ontologies/ICD10CM/?p=classes&conceptid=http%3A%2F%2Fpurl.bioontology.org%2Fontology%2FICD10CM%2FL00-L99)
- [Endocrine, nutritional and metabolic diseases (E00-E89)](https://bioportal.bioontology.org/ontologies/ICD10CM/?p=classes&conceptid=http%3A%2F%2Fpurl.bioontology.org%2Fontology%2FICD10CM%2FE00-E89)
- [External causes of morbidity (V00-Y99)](https://bioportal.bioontology.org/ontologies/ICD10CM/?p=classes&conceptid=http%3A%2F%2Fpurl.bioontology.org%2Fontology%2FICD10CM%2FV00-Y99)
- [Factors influencing health status and contact with health services (Z00-Z99)](https://bioportal.bioontology.org/ontologies/ICD10CM/?p=classes&conceptid=http%3A%2F%2Fpurl.bioontology.org%2Fontology%2FICD10CM%2FZ00-Z99)
- [Injury, poisoning and certain other consequences of external causes (S00-T88)](https://bioportal.bioontology.org/ontologies/ICD10CM/?p=classes&conceptid=http%3A%2F%2Fpurl.bioontology.org%2Fontology%2FICD10CM%2FS00-T88)
- [Mental, Behavioral and Neurodevelopmental disorders (F01-F99)](https://bioportal.bioontology.org/ontologies/ICD10CM/?p=classes&conceptid=http%3A%2F%2Fpurl.bioontology.org%2Fontology%2FICD10CM%2FF01-F99)
- [Neoplasms (C00-D49)](https://bioportal.bioontology.org/ontologies/ICD10CM/?p=classes&conceptid=http%3A%2F%2Fpurl.bioontology.org%2Fontology%2FICD10CM%2FC00-D49)
- [Pregnancy, childbirth and the puerperium (O00-O9A)](https://bioportal.bioontology.org/ontologies/ICD10CM/?p=classes&conceptid=http%3A%2F%2Fpurl.bioontology.org%2Fontology%2FICD10CM%2FO00-O9A)
- [Symptoms, signs and abnormal clinical and laboratory findings, not elsewhere classified (R00-R99)](https://bioportal.bioontology.org/ontologies/ICD10CM/?p=classes&conceptid=http%3A%2F%2Fpurl.bioontology.org%2Fontology%2FICD10CM%2FR00-R99)

### Transitively materialize sub-classes of ICD10 classes

_Should procedures, external factors, etc be removed from this materialization?_

```SPARQL
PREFIX mondo: <http://purl.obolibrary.org/obo/mondo#>
PREFIX mydata: <http://example.com/resource/>
PREFIX obo: <http://purl.obolibrary.org/obo/>
PREFIX ontologies: <http://transformunify.org/ontologies/>
PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
PREFIX sm: <tag:stardog:api:mapping:>
PREFIX turbo: <http://transformunify.org/ontologies/>
PREFIX umls: <http://bioportal.bioontology.org/ontologies/umls/>
PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
insert {
    graph mydata:ICD10TransitiveSubClasses {
        ?sub rdfs:subClassOf ?s .
    }
}
where {
    graph <http://purl.bioontology.org/ontology/ICD10CM/> {
        # + or * ?
        ?s rdfs:subClassOf+ owl:Thing .
        ?sub rdfs:subClassOf* ?s .
    }
}
```

> Added 565588 statements. Update took 1m 24s, moments ago.

----

[http://purl.bioontology.org/ontology/SNOMEDCT/64572001](http://purl.bioontology.org/ontology/SNOMEDCT/64572001) doesn't have any sub-classes?

Index on 

- http://www.w3.org/2000/01/rdf-schema#label
- http://www.w3.org/2004/02/skos/core#prefLabel
- URIs
- _Takes less than 5 minutes!_

Then look for AIDS-associated disorder, http://purl.bioontology.org/ontology/SNOMEDCT/420721002

Found [http://purl.bioontology.org/ontology/SNOMEDCT_US/420721002](http://purl.bioontology.org/ontology/SNOMEDCT_US/420721002)


### Transitively materialize MonDO sub-classes

_No up-front filtering this time... apply at query time. Exclude any diseases that are a `rdfs:subClassOf*` rare, congenital or syndromic?_

_Constrain to ["disease or disorder", `obo:MONDO_0000001`](http://purl.obolibrary.org/obo/MONDO_0000001)?_

```SPARQL
PREFIX mydata: <http://example.com/resource/>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX obo: <http://purl.obolibrary.org/obo/>
insert {
    graph mydata:MondoTransitiveSubClasses {
        ?mondoSub rdfs:subClassOf ?mondo .
    }
}
where {
    graph <http://purl.obolibrary.org/obo/mondo.owl> {
        ?mondoSub rdfs:subClassOf* ?mondo .
    }
    # minus {
    #     graph <http://example.com/resource/materializedMondoAxioms> {
    #         ?mondoSub obo:RO_0002573 obo:MONDO_0021152 .
    #     }
    # }
}
```

> Added 1044847 statements. Update took 1m 31s, minutes ago.

## 24 paths in repo `dd_include_icd_transitivity` 

_on http://turbo-prd-db01.pmacs.upenn.edu:7200/ _

```R
 [1] "mydata:m-dbxr-i9"                        "mydata:m-dbxr-i10"                       "mydata:m-dbxr-snomed-shared_cui-i9"     
 [4] "mydata:m-eqClass-snomed-shared_cui-i9"   "mydata:m-exMatch-snomed-shared_cui-i9"   "mydata:m-cMatch-snomed-shared_cui-i9"   
 [7] "mydata:m-dbxr-snomed-shared_cui-i10"     "mydata:m-eqClass-snomed-shared_cui-i10"  "mydata:m-exMatch-snomed-shared_cui-i10" 
[10] "mydata:m-cMatch-snomed-shared_cui-i10"   "mydata:m-dbxr-snomed-NLM_mappings-i9"    "mydata:m-eqClass-snomed-NLM_mappings-i9"
[13] "mydata:m-exMatch-snomed-NLM_mappings-i9" "mydata:m-cMatch-snomed-NLM_mappings-i9"  "mydata:i9-eqClass-m"                    
[16] "mydata:i10-eqClass-m"                    "mydata:m-dbxr-shared_cui-i9"             "mydata:m-exMatch-shared_cui-i9"         
[19] "mydata:m-cMatch-shared_cui-i9"           "mydata:m-dbxr-shared_cui-i10"            "mydata:m-exMatch-shared_cui-i10"        
[22] "mydata:m-cMatch-shared_cui-i10"          "mydata:i9-shared_cui-eqClass-m"          "mydata:i10-shared_cui-eqClass-m" 
```

## paths from `Hayden_diseaseToDiagnosis`

1. http://graphBuilder.org/mondoToIcdMappings
1. http://graphBuilder.org/mondoToIcdMappingsFullSemantics
1. owl:equivalentClass_snomed_with_icd9_map
1. oboInOwl:hasDbXref_snomed_with_icd9_map
1. skos:exactMatch_snomed_with_icd9_map
1. owl:equivalentClass_snomed_shared_cui
1. oboInOwl:hasDbXref_snomed_shared_cui
1. skos:exactMatch_snomed_shared_cui
1. oboInOwl:hasDbXref_cui
1. skos:exactMatch_cui
1. oboInOwl:hasDbXref_icd9_without_range_subclasses
1. owl:cui_equivalentClass
1. owl:icd9_equivalentClass
1. oboInOwl:hasDbXref_icd10
1. owl:icd10_equivalentClass
1. skos:closeMatch_snomed_with_icd9_map
1. skos:closeMatch_snomed_shared_cui
1. skos:closeMatch_cui


## There are now separate queries for separate path families

These queries are possible with no additional materialization and can be concatenated row-wise

### MonDO's direct paths to ICD codes

In this case the _detailed_ paths would be the Cartesian product of the two `?rewriteGraph`s (which capture the orientation of MonDO's assertion) and the  `?assertedPredicate`s, which appear to be limited to two

1. `mydata:mdbxr`
1. `owl:equivalentClass`

```SPARQL
PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
select 
distinct ?m ?rewriteGraph ?assertedPredicate ?icdVer ?icdCode ("mondo->icd" as ?pathFamily)
where {
    graph <http://example.com/resource/MondoTransitiveSubClasses> {
        ?m rdfs:subClassOf <http://purl.obolibrary.org/obo/MONDO_0000001> .
    }
    graph ?rewriteGraph {
        ?m ?assertedPredicate ?icd
    }
    {
        {
            graph <http://purl.bioontology.org/ontology/ICD10CM/> {
                ?icd skos:notation ?icdCode .
            }
            bind(10 as ?icdVer)
        }
        union
        {
            graph <http://purl.bioontology.org/ontology/ICD9CM/> {
                ?icd skos:notation ?icdCode
            }
            bind(9 as ?icdVer)
        } 
    }
}
order by ?m
```

Timing: The sorted results (raw or **pre-distinct-ified**) from this query across all of MonDO and all of ICD9/10 codes can be **downloaded from AWS** to Penn in roughly 10 seconds. Unsorted would be faster.

This covers paths

1. mydata:m-dbxr-i10
1. mydata:i10-eqClass-m
1. mydata:m-dbxr-i9
1. mydata:i9-eqClass-m

----

### Real-time MonDO axiom filtering example

----

### MonDO's paths to ICD codes via a CUI

This corresponds to paths 

1. mydata:m-dbxr-shared_cui-i9 
1. mydata:m-exMatch-shared_cui-i9 
1. mydata:m-cMatch-shared_cui-i9 
1. mydata:m-dbxr-shared_cui-i10 
1. mydata:m-exMatch-shared_cui-i10 
1. mydata:m-cMatch-shared_cui-i10 
1. mydata:i9-shared_cui-eqClass-m 
1. mydata:i10-shared_cui-eqClass-m

```SPARQL
PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
PREFIX mydata: <http://example.com/resource/>
select 
distinct ?m ?rewriteGraph ?assertedPredicate ?icdVer ?icdCode ("mondo->CUI->icd" as ?pathFamily)
where {
    graph <http://example.com/resource/MondoTransitiveSubClasses> {
        ?m rdfs:subClassOf <http://purl.obolibrary.org/obo/MONDO_0000001> .
    }
    graph ?rewriteGraph {
        ?m ?assertedPredicate ?cui
    }
    graph <http://example.com/resource/materializedCui> {
        ?cui a mydata:materializedCui .
        ?icd mydata:materializedCui ?cui .
    }
    {
        {
            graph <http://purl.bioontology.org/ontology/ICD10CM/> {
                ?icd skos:notation ?icdCode .
            }
            bind(10 as ?icdVer)
        }
        union
        {
            graph <http://purl.bioontology.org/ontology/ICD9CM/> {
                ?icd skos:notation ?icdCode
            }
            bind(9 as ?icdVer)
        } 
    }
}
order by ?m
```

### MonDO's paths to ICD10 codes via SNOMED and a CUI

All of the path family queries can have MonDO or ICD transitivity bolted on as a module. However, the queries that traverse SNOMED will have transitive and non-transitive alternative forms. The non-trasivite choice is shown here now, and the transitive choice will be added soon. A query session would use **either** transitive **or** non-transitive, and that would become another attribute of the paths.

This corresonpds to paths

1. mydata:m-dbxr-snomed-shared_cui-i9 
1. mydata:m-eqClass-snomed-shared_cui-i9 
1. mydata:m-exMatch-snomed-shared_cui-i9 
1. mydata:m-cMatch-snomed-shared_cui-i9 
1. mydata:m-dbxr-snomed-shared_cui-i10 
1. mydata:m-eqClass-snomed-shared_cui-i10 
1. mydata:m-exMatch-snomed-shared_cui-i10 
1. ydata:m-cMatch-snomed-shared_cui-i10


```SPARQL
PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
PREFIX mydata: <http://example.com/resource/>
select 
# enriched for icd10
# there's a seperate path family for snomed -> icd9
distinct 
#?icdVer
?m ?rewriteGraph ?assertedPredicate ?icdVer ?icdCode ("mondo->snomed->CUI->icd" as ?pathFamily)
where {
    graph <http://example.com/resource/MondoTransitiveSubClasses> {
        ?m rdfs:subClassOf <http://purl.obolibrary.org/obo/MONDO_0000001> .
    }
    graph ?rewriteGraph {
        ?m ?assertedPredicate ?snomed
    }
    graph <http://purl.bioontology.org/ontology/SNOMEDCT_US/> {
        ?snomed a owl:Class
    }
    graph <http://example.com/resource/materializedCui> {
        ?snomed mydata:materializedCui ?cui .
        ?icd mydata:materializedCui ?cui .
    }
    {
        {
            graph <http://purl.bioontology.org/ontology/ICD10CM/> {
                ?icd skos:notation ?icdCode .
            }
            bind(10 as ?icdVer)
        }
        union
        {
            graph <http://purl.bioontology.org/ontology/ICD9CM/> {
                ?icd skos:notation ?icdCode
            }
            bind(9 as ?icdVer)
        } 
    }
}
```

#### MonDO's paths to ICD10 codes via SNOMED and a CUI as above, with transitivity over SNOMED sublcasses

```SPARQL
PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
PREFIX mydata: <http://example.com/resource/>
select 
# enriched for icd10
# there's a seperate path family for snomed -> icd9
distinct 
#?icdVer
?m ?rewriteGraph ?assertedPredicate ?icdVer ?icdCode ("mondo->snomed->CUI->icd" as ?pathFamily)
where {
    graph <http://example.com/resource/MondoTransitiveSubClasses> {
        ?m rdfs:subClassOf <http://purl.obolibrary.org/obo/MONDO_0000001> .
    }
    graph ?rewriteGraph {
        ?m ?assertedPredicate ?presnomed
    }
    graph <http://example.com/resource/SnomedDiseaseTransitiveSubClasses> {
        ?snomed rdfs:subClassOf ?presnomed
    }
    graph <http://purl.bioontology.org/ontology/SNOMEDCT_US/> {
        ?snomed a owl:Class
    }
    graph <http://example.com/resource/materializedCui> {
        ?snomed mydata:materializedCui ?cui .
        ?icd mydata:materializedCui ?cui .
    }
    {
        {
            graph <http://purl.bioontology.org/ontology/ICD10CM/> {
                ?icd skos:notation ?icdCode .
            }
            bind(10 as ?icdVer)
        }
        union
        {
            graph <http://purl.bioontology.org/ontology/ICD9CM/> {
                ?icd skos:notation ?icdCode
            }
            bind(9 as ?icdVer)
        } 
    }
}
```

### Last path family: MonDO to SNOMED to NLMs mappings to ICD9 

This corresonpds to paths

1. mydata:m-dbxr-snomed-NLM_mappings-i9 
1. mydata:m-eqClass-snomed-NLM_mappings-i9 
1. mydata:m-exMatch-snomed-NLM_mappings-i9 
1. mydata:m-cMatch-snomed-NLM_mappings-i9


```SPARQL
PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
PREFIX mydata: <http://example.com/resource/>
PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
select 
distinct 
?m ?rewriteGraph ?assertedPredicate ?icdVer ?icdCode ("mondo->snomed->NLM mappings->icd9" as ?pathFamily)
where {
    graph <http://example.com/resource/MondoTransitiveSubClasses> {
        ?m rdfs:subClassOf <http://purl.obolibrary.org/obo/MONDO_0000001> .
    }
    graph ?rewriteGraph {
        ?m ?assertedPredicate ?snomed
    }
    graph <http://purl.bioontology.org/ontology/SNOMEDCT_US/> {
        ?snomed a owl:Class ;
                skos:notation ?CID .
    }
    graph <https://www.nlm.nih.gov/research/umls/mapping_projects/icd9cm_to_snomedct.html> {
        # this grpah has lots of filterable properties like
        # mydata:AVG_USAGE, mydata:CORE_USAGE, mydata:IN_CORE, mydata:IS_1-1MAP
        ?icd9cm_to_snomedct mydata:SNOMED_CID ?CID ;
                            mydata:ICD_CODE ?icdCode .
    }
    {
#        {
#            graph <http://purl.bioontology.org/ontology/ICD10CM/> {
#                ?icd skos:notation ?icdCode .
#            }
#            bind(10 as ?icdVer)
#        }
#        union
        {
            graph <http://purl.bioontology.org/ontology/ICD9CM/> {
                ?icd skos:notation ?icdCode
            }
            bind(9 as ?icdVer)
        } 
    }
}
```

