#!/bin/bash

Project=$1

mkdir -p $Project/data
cd $Project/data

for SRR in "$@"; do
    if [ "$SRR" != "$1" ]; then
        prefetch $SRR
        fasterq-dump $SRR
    fi
done
