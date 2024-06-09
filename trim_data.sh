#!/bin/bash

Project=$1
mkdir -p $Project/trimmed_reads

for FILE in $Project/data/*.fastq; do
     /usr/bin/TrimmomaticSE -phred33 \
        $FILE \
        $Project/trimmed_reads/$(basename $FILE .fastq)_trimmed.fastq \
        ILLUMINACLIP:TruSeq3-SE.fa:2:30:10 \
        LEADING:5 TRAILING:20 SLIDINGWINDOW:4:20 MINLEN:36 \
        HEADCROP:15
done
# 去除序列开头质量值小于5,末尾质量值小于20的碱基;在4个碱基的滑动窗口中，如果平均质量值小于20，则截断序列;保留长度至少为36的序列;去除序列开头的前15个碱基。
