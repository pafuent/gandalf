#!/usr/bin/env python

import argparse
import gzip
import json
import re
import sys


def process_record(record):
    # Ignore the last character of the file, wich are a comma 
    record = record[0:-2]
    print record
    sys.stdout.flush()

def show_label(record, language):
    # Ignore the last character of the file, wich are a comma 
    record = record[0:-2]
    try:
        record = json.loads(record)
        is_valid_language = language in record['labels']
        if is_valid_language:
            print u"{id} -> {lang_label}".format(
                id=record['id'],
                lang_label=record['labels'][language]['value'])
        else:
            print u"{id} -> No label for language {language}".format(
                id=record['id'],
                language=language)
        sys.stdout.flush()
    except Exception as ex:
        print "ERROR: {0}".format(ex)
        print record


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description='Filters a Wikidata JSON dump to Elastic')
    parser.add_argument(
        'dump', type=str, help='path to a gzipped JSON dump')
    parser.add_argument(
        '--number-of-records', type=int, dest="number_of_records", default=-1,
        help='the number of records to upload. Use -1 for all the dump')
    parser.add_argument(
        '--filter-regex', type=str, dest="filter_regex", default="",
        help='a regular expression used to filter')
    parser.add_argument(
        '--show-only-labels', type=str, dest="show_only_labels", default="",
        help='if it is present shows only the labels of the records'
             ' in the language of its value')
    args = parser.parse_args()

    with gzip.open(args.dump, 'r') as dump_fd:
        # ignore the first two lines
        next(dump_fd) # [
        next(dump_fd) # new line

        filter_regex = (
            re.compile(args.filter_regex) if args.filter_regex else None)

        try:
            if args.number_of_records == -1:
                for record in dump_fd:
                    if filter_regex is None or filter_regex.search(record):
                        if args.show_only_labels:
                            show_label(record, args.show_only_labels)
                        else:
                            process_record(record, filter_regex)
            else:
                for i in range(0, args.number_of_records):
                    record = next(dump_fd)
                    if filter_regex is None or filter_regex.search(record):
                        if args.show_only_labels:
                            show_label(record, args.show_only_labels)
                        else:
                            process_record(record, filter_regex)
        except StopIteration:
            pass

