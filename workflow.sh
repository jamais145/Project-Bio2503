#!/bin/bash

# 设置工作目录
WORK_DIR=~/project
cd $WORK_DIR

# 建立环境
echo "Setting up the environment..."
 
# 安装Miniconda
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
bash Miniconda3-latest-Linux-x86_64.sh -b -p $WORK_DIR/miniconda
export PATH="$WORK_DIR/miniconda/bin:$PATH"
conda init
source ~/.bashrc

# 安装qiime2并激活环境
wget https://data.qiime2.org/distro/amplicon/qiime2-amplicon-2024.5-py38-linux-conda.yml
conda env create -n project2503 --file qiime2-amplicon-2024.5-py38-linux-conda.yml
conda activate project2503

# 安装R
sudo apt update -qq
sudo apt install --no-install-recommends software-properties-common dirmngr
wget -qO- https://cloud.r-project.org/bin/linux/ubuntu/marutter_pubkey.asc | sudo tee -a /etc/apt/trusted.gpg.d/cran_ubuntu_key.asc
sudo add-apt-repository "deb https://cloud.r-project.org/bin/linux/ubuntu $(lsb_release -cs)-cran40/"
sudo apt install --no-install-recommends r-base

# 安装DESeq2
Rscript -e "if (!requireNamespace('BiocManager', quietly = TRUE)) install.packages('BiocManager'); BiocManager::install('DESeq2')"

# 安装必要的分析工具
conda install sra-tools -y
conda install -c bioconda fastqc -y
pip install multiqc
conda install -c bioconda trimmomatic -y

# 下载数据
echo "Downloading data..."
bash download_data.sh $WORK_DIR SRR29282889 SRR29282890 SRR29282891 SRR29282892 SRR29282893 SRR29282894 SRR29282895 SRR29282896 SRR29282897 SRR29282898 SRR29282899 SRR29282900 SRR29282901 SRR29282902

# 质量控制
echo "Performing quality control..."
bash quality_control.sh $WORK_DIR

# 剪切低质量数据
echo "Trimming low-quality data..."
bash trim_data.sh $WORK_DIR

# 去噪、生成特征表
echo "Generating feature table..."
# 创建 manifest 文件
cat <<EOF > $WORK_DIR/manifest.tsv
sample-id       absolute-filepath
SRR29282889_trimmed     $WORK_DIR/trimmed_reads/SRR29282889_trimmed.fastq
SRR29282890_trimmed     $WORK_DIR/trimmed_reads/SRR29282890_trimmed.fastq
SRR29282891_trimmed     $WORK_DIR/trimmed_reads/SRR29282891_trimmed.fastq
SRR29282892_trimmed     $WORK_DIR/trimmed_reads/SRR29282892_trimmed.fastq
SRR29282893_trimmed     $WORK_DIR/trimmed_reads/SRR29282893_trimmed.fastq
SRR29282894_trimmed     $WORK_DIR/trimmed_reads/SRR29282894_trimmed.fastq
SRR29282895_trimmed     $WORK_DIR/trimmed_reads/SRR29282895_trimmed.fastq
SRR29282896_trimmed     $WORK_DIR/trimmed_reads/SRR29282896_trimmed.fastq
SRR29282897_trimmed     $WORK_DIR/trimmed_reads/SRR29282897_trimmed.fastq
SRR29282898_trimmed     $WORK_DIR/trimmed_reads/SRR29282898_trimmed.fastq
SRR29282899_trimmed     $WORK_DIR/trimmed_reads/SRR29282899_trimmed.fastq
SRR29282900_trimmed     $WORK_DIR/trimmed_reads/SRR29282900_trimmed.fastq
SRR29282901_trimmed     $WORK_DIR/trimmed_reads/SRR29282901_trimmed.fastq
SRR29282902_trimmed     $WORK_DIR/trimmed_reads/SRR29282902_trimmed.fastq
EOF

bash dada2_processing.sh $WORK_DIR

# 分类物种注释
echo "Classifying taxonomy..."
bash taxonomy_classification.sh $WORK_DIR

# Alpha 多样性分析
echo "Performing alpha diversity analysis..."
bash alpha_diversity.sh $WORK_DIR

# 差异表达分析
echo "Preparing DESeq2 input..."
# 创建元数据文件
cat <<EOF > $WORK_DIR/metadata.tsv
treatment
SCZ
SCZ
SCZ
HC
HC
HC
HC
HC
SCZ
SCZ
SCZ
SCZ
HC
HC
EOF

bash prepare_deseq2_input.sh $WORK_DIR
Rscript deseq2.R

echo "All steps completed successfully!"

