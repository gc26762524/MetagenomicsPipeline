# library
library(ggplot2)
library(optparse)
library(stringr)
library(reshape)
library(RColorBrewer)
library(dplyr)
library(gtools)
library(plyr)
library(tidyr)
library("tibble")
library(vegan)

setwd("/Users/chengguo/Desktop/COVID16S/")
ko<-read.table("/Users/chengguo/Desktop/COVID16S/exported.NoS/picrust2_out_pipeline/KO_metagenome_out/pred_metagenome_unstrat.tsv", header=T, row.names=1, sep="\t",check.names = FALSE)
path<-read.table("/Users/chengguo/Desktop/COVID16S/exported.NoS/picrust2_out_pipeline/pathways_out/path_abun_unstrat.tsv", header=T, row.names=1, sep="\t",check.names = FALSE)

ko_bc<-read.table("/Users/chengguo/Desktop/COVID16S/exported.NoS/picrust2_out_pipeline/KO_metagenome_out/core-metrics-results/bray_curtis_distance_matrix/data/distance-matrix.tsv", header=T, row.names=1, sep="\t",check.names = FALSE)
path_bc<-read.table("/Users/chengguo/Desktop/COVID16S/exported.NoS/picrust2_out_pipeline/pathways_out/core-metrics-results/bray_curtis_distance_matrix/data/distance-matrix.tsv", header=T, row.names=1, sep="\t",check.names = FALSE)

taxa_bc<-read.table("/Users/chengguo/Desktop/COVID16S/core-metrics-results.NoS/bray_curtis_distance_matrix/data/distance-matrix.tsv", header=T, row.names=1, sep="\t",check.names = FALSE)
taxa_unweight<-read.table("/Users/chengguo/Desktop/COVID16S/core-metrics-results.NoS/unweighted_unifrac_distance_matrix/data/distance-matrix.tsv", header=T, row.names=1, sep="\t",check.names = FALSE)
taxa_weight<-read.table("/Users/chengguo/Desktop/COVID16S/core-metrics-results.NoS/weighted_unifrac_distance_matrix/data/distance-matrix.tsv", header=T, row.names=1, sep="\t",check.names = FALSE)



meta<-read.table("/Users/chengguo/Desktop/COVID16S/mapping_all_20201013.txt", header=T, row.names=1, sep="\t",check.names = FALSE)
dim(meta)

#pcoa = cmdscale(path_bc, k=4, eig=T)
#pcoa = cmdscale(ko_bc, k=4, eig=T)
pcoa = cmdscale(taxa_unweight, k=4, eig=T)

points = as.data.frame(pcoa$points)
eig = pcoa$eig
colnames(points)
dim(points)
length(meta$`Group-SampleType`) 


points = cbind(points, meta$`Group-SampleType-Detection`)
colnames(points)
colnames(points) = c("PC1", "PC2", "PC3", "PC4","group") 
p = ggplot(points, aes(x=PC1, y=PC2, color=group)) + geom_point(alpha=.7, size=2) +
  labs(x=paste("PCoA 1 (", format(100 * eig[1] / sum(eig), digits=4), "%)", sep=""),
       y=paste("PCoA 2 (", format(100 * eig[2] / sum(eig), digits=4), "%)", sep=""),
       title=paste(m," PCoA",sep="")) + theme_classic()
p = p + stat_ellipse(level=0.68)
p

