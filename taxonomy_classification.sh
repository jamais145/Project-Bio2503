#!/bin/bash

Project=$1

mkdir -p $Project/taxonomy


# 下载SILVA数据库（如未下载）
if [ ! -f "silva-138-99-nb-classifier.qza" ]; then
  wget -O silva-138-99-nb-classifier.qza \
  https://data.qiime2.org/2024.5/common/silva-138-99-nb-classifier.qza
fi

# 分类物种注释
qiime feature-classifier classify-sklearn \
  --i-classifier silva-138-99-nb-classifier.qza \
  --i-reads $Project/dada2_output/rep-seqs.qza \
  --o-classification $Project/taxonomy/taxonomy.qza

if [ $? -ne 0 ]; then
  echo "Error: Taxonomy classification failed."
  exit 1
fi

# 分类物种可视化
qiime metadata tabulate \
  --m-input-file $Project/taxonomy/taxonomy.qza \
  --o-visualization $Project/taxonomy/taxonomy.qzv

if [ $? -ne 0 ]; then
  echo "Error: Taxonomy visualization failed."
  exit 1
fi

echo "Taxonomy classification completed successfully!"
