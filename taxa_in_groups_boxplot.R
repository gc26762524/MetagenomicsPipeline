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

setwd("/Users/chengguo/Desktop/COVID16S/")
data<-read.table("/Users/chengguo/Desktop/COVID16S/exported/Relative/otu_table.GenusSpecies.relative.FORlefse.txt", header=T, row.names=1, sep="\t",check.names = FALSE)
meta<-read.table("/Users/chengguo/Desktop/COVID16S/mapping_all_20201013.txt", header=T, row.names=1, sep="\t",check.names = FALSE)

head(data)
head(meta)

group<-"Group-SampleType-Detection"

data2<-data

meta2<-meta[group]
#print(meta3)
meta3<-na.omit(meta2)
#print(meta4)


meta4<-as.data.frame(t(meta3))
data3<-data2[,colnames(data2)%in%colnames(meta4)]
dim(data3)
data4<-data3
data5<-data4[as.logical(rowSums(data4 != 0)), ]

namess <- c( rownames(meta4) , rownames(data5) )

meta4 %>% mutate_if(is.factor, as.character) -> meta4
data5 %>% mutate_if(is.factor, as.character) -> data5


dim(data5)
dim(meta4)
#print(data3)
data_final<-rbind.fill(meta4, data5)

rownames(data_final) <- namess

dim(data_final)
head(data_final)

#col_name<-colnames(data_final)
#colnames(data_final)<-as.vector(data_final["Group",])
#colnames(data_final)<-NULL
data_final2<-t(data_final)

#data_final<-data_final[-1,]
#data_final %>% mutate_if(as.character, as.numeric) -> data_final
list <- c(group, 'ramosum', 'citroniae', 'longicatena', 'Granulicarella','copri', 'Megamonas', 'Blautia', 'Faecalibacterium', 'prausnitzii', 'Megasphaera', 'Coprococcus', 'caccae', 'eggerthii', 'Coprococcus', 'Paraprevotella', 'producta', 'obeum')
list <- c(group, 'parainfluenzae', 'Haemophilus', 'Veillonella', 'Campylobacter', 'mucilaginosa', 'Granulicatella', 'subflava', 'rectus', 'Neisseria', 'Corynebacterium', 'Actinobacillus', 'Moryella', 'Treponema', 'Pseudomonas')
#data_test<-data_final2[,list]
data_test<-data_final2[,colnames(data_final2)%in%list]
colnames(data_test)[1] <- 'Group'

#data_test[,c(2,3)] %>% mutate_if(as.character, as.numeric) -> data_test[,c(2,3)]

my_data <- as_tibble(data_test)

my_data2 <- my_data %>%
  pivot_longer(!Group, names_to = "taxa", values_to = "relabun")

#as.data.frame(my_data2)
my_data2[,]
my_data2$relabun<-as.numeric(as.character(my_data2$relabun))


#ggplot(as.data.frame(my_data2), aes(x=Group, y=relabun, fill=taxa)) + geom_boxplot()

ggplot(my_data2, aes(x=taxa, y=relabun, fill=Group)) + geom_boxplot(outlier.shape = NA) + 
  theme(text = element_text(size = 10),
        panel.grid.major = element_blank(),panel.grid.minor = element_blank(),
        axis.line = element_line(),panel.border =  element_blank(),
        axis.text.x = element_text(angle = 45,size = 10,hjust = 1))+
  scale_y_continuous(limits=c(-0.001,0.09), expand = c(0, 0))


###################################


