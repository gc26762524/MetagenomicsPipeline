library(tidyverse)
library(magrittr)
library(dplyr) 
library(ggplot2)
library(ggpubr)
theme_set(theme_pubclean())

top<-20
setwd("~/Desktop")
#filename_data<-"otu_table.Species.relative.txt"
#filename_map<-"RAO_mapping.txt"

meta<-"SampleID	Group1	Group2	Alias	Description
P1B	patient_before	P1	A1	P1B
P2B	patient_before	P2	A2	P2B
P1A	patient_after	P1	A3	P1A
P2A	patient_after	P2	A4	P2A
P3B	patient_before	P3	A5	P3B
P5A	patient_after	P5	A6	P5A
P3A	patient_after	P3	A7	P3A
P4B	patient_before	P4	A8	P4B
P4A	patient_after	P4	A9	P4A
P5B	patient_before	P5	A530	P5B
"

data<-"Taxonomy	P1A	P1B	P2A	P2B	P3A	P3B	P4A	P4B	P5A	P5B	Tax_detail
Escherichia_coli	0.0360895024067128	0.500738878728724	0.0264212956326006	0.390816798813625	0.0466176975867423	0.132779461802854	0.11684804248392	0.0470690825040903	0.00159941549317477	0.0037604627173727	k__Bacteria;p__Proteobacteria;c__Gammaproteobacteria;o__Enterobacterales;f__Enterobacteriaceae;g__Escherichia;s__Escherichia_coli;
Bacteroides_vulgatus	0.207364197992252	7.96322420346802e-05	0.0281520541974901	0.00065826480615388	0.491222265434461	0.248153967222305	0.00702551240328981	0.00401952338053703	0.0460990684463345	0.0722133704409402	k__Bacteria;p__Bacteroidetes;c__Bacteroidia;o__Bacteroidales;f__Bacteroidaceae;g__Bacteroides;s__Bacteroides_vulgatus;
Prevotella_copri	2.18668148536218e-05	5.79367705205878e-05	0.389096729608052	0.000580745249565744	2.58667733973917e-05	1.59732516824235e-05	0.275708505032596	0.361594114257623	0.000471666533559156	3.77322240667062e-05	k__Bacteria;p__Bacteroidetes;c__Bacteroidia;o__Bacteroidales;f__Prevotellaceae;g__Prevotella;s__Prevotella_copri;
Bacteroides_plebeius	0.00120648021070295	2.218855041214e-06	0.00101108848468379	8.11023932371678e-05	0.00281445458812695	0.00104677265404962	0.00317290405684237	0.000205164060739843	0.33251354365519	0.000601983912948296	k__Bacteria;p__Bacteroidetes;c__Bacteroidia;o__Bacteroidales;f__Bacteroidaceae;g__Bacteroides;s__Bacteroides_plebeius;
Bacteroides_dorei	0.00562272485730909	3.74739962516142e-05	0.067105780562805	0.000237444356103997	0.0151296574688732	0.0104273853355173	0.00155035024360449	0.0264902351942286	0.00203609532372469	0.275533550965024	k__Bacteria;p__Bacteroidetes;c__Bacteroidia;o__Bacteroidales;f__Bacteroidaceae;g__Bacteroides;s__Bacteroides_dorei;
Bacteroides_fragilis	0.269934810765152	6.41002567461822e-05	0.00600156868886283	0.000720475878877973	0.0545400917084004	0.0689766398189729	0.186822833530767	0.251492309463225	0.00360681845064656	0.148074644911518	k__Bacteria;p__Bacteroidetes;c__Bacteroidia;o__Bacteroidales;f__Bacteroidaceae;g__Bacteroides;s__Bacteroides_fragilis;
Klebsiella_pneumoniae	0.0122383734997377	0.247561355039981	0.00190232791201064	0.0978287032769601	2.38359110232163e-05	9.46152827758154e-05	0.00367044819727877	0.0498063960945368	4.79840996879072e-05	9.61533729236112e-05	k__Bacteria;p__Proteobacteria;c__Gammaproteobacteria;o__Enterobacterales;f__Enterobacteriaceae;g__Klebsiella;s__Klebsiella_pneumoniae;
Bacteroides_coprocola	0.00528802059774444	5.67040732754689e-06	0.00640487180181015	4.20169025204604e-05	0.0128638563842537	0.0253670393817022	0.00760809463561253	0.00276892774558607	0.226377946802064	0.00927419788491745	k__Bacteria;p__Bacteroidetes;c__Bacteroidia;o__Bacteroidales;f__Bacteroidaceae;g__Bacteroides;s__Bacteroides_coprocola;
Bacteroides_ovatus	0.0764682515431156	3.87066934967331e-05	0.02960636349557	0.00029965542882809	0.0264399575806294	0.20941352690738	0.00491712313658311	0.0126457276453653	0.0049749783765009	0.0797414959860752	k__Bacteria;p__Bacteroidetes;c__Bacteroidia;o__Bacteroidales;f__Bacteroidaceae;g__Bacteroides;s__Bacteroides_ovatus;
Proteus_mirabilis	3.40781530186314e-07	0	3.16654835290548e-06	0.189764943115954	1.6567561473536e-06	3.49779233921683e-07	0.00221519350744301	1.31179066969209e-07	8.17446331991604e-07	2.55193785958399e-05	k__Bacteria;p__Proteobacteria;c__Gammaproteobacteria;o__Enterobacterales;f__Morganellaceae;g__Proteus;s__Proteus_mirabilis;
Bacteroides_stercoris	0.000713880508818631	2.76124182906631e-05	0.0239896743656012	0.000187284643017556	0.0847160344013122	0.160939779850116	0.000345256154172184	0.00241198950436285	0.0155808540662928	0.00107755576120934	k__Bacteria;p__Bacteroidetes;c__Bacteroidia;o__Bacteroidales;f__Bacteroidaceae;g__Bacteroides;s__Bacteroides_stercoris;
Bacteroides_thetaiotaomicron	0.0222873960587934	7.61806897483473e-05	0.00466106321946617	0.000725361565217561	0.00514241075014551	0.00312556893778518	0.00376929653533198	0.00672817434485075	0.00400834808892083	0.138148153481563	k__Bacteria;p__Bacteroidetes;c__Bacteroidia;o__Bacteroidales;f__Bacteroidaceae;g__Bacteroides;s__Bacteroides_thetaiotaomicron;
Prevotella_stercorea	0.000154544423939494	6.656565123642e-06	0.00288405385742203	7.45881447843833e-05	0.000142587916165787	1.60315482214105e-05	0.126867301022311	0.00125767930456729	2.65670057897271e-05	1.57673303467154e-05	k__Bacteria;p__Bacteroidetes;c__Bacteroidia;o__Bacteroidales;f__Prevotellaceae;g__Prevotella;s__Prevotella_stercorea;
Haemophilus_parainfluenzae	0.0236913023693177	1.97231559219022e-06	0.000761794768900503	0.0970235421681959	0.000238626328965607	9.70054408742802e-05	9.68218345395908e-06	0.000210083275751189	0.000155314803078405	0.000741793651398362	k__Bacteria;p__Proteobacteria;c__Gammaproteobacteria;o__Pasteurellales;f__Pasteurellaceae;g__Haemophilus;s__Haemophilus_parainfluenzae;
Bacteroides_uniformis	0.0788047633079163	4.38840219262324e-05	0.0069770574935791	0.00033776378227688	0.0863827310855499	0.000195176812528299	0.0158814828691777	0.0124469257693734	0.0320405446841097	0.084613145360021	k__Bacteria;p__Bacteroidetes;c__Bacteroidia;o__Bacteroidales;f__Bacteroidaceae;g__Bacteroides;s__Bacteroides_uniformis;
Alistipes_putredinis	0.00059239189330721	8.13580181778467e-06	0.0784331957132228	4.62511640147704e-05	0.000636728798050671	0.000241930636795831	0.0126942431763686	0.0180746389214195	0.00651839879593425	0.0258516773614129	k__Bacteria;p__Bacteroidetes;c__Bacteroidia;o__Bacteroidales;f__Rikenellaceae;g__Alistipes;s__Alistipes_putredinis;
Eubacterium_rectale	0.0187650781627877	1.72577614316644e-06	0.000406853485343007	2.18227323168283e-05	0.000181441520008564	4.23232873045237e-05	0.00138357651000218	0.00160248348209586	0.0743172340820515	0.000249087363222966	k__Bacteria;p__Firmicutes;c__Clostridia;o__Clostridiales;f__Lachnospiraceae;s__[Eubacterium]_rectale;
Klebsiella_oxytoca	1.06210243574735e-05	0.0727648856821229	1.13228092619044e-05	0.000166439047968646	1.6567561473536e-06	6.12113659362946e-06	6.01196042373738e-05	3.60742434165326e-06	0	9.11406378422855e-07	k__Bacteria;p__Proteobacteria;c__Gammaproteobacteria;o__Enterobacterales;f__Enterobacteriaceae;g__Klebsiella;s__Klebsiella_oxytoca;
Eubacterium_eligens	0.0585427454768635	1.47923669414267e-06	0.00155592671340492	8.07766808145286e-05	6.16206399322162e-05	0.000237500099832823	0.00548214233845446	0.000449353893903027	0.00178759163879924	0.000327741733680859	k__Bacteria;p__Firmicutes;c__Clostridia;o__Clostridiales;f__Eubacteriaceae;g__Eubacterium;s__[Eubacterium]_eligens;
Flavonifractor_plautii	0.0031873296518326	0.0469260721877368	0.00200020304291863	2.60569938111383e-05	0.0010747003021656	0.000826178550523016	3.44505597315288e-05	0.000214215416360719	0.000278258731409942	0.000681458549146769	k__Bacteria;p__Firmicutes;c__Clostridia;o__Clostridiales;f__Ruminococcaceae;g__Flavonifractor;s__Flavonifractor_plautii;
"

bac<-read.table(text=data, row.names = 1)
class(bac)
bac2<-bac[,c(1:(ncol(bac)-1))]
bac3<- as.data.frame(t(bac2))
colnames(bac3)[1] <- 'SampleID'

bac3[,2:ncol(bac3)] <- sapply(bac3[,2:ncol(bac3)], as.character)
bac3[,2:ncol(bac3)] <- sapply(bac3[,2:ncol(bac3)], as.numeric)

str(bac2)

table<-read.table(text=meta, header=T)
head(table)

table_a<- merge(x=table, y=bac3, by="SampleID")
dim(table_a)
head(table_a)

subject_list<-colnames(table_a)[c(6:length(colnames(table_a)))]

for (subject in subject_list){
  print(subject)
  table2<-table_a[,c('SampleID', 'Group1', 'Group2', subject)]
  table2[,subject] <- table2[,subject] * 100
  table2$Group1 <- with(table2, relevel(Group1, "patient_before"))
  group <- "Group1"
  p<-ggplot(table2, aes_string(x = group, y = subject)) +
    geom_boxplot(aes(fill = Group1), alpha = 1, outlier.size=0, size=0.7, width=0.7,) +
    geom_point(aes(col = Group1)) +
    geom_line(aes(group = Group2), col = "gray") +
    xlab("")+ylab("Abundance Percent (%)")+ theme_bw() +
    theme(text = element_text(size = 10),
          panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
          axis.line = element_line(),panel.border =  element_blank(),
          axis.text.x = element_text(angle = 45,size = 10,hjust = 1)) +
    stat_compare_means(paired = TRUE)
  ggsave(plot = p, paste(subject, "Paired_boxplot",".png",sep = ""),width = 5,height = 7,dpi = 300) 
  ggsave(plot = p, paste(subject, "Paired_boxplot",".pdf",sep = ""),width = 5,height = 7,dpi = 300) 
}





