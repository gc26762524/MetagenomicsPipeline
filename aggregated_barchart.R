#R script for lefse input file
library(optparse)
library(stringr)
library(reshape)
library(RColorBrewer)
library(ggplot2)


option_list <- list( 
    make_option(c("-i", "--input"),metavar="path", dest="input",help="Specify the path of the table data file",default=NULL),
    make_option(c("-m", "--map"),metavar="path",dest="map", help="Specify the path of mapping file",default=NULL),
    make_option(c("-g", "--category"),metavar="string",dest="group", help="Specify category name in mapping file",default="none")
    )

opt <- parse_args(OptionParser(option_list=option_list,description = "R script for generating group specific lefse input"))

filename_data<-opt$input
filename_meta<-opt$map
Grouplist<-opt$group

filename_data<-"otu_table.Species.relative.txt"
filename_meta<-"ZZG.merged.mapping.final.txt"
output_temp<-gsub(pattern = "\\.txt$", "", filename_data)
data <- read.table(filename_data, row.name = 1, header = TRUE, check.names=FALSE, sep="\t")
meta <- read.table(filename_meta, row.name = 1, header = TRUE , fill=TRUE, na.strings="", check.names=FALSE, sep="\t")

top<-10
Grouplist<-"Group1"
groups<-str_split(Grouplist,",")[[1]]
data<-as.matrix(data[,-c(ncol(data))])
data<-data[order(rowSums(-data)),]
data<-data[c(1:top),]
colSums(data)
others= 1 - colSums(data)
data<- rbind(data,others)
colSums(data)
dim(data)
Subject <- colnames(data)
data2<-rbind(Subject,data)
rownames(data2)[1]<-'Subject'

for (group in groups){
  output_file=paste(output_temp,".",group,".lefse.txt",sep="")
  print(group)
  meta2<-meta[group]
  #print(meta3)
  meta3<-na.omit(meta2)
  #print(meta4)
  meta4<-as.data.frame(t(meta3))
  data3<-data2[,colnames(data2)%in%colnames(meta4)]
  dim(data3)
  data4<-data3
  data5<-data4[as.logical(rowSums(data4 != 0)), ]
  dim(data5)
  dim(meta4)
  #print(data3)
  data_final<-rbind(meta4, data5)
  dim(data_final)
  head(data_final)
  #print(data_final)
  write.table(data_final,file = output_file, row.names = T, col.names = F, quote = F, sep = "\t")
}

new<-as.data.frame(t(data_final))
head(new)
new2<-new
new2[, c(3:ncol(new2))] <- sapply(new2[, c(3:ncol(new2))], as.character)
new2[, c(3:ncol(new2))] <- sapply(new2[, c(3:ncol(new2))], as.numeric)

head(new2)
rowSums(new2[, 3:ncol(new2)])

new3<-aggregate(new2[, 3:ncol(new2)], list(new2$Group1), mean)
new3[, 2:ncol(new3)] <- new3[, 2:ncol(new3)] *100
rowSums(new3[, 2:ncol(new3)])

new4<-melt(new3,id.vars = "Group.1")

pallet<-c(brewer.pal(12,"Paired"),brewer.pal(8,"Set2")[-c(7,8)],brewer.pal(8,"Dark2"),brewer.pal(12,"Set3"),brewer.pal(8,"Accent"),brewer.pal(11,"Spectral"))

p<-ggplot(new4,aes(x=Group.1,y=value,fill=variable))+geom_bar(stat = "identity",width = 0.7)+
  guides(fill=guide_legend(title = NULL))+
  scale_fill_manual(values = pallet)+
  scale_x_discrete(limits=label_order)+
  xlab("")+ylab("Sequence Number Percent (%)")+theme_bw()+
  theme(text = element_text(size = 10),
        panel.grid.major = element_blank(),panel.grid.minor = element_blank(),
        axis.line = element_line(),panel.border =  element_blank(),
        axis.text.x = element_text(angle = 45,size = 10,hjust = 1))+
  scale_y_continuous(limits=c(0,101), expand = c(0, 0))

ggsave(plot = p,filename = paste(output_temp,"_",group,"_aggregated_barchart.png",sep = ""),width = 5,height = 7,dpi = 300)
ggsave(plot = p,filename = paste(output_temp,"_",group,"_aggregated_barchart.pdf",sep = ""),width = 5,height = 7,dpi = 300)
write.table(new4,file = paste(output_temp,"_",group,"_aggregated_barchart.txt",sep = ""), row.names = T, col.names = F, quote = F, sep = "\t")