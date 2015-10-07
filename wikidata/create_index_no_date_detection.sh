#!/bin/bash
curl -XPUT 'http://127.0.0.1:9200/wikidata/?pretty=1'  -d '
{
    "mappings": {
        "_default_": {
            "date_detection": 0
        }
    }
}
'
