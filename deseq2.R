library(DESeq2)
library(ggplot2)
library(dplyr)

project_path <- "~/project"

# 读取特征表
counts <- read.table(file.path(project_path, "deseq2_input", "feature-table.tsv"),
                     header = TRUE, row.names = 1, sep = "\t")

# 转换特征表数据为整型,DESeq2分析只能读取整型
counts <- as.matrix(counts)
counts <- apply(counts, 2, function(x) as.integer(as.numeric(x)))
counts <- counts + 1
# 将特征表列名转换为字符型
colnames(counts) <- as.character(colnames(counts))

# 读取元数据
meta <- read.table(file.path(project_path, "metadata.tsv"),
                  header = TRUE)



# 运行DESeq2分析
dds <- DESeqDataSetFromMatrix(countData = counts, colData = meta, design = ~ treatment)

dds <- DESeq(dds)
res <- results(dds)

dir.create(file.path(project_path, "deseq2_output"), showWarnings = FALSE)

# 保存分析文件
write.csv(as.data.frame(res), file=file.path(project_path, "deseq2_output", "deseq2_results.csv"))

project_path <- "~/project"
result_file <- file.path(project_path, "deseq2_output", "deseq2_results.csv")

deseq2_results <- read.csv(result_file)

cat("DESeq2 results head:\n")
print(head(deseq2_results))

# 计算 -log10 p-value，并添加显著性标签
deseq2_results <- deseq2_results %>%
  mutate(log10_padj = -log10(padj),
         significance = case_when(
           padj < 0.05 & log2FoldChange > 1 ~ "Upregulated",
           padj < 0.05 & log2FoldChange < -1 ~ "Downregulated",
           TRUE ~ "Not significant"
         ))

# 绘制火山图
volcano_plot <- ggplot(deseq2_results, aes(x = log2FoldChange, y = log10_padj, color = significance)) +
  geom_point(alpha = 0.8, size = 1.5) +
  scale_color_manual(values = c("Upregulated" = "red", "Downregulated" = "blue", "Not significant" = "gray")) +
  geom_vline(xintercept = c(-1, 1), linetype = "dashed", color = "black") +
  geom_hline(yintercept = -log10(0.05), linetype = "dashed", color = "black") +
  theme_minimal() +
  labs(title = "Volcano Plot of HC vs SCZ",
       x = "Log2 Fold Change",
       y = "-Log10 Adjusted P-value",
       color = "Significance")

# 保存火山图为文件
ggsave(file.path(project_path, "deseq2_output", "volcano_plot.png"), plot = volcano_plot, width = 8, height = 6)

print("DESeq2 analysis completed！")
