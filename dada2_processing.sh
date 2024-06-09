#!/bin/bash

Project=$1

mkdir -p $Project/dada2_output

# 导入序列数据
qiime tools import \
  --type 'SampleData[SequencesWithQuality]' \
  --input-path $Project/manifest.tsv \
  --output-path $Project/dada2_output/demux.qza \
  --input-format SingleEndFastqManifestPhred33V2

if [ $? -ne 0 ]; then
  echo "Error: Failed to import sequences."
  exit 1
fi

# DADA2去噪
qiime dada2 denoise-single \
  --i-demultiplexed-seqs $Project/dada2_output/demux.qza \
  --p-trim-left 0 \
  --p-trunc-len 240 \
  --o-representative-sequences $Project/dada2_output/rep-seqs.qza \
  --o-table $Project/dada2_output/table.qza \
  --o-denoising-stats $Project/dada2_output/denoising-stats.qza

if [ $? -ne 0 ]; then
  echo "Error: DADA2 denoise-single failed."
  exit 1
fi

# 特征表汇总
qiime feature-table summarize \
  --i-table $Project/dada2_output/table.qza \
  --o-visualization $Project/dada2_output/table.qzv

if [ $? -ne 0 ]; then
  echo "Error: Feature table summarization failed."
  exit 1
fi

# 序列表格
qiime feature-table tabulate-seqs \
  --i-data $Project/dada2_output/rep-seqs.qza \
  --o-visualization $Project/dada2_output/rep-seqs.qzv

if [ $? -ne 0 ]; then
  echo "Error: Feature table tabulation failed."
  exit 1
fi

# 去噪统计数据表格
qiime metadata tabulate \
  --m-input-file $Project/dada2_output/denoising-stats.qza \
  --o-visualization $Project/dada2_output/denoising-stats.qzv

if [ $? -ne 0 ]; then
  echo "Error: Denoising stats tabulation failed."
  exit 1
fi

echo "dada2 processing completed successfully!"

