# disease_to_diagnosis_code

## Setup

Requires `disease_diagnosis.yaml`, based on `disease_diagnosis_template.yaml`, in the R home directory

Multiple different graphdb endpoints can be specified in their own blocks. The one of them is set in the default block, which also sets some other, non-graphdb-related parameters

Requires a grapdb server setup with a repo specified in the YAML file mentioned above.
Default settings can be used, except for no inference, and yes context index.

In turtle, that looks like

```Turtle
#
# RDF4J configuration template for a GraphDB EE worker repository
#
@prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#>.
@prefix rep: <http://www.openrdf.org/config/repository#>.
@prefix sr: <http://www.openrdf.org/config/repository/sail#>.
@prefix sail: <http://www.openrdf.org/config/sail#>.
@prefix owlim: <http://www.ontotext.com/trree/owlim#>.

[] a rep:Repository ;
    rep:repositoryID "disease_diagnosis_dev" ;
    rdfs:label "" ;
    rep:repositoryImpl [
        rep:repositoryType "owlim:ReplicationClusterWorker" ;
        rep:delegate [
            rep:repositoryType "owlim:MonitorRepository" ;
            sr:sailImpl [
                sail:sailType "owlimClusterWorker:Sail" ;
           
                owlim:owlim-license "" ;
    
                owlim:base-URL "http://example.org/owlim#" ;
                owlim:defaultNS "" ;
                owlim:entity-index-size "10000000" ;
                owlim:entity-id-size  "32" ;
                owlim:imports "" ;
            owlim:repository-type "file-repository" ;
                owlim:ruleset "empty" ;
                owlim:storage-folder "storage" ;
    
                owlim:enable-context-index "true" ;

                owlim:enablePredicateList "true" ;

                owlim:in-memory-literal-properties "true" ;
                owlim:enable-literal-index "true" ;

                owlim:check-for-inconsistencies "false" ;
                owlim:disable-sameAs  "true" ;
                owlim:query-timeout  "0" ;
                owlim:query-limit-results  "0" ;
                owlim:throw-QueryEvaluationException-on-timeout "false" ;
                owlim:read-only "false" ;
    owlim:nonInterpretablePredicates "http://www.w3.org/2000/01/rdf-schema#label;http://www.w3.org/1999/02/22-rdf-syntax-ns#type;http://www.ontotext.com/owlim/ces#gazetteerConfig;http://www.ontotext.com/owlim/ces#metadataConfig" ;
            ]
        ]
    ].
```
Authentication is optional. Blank usernames and passswords are OK in the YAML file as long as authentication has been disabled, or the disease diagnosis repostory has been set to "free" read/write.

Two RDF files, specified in the YAML file, must be loaded into the graphdb server's import folder. 

For example
- snomed.triples.file: 'SNOMED_2019AB_codeiris.ttl'
- icd9_to_snomed.triples.file: 'www_nlm_nih_gov_research_umls_mapping_projects_icd9cm_to_snomedct.ttl'

Among other ways, the graphdb import folder can be determined by logging into the web console (workbench), going to the import rdf -> server page, and clicking on a ? icon

Then just run `disease_diagnosis_dev`
