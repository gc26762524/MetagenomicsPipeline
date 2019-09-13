#R script for lefse input file
library(optparse)
library(stringr)
library(reshape2)
library(ggplot2)
library(RColorBrewer)
library(pheatmap)
library(psych)

option_list <- list( 
  make_option(c("-i", "--input"),metavar="path", dest="input",help="Specify the path of the table data file",default=NULL),
  make_option(c("-m", "--map"),metavar="path",dest="map", help="Specify the path of mapping file",default=NULL),
  make_option(c("-g", "--category"),metavar="string",dest="group", help="Specify category name in mapping file",default="none")
)

opt <- parse_args(OptionParser(option_list=option_list,description = "R script for generating group specific lefse input"))

filename_data<-opt$input
filename_meta<-opt$map
Grouplist<-opt$group

#filename_data<-"/Users/chengguo/Google\ Drive/MacPro/WST/VIP/Zhiguo_Zhang/ZZG2/AMR/final.contigs.fa.fna.out.txt.coverage.txt"
#filename_meta<-"/Users/chengguo/Google\ Drive/MacPro/WST/VIP/Zhiguo_Zhang/ZZG2/ZZG.merged.mapping.final.txt"
top<-10

#setwd("~/Desktop")
#filename_data<-"final.contigs.fa.fna.out.txt.coverage.txt"
#filename_meta<-"ZZG.merged.mapping.txt"
#Grouplist<-'Group1,Group2'

output_temp<-gsub(pattern = "\\.txt$", "", filename_data)
data <- read.table(filename_data, row.name = 1, header = TRUE, check.names=FALSE, sep="\t", quote="")
meta <- read.table(filename_meta, row.name = 1, header = TRUE , fill=TRUE, na.strings="", check.names=FALSE, sep="\t")

data2<-data[,c(1:(ncol(data)-1))]
row.names(data2)<-data[,ncol(data)]

###For genenating the stacked bar chart.
data3<-prop.table(as.matrix(data2), margin = 2)
#colSums(data3)
data4<-data3[order(rowSums(-data3)),]
colSums(data4)
rowSums(data4)
data5<-data4[c(1:top),]
dim(data5)
colSums(data5)
others<-1- colSums(data5)
data6<- rbind(data5,others)
#colSums(data6)
data7<-t(data6*100)
AMRID<-colnames(data7)
AMRID_new <- stringr::str_trunc(AMRID,side="center", 13)
colnames(data7)<-AMRID_new
data8 <- melt(data7,id ="sampleID")
colnames(data8)<-c('SampleID', 'AMR', 'Proportion')

pallet<-c(brewer.pal(12,"Paired"),brewer.pal(8,"Set2")[-c(7,8)],brewer.pal(8,"Dark2"),brewer.pal(12,"Set3"),brewer.pal(8,"Accent"),brewer.pal(11,"Spectral"))

p_barchart<-ggplot(data8, aes(x = SampleID, y = Proportion, fill=AMR)) + geom_bar(stat='identity')  + theme(panel.background = element_rect(fill = "white", colour = "grey50")) + scale_fill_brewer(palette="Set1")
p_barchart<-ggplot(data8, aes(x = SampleID, y = Proportion, fill = AMR)) + 
  geom_bar(stat = "identity",width = 0.7)+
  guides(fill=guide_legend(title = NULL))+
  scale_fill_manual(values = pallet)+
  xlab("")+ylab("Sequence Number Percent (%)")+theme_bw()+
  theme(text = element_text(size = 10),
        panel.grid.major = element_blank(),panel.grid.minor = element_blank(),
        axis.line = element_line(),panel.border =  element_blank(),
        axis.text.x = element_text(angle = 45,size = 10,hjust = 1))+
  scale_y_continuous(limits=c(0,101), expand = c(0, 0)
  )

ggsave(plot = p_barchart,filename = paste(output_temp,"_barplot.png",sep = ""),width = 10,height = 8,dpi = 300)
ggsave(plot = p_barchart,filename = paste(output_temp,"_barplot.pdf",sep = ""),width = 10,height = 8,dpi = 300)

###Loop for groups
groups<-str_split(Grouplist,",")[[1]]

####For different groups with NA values in the mapping file
for (group in groups){
  
  print(group)
  data_lefse<-data3
  Subject <- colnames(data_lefse)
  data_lefse2<-rbind(Subject,data_lefse)
  rownames(data_lefse2)[1]<-'Subject'
  meta2<-meta[group]
  #print(meta3)
  meta3<-na.omit(meta2)
  #print(meta4)
  meta4<-as.data.frame(t(meta3))
  meta4[] <- lapply(meta4, as.character)
  data_lefse3<-data_lefse2[,colnames(data_lefse2)%in%colnames(meta4)]
  #print(data3)
  data_lefse4<-rbind(meta4, data_lefse3)
  class(data3)
  #print(data_final)
  #For generating the lefse input file
  lefseoutput_file=paste(output_temp,"_",group,"_lefse.txt",sep="")
  write.table(data_lefse4,file = lefseoutput_file, row.names = T, col.names = F, quote = F, sep = "\t")
  
}

#####For generating heatmap
for (group in groups){
  
  print(group)
  data_heatmap<-data3*100
  class(data3)
  #Subject <- colnames(data_lefse)
  #data_lefse2<-rbind(Subject,data_lefse)
  #rownames(data_lefse2)[1]<-'Subject'
  meta2<-meta[group]
  #print(meta3)
  meta3<-na.omit(meta2)
  #print(meta4)
  meta4<-as.data.frame(t(meta3))
  meta4[] <- lapply(meta4, as.character)
  data_heatmap2<-data_heatmap[,colnames(data_heatmap)%in%colnames(meta4)]
  #print(data3)
  #data_heatmap3<-rbind(meta4, data_heatmap2)
  #class(data3)
  #print(data_final)
  #For generating the lefse input file
  annotation_col<- meta2
  data_heatmap3<-data_heatmap2
  AMRID_heatmap<-rownames(data_heatmap2)
  AMRID_heatmap_new <- stringr::str_trunc(AMRID_heatmap,side="center", 13)
  rownames(data_heatmap3)<-AMRID_heatmap_new
  p_heatmap<-pheatmap(data_heatmap3,fontsize=12,border_color = "black",
                      main="Heatmap for AMR genes",
                      legend_breaks = c(0, 20, 40, 60, max(data_heatmap3)), 
                      legend_labels = c("0", "20", "40", "60", "Proportion(%)\n"),
                      annotation_col=annotation_col,
                      fontsize_row =17,fontsize_col = 17,
                      fontsize_number = 22,
                      cluster_rows=T,clustering_distance_rows="euclidean",
                      cluster_cols=F,clustering_distance_cols="euclidean",
                      clustering_method="centroid"
  )
  ggsave(plot = p_heatmap,filename = paste(output_temp,"_",group,"_heatmap.png",sep = ""),width = 10,height = 14,dpi = 300)
  ggsave(plot = p_heatmap,filename = paste(output_temp,"_",group,"_heatmap.pdf",sep = ""),width = 10,height = 14,dpi = 300)
  write.table(data_heatmap3,file = paste(output_temp,"_",group,"_heatmap.txt",sep = ""), row.names = T, col.names = F, quote = F, sep = "\t")
}
