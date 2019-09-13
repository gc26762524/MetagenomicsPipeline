library(reshape2)
library(ggplot2)
library(RColorBrewer)


setwd("~/Desktop")

input <-"orthology	sample1	sample2	sample3	sample4	sample5	sample6	sample7	sample8
Cellular Processes	941.62143824647	741.104070039142	707.265238934281	769.731154328598	817.523340250178	1265.22023523319	952.662628505868	1017.37588668238
Genetic Information Processing	2979.13559309301	3575.90782288264	3606.9920900521	3507.66348633496	3488.85679594546	3641.61393384733	3468.98315576402	3480.55060865853
Human Diseases	955.989786994423	1031.35669052169	1072.92020625022	973.297867652355	985.237090473578	1038.30778620247	970.676394488087	989.194413423238
Metabolism	12035.4746837111	11332.9271650433	11730.3261400922	11567.5437718207	10851.397133479	10349.495502954	10863.1893718713	10518.8941055545
Organismal Systems	476.416797364435	438.547104464593	449.430012260196	459.980496919068	497.539308152761	575.866370617029	484.4957997039	564.388993024318
"

data<-read.table(text=input, header=T, row.name = 1, sep="\t")
class(data)
data2<-t(data[,order(colnames(data))])
head(data2)
class(data2)
data3<-prop.table(data2, margin=1)

rowSums(data3)
head(data3)

data4<-data3*100

data5<-melt(data4, id.var="SampleID")
colnames(data5)<-c('SampleID', 'Function', 'Proportion')
pallet<-c(brewer.pal(12,"Paired"),brewer.pal(8,"Set2")[-c(7,8)],brewer.pal(8,"Dark2"),brewer.pal(12,"Set3"),brewer.pal(8,"Accent"),brewer.pal(11,"Spectral"))


p<-ggplot(data5, aes(x = SampleID, y = Proportion, fill = Function)) + 
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


ggsave(plot = p,filename = "all.merged.abundance.KeepID.Pathway.Level1.png" ,width = 10,height = 8,dpi = 300)
ggsave(plot = p,filename = "all.merged.abundance.KeepID.Pathway.Level1.pdf" ,width = 10,height = 8,dpi = 300)


