#!/bin/bash

Project=$1

mkdir -p $Project/deseq2_input

# 导出特征表到biom格式
qiime tools export \
  --input-path $Project/dada2_output/table.qza \
  --output-path $Project/deseq2_input

# 转换BIOM为TSV
biom convert \
  -i $Project/deseq2_input/feature-table.biom \
  -o $Project/deseq2_input/feature-table.tsv \
  --to-tsv

# 复制元数据文件
cp $Project/metadata.tsv $Project/deseq2_input/metadata.tsv

echo "Feature table and have been prepared!"

