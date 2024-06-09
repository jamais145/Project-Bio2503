#!/bin/bash

Project=$1

mkdir -p $Project/alpha_diversity

# 计算Alpha多样性
echo "Calculating Alpha diversity..."
qiime diversity alpha \
  --i-table $Project/dada2_output/table.qza \
  --p-metric shannon \
  --o-alpha-diversity $Project/alpha_diversity/shannon.qza

# 可视化Alpha多样性
echo "Visualizing Alpha diversity..."
qiime diversity alpha-group-significance \
  --i-alpha-diversity $Project/alpha_diversity/shannon.qza \
  --m-metadata-file $Project/metadata.tsv \
  --o-visualization $Project/alpha_diversity/shannon_group_significance.qzv

echo "Alpha diversity analysis completed!"
