#!/usr/bin/env python

import argparse
import gzip
import json
import re
import sys

import requests


def process_record(record, endpoint):
    # Ignore the last character of the file, wich are a comma
    record = json.loads(record[0:-2])

    result = requests.put("{0}/{1}".format(endpoint, record['id']),
                          json=record)
    if result.status_code not in (200, 201):
        print result.status_code
        print result.text

if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description='Uploads a Wikidata JSON dump to Elastic')
    parser.add_argument(
        'dump', type=str, help='path to a gzipped JSON dump')
    parser.add_argument(
        '--number-of-records', type=int, dest="number_of_records", default=10,
        help='the number of records to upload. Use -1 for all the dump')
    parser.add_argument(
        '--filter-regex', type=str, dest="filter_regex", default="",
        help='a regular expression used to filter')
    parser.add_argument(
        '--elastic-endpoint', type=str, dest="elastic_endpoint",
        default="http://127.0.0.1:9200",
        help='the elastic index to populate with the JSON dump')
    parser.add_argument(
        '--elastic-index', type=str, dest="elastic_index", default="wikidata/json",
        help='the elastic index to populate with the JSON dump')
    args = parser.parse_args()

    with gzip.open(args.dump, 'r') as dump_fd:
        # ignore the first two lines
        next(dump_fd) # [
        next(dump_fd) # new line

        filter_regex = (
            re.compile(args.filter_regex) if args.filter_regex else None)

        try:
            endpoint = "{0}/{1}".format(args.elastic_endpoint,
                                        args.elastic_index)
            if args.number_of_records == -1:
                for record in dump_fd:
                    if filter_regex is None or filter_regex.search(record):
                        process_record(record, endpoint)
            else:
                for i in range(0, args.number_of_records):
                    record = next(dump_fd)
                    if filter_regex is None or filter_regex.search(record):
                        process_record(record, endpoint)
        except StopIteration:
            pass

