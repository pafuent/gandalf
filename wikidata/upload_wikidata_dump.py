#!/usr/bin/env python

import argparse
import json
import re
import subprocess
import sys

import elasticsearch


def process_record(record, es, index, doc_type):
    # Ignore the last character of the file, wich are a comma
    record = json.loads(record[0:-2])

    try:
        res = es.index(index=index, doc_type=doc_type, id=record['id'],
                       body=record)
    except elasticsearch.TransportError as ex:
        print ex

if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description='Uploads a Wikidata JSON dump to Elastic')
    parser.add_argument(
        'dump', type=str, help='path to a gzipped JSON dump')
    parser.add_argument(
        '--number-of-records', type=int, dest="number_of_records", default=-1,
        help='the number of records to upload. Use -1 for all the dump')
    parser.add_argument(
        '--filter-regex', type=str, dest="filter_regex", default="",
        help='a regular expression used to filter')
    parser.add_argument(
        '--elastic-host', type=str, dest="elastic_host",
        default="127.0.0.1",
        help='the elastic host to populate with the JSON dump')
    parser.add_argument(
        '--elastic-port', type=int, dest="elastic_port",
        default=9200,
        help='the elastic port to populate with the JSON dump')
    parser.add_argument(
        '--elastic-index', type=str, dest="elastic_index", default="wikidata",
        help='the elastic index to populate with the JSON dump')
    parser.add_argument(
        '--elastic-type', type=str, dest="elastic_type", default="json",
        help='the elastic type to populate with the JSON dump')
    args = parser.parse_args()

    es = elasticsearch.Elasticsearch(host=args.elastic_host,
                                     port=args.elastic_port)

    p = subprocess.Popen(["zcat", args.dump], stdout=subprocess.PIPE)
    dump_fd = p.stdout

    # ignore the first two lines
    next(dump_fd) # [
    next(dump_fd) # new line

    filter_regex = (
        re.compile(args.filter_regex) if args.filter_regex else None)

    try:
        if args.number_of_records == -1:
            for record in dump_fd:
                if filter_regex is None or filter_regex.search(record):
                    process_record(record, es, args.elastic_index,
                                   args.elastic_port)
        else:
            for i in range(0, args.number_of_records):
                record = next(dump_fd)
                if filter_regex is None or filter_regex.search(record):
                    process_record(record, es, args.elastic_index,
                                   args.elastic_port)
    except StopIteration:
        pass

    p.kill()
