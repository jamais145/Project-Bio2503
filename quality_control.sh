#!/bin/bash

Project=$1
mkdir -p $Project/fastqc_results

for FILE in $Project/data/*.fastq; do
    fastqc $FILE -o $Project/fastqc_results
done

for FILE in $Project/fastqc_results/*.zip; do
	unzip $FILE -d $Project/fastqc_results
done

multiqc $Project/fastqc_results -o $Project/fastqc_results
