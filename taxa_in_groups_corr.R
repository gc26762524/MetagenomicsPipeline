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

data2<-data

meta2<-meta[,c("Group-SampleType", "E-CFU")]
#print(meta3)
meta3<-na.omit(meta2)
dim(meta3)
#print(meta4)


meta4<-as.data.frame(t(meta3))
data3<-data2[,colnames(data2)%in%colnames(meta4)]
dim(data3)
#data4<-data3
#data5<-data4[as.logical(rowSums(data4 != 0)), ]
#dim(data5)
namess <- c( colnames(meta3) , rownames(data3) )

#meta4 %>% mutate_if(is.factor, as.character) -> meta4
#data5 %>% mutate_if(is.factor, as.character) -> data5


dim(data3)
dim(meta3)
head(data3)
head(meta3)
#print(data3)
data_final<-rbind.fill(as.data.frame(t(meta3)), data3)

rownames(data_final) <- namess

dim(data_final)
head(data_final)

#list <- c('Group-SampleType' ,'Day-From-Conversion', 'ramosum', 'citroniae', 'longicatena', 'Granulicarella','copri', 'Megamonas', 'Blautia', 'Faecalibacterium', 'prausnitzii', 'Megasphaera', 'Coprococcus', 'caccae', 'eggerthii', 'Coprococcus', 'Paraprevotella', 'producta', 'obeum', 'parainfluenzae', 'Haemophilus', 'Veillonella', 'Campylobacter', 'mucilaginosa', 'Granulicatella', 'subflava', 'rectus', 'Neisseria', 'Corynebacterium', 'Actinobacillus', 'Moryella', 'Treponema', 'Pseudomonas')
#list <- c('Group-SampleType' ,'E-CFUlog', 'ramosum', 'citroniae', 'longicatena', 'Granulicatella','copri', 'Megamonas', 'Blautia', 'Faecalibacterium', 'prausnitzii', 'Megasphaera', 'Coprococcus', 'caccae', 'eggerthii', 'Coprococcus', 'Paraprevotella', 'producta', 'obeum', 'parainfluenzae', 'Haemophilus', 'Veillonella', 'Campylobacter', 'mucilaginosa', 'Granulicatella', 'subflava', 'rectus', 'Neisseria', 'Corynebacterium', 'Actinobacillus', 'Moryella', 'Treponema', 'Pseudomonas')

#data_final2<-data_final[rownames(data_final)%in%list,]

data_final2<-data_final
dim(data_final2)
head(data_final2)

data_final3<-as.data.frame(t(data_final2))
dim(data_final3)
head(data_final3)

data_final3.FT<-data_final3[data_final3$'Group-SampleType' == 'P-T',]
dim(data_final3.FT)
data_final3.FT<-data_final3.FT[,-1]
dim(data_final3.FT)
head(data_final3.FT)


data_final4.FT <- data.frame(sapply(data_final3.FT, function(x) as.numeric(as.character(x))))


#for (variable1 in list[3:length(list)]){
  #print(variable1)
  #i<i+1
  #res<-cor.test(data_final4.FT$N.CFUlog, data_final4.FT[[variable1]],  method = "spearman", exact = FALSE)
  #print(res)
  #print(c(variable1, as.numeric(as.character(res$estimate)), res$p.value))
  #corr_result[nrow(corr_result) + 1,] = c(variable1, as.numeric(as.character(res$estimate)), res$p.value)
#}

summary(namess)
summary(list)
namess[3]<-'Bacteria1.68'
#data_final4.FT[['Bacteria1.68']]

match(namess,'LCP-6')
namess[168]<-'LCP.6'

match(namess,'rc4-4')
namess[252]<-'rc4.4'

match(namess,'WCHB1-05')
namess[329]<-'rc4.4'

for (variable1 in namess[3:length(namess)]){
  #print(variable1)
  #i<i+1
  res<-cor.test(data_final4.FT$E.CFU, data_final4.FT[[variable1]],  method = "spearman", exact = FALSE)
  #print(res)
  print(c(variable1, as.numeric(as.character(res$estimate)), res$p.value))
  #corr_result[nrow(corr_result) + 1,] = c(variable1, as.numeric(as.character(res$estimate)), res$p.value)
}


#####
library("ggpubr")
ggscatter(data_final4.FT, x = "E.CFUlog", y = "Prevotella", 
          add = "reg.line", conf.int = TRUE, 
          cor.coef = TRUE, cor.method = "spearman",
          xlab = "E.CFUlog", ylab = "Prevotella")



#####
plot(data_final3.FT[,c("Prevotella", "E-CFU")]
ggplot(data_final4.FT, aes(x=`Day-From-Conversion`, y = Prevotella )) + geom_point(shape = 3)
ggplot(data_final4.FT, aes(x=Day.From.Conversion, y = Prevotella )) + geom_point(shape = 3)
