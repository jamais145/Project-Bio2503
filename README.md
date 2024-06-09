# README



[TOC]

## 1、Project_bio2503

​		本项目以14个精神分裂症（SCZ）和健康对照（HC）的肠道微生物组16S rRNA单向测序数据作为分析对象，进行了一系列的生物信息学分析流程。其中上游分析包括包括数据下载、质量控制、剪切低质量数据、数据去噪等；下游分析包括特征表和分类表生成、物种分类注释、alpha多样性分析、差异表达分析等。本项目的具体分析流程以及环境的搭建可详细见于`项目报告.pdf`文件。

​		项目的各个分析步骤以模块化方式编写在各个bash脚本中。若要对这14个数据集进行分析，只需要将项目的各个脚本下载至本地同一目录下，在Linux环境下运行`workflow.sh`：

```bash
bash workflow.sh
```

​		workflow流程将包括计算环境的搭建、各个分析脚本的调用、meta等准备文件的编写，最后生成分析结果的可视化文件，存放于对应的目录中。

​		Github上亦包括存放数据集的目录`data` ，存放各分析结果的目录`fastqc_results` `dada2_output` `deseq2_output` `taxonomy`等等，可以直接查看分析结果。





## 2、 将脚本应用于他处

​		本项目的编写虽然是为了分析精神分裂症（SCZ）和健康对照（HC）的肠道微生物组16S rRNA数据，但由于模块化的架构，你也可以将整套分析流程应用于其他的组学数据分析（16S rRNA数据最佳），只需要对`workflow.sh`进行一些修改，下面是具体的修改适应操作：

  + 数据集下载

    将`workflow.sh`中下载数据集的步骤更换为你感兴趣的其他数据:

    ```bash
    bash download_data.sh $WORK_DIR SRRxxxxxxxx SRRxxxxxxxx SRRxxxxxxxx
    ```

    + 注意，为保证统计分析的可靠性和准确性，数据集最好包括至少六条SRR数据，每个组别至少3个条SRR样本.

      

  + manifest文件的编写

    manifest文件用于描述和管理数据文件的位置、属性以及处理方式，本项目中`manifest.tsv`的格式为：

    ```bash
    sample-id	absolute-filepath
    SRRxxxxxxxx_trimmed	~/project/trimmed_reads/SRRxxxxxxxx_trimmed.fastq
    SRRxxxxxxxx_trimmed	~/project/trimmed_reads/SRRxxxxxxxx_trimmed.fastq
    ......
    ```

    添加你的样本ID和存放位置，用于之后的分析。



  + metadata文件的编写

    metadata文件描述样本相关信息。这些信息可以包括但不限于样本的来源、处理方式、实验条件、环境参数等。本项目中为区分样本的来源，`metadata.tsv`的格式为：

    ```bash
    treatment
    SCZ
    SCZ
    HC
    HC
    ......
    ```

    你也可以添加其他的条件参数，进行更复杂的分析。
    
    + 注意，metadata文件内行的样本排列应该与特征表中列的排列顺序一致，才可用于接下来的`DESeq2`分析。

