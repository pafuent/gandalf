#!/bin/bash

ls -1 | sed -e "s/-.*$//" | sort | uniq > requirements.txt
