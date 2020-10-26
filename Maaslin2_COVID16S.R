library(Maaslin2)

#####
setwd("~/Desktop/COVID16S")

NoS_F_input_data <- read.table("~/Desktop/COVID16S/exported.NoS_F/Relative/otu_table.GenusSpecies.relative.FORMAASLIN.txt", header=T, sep = "\t",row.names = 1, stringsAsFactors = FALSE)
NoS_F_input_metadata <-read.table("/Users/chengguo/Desktop/COVID16S/mapping_all_20201013_F.txt", header=T, sep = "\t",row.names = 1, stringsAsFactors = FALSE)

#Maaslin2 gives different resut if swith the order of Group and FType2 in fixed_effects
fit_data <- Maaslin2(
  NoS_F_input_data, NoS_F_input_metadata, 'NoS_F.output_Masslin1013_F3', transform = "AST",
  fixed_effects = c('Detection','Sex','age','Antibiotic', 'Group','FType2'),
  random_effects = c('PatientID'),
  normalization = 'NONE',
  min_abundance = 0.0005,
  min_prevalence = 0.1,
  standardize = FALSE)

##
NoS_T_input_data <- read.table("~/Desktop/COVID16S/exported.NoS_T/Relative/otu_table.GenusSpecies.relative.FORMAASLIN.txt", header=T, sep = "\t",row.names = 1, stringsAsFactors = FALSE)
NoS_T_input_metadata <-read.table("/Users/chengguo/Desktop/COVID16S/mapping_all_20201013_T.txt", header=T, sep = "\t",row.names = 1, stringsAsFactors = FALSE)

fit_data <- Maaslin2(
  NoS_T_input_data, NoS_T_input_metadata, 'NoS_F.output_Masslin1013_T', transform = "AST",
  fixed_effects = c('Group','Detection','Sex','age','Antibiotic','TType2'),
  random_effects = c('PatientID'),
  normalization = 'NONE',
  min_abundance = 0.0005,
  min_prevalence = 0.1,
  standardize = FALSE)


#######################
setwd("~/Desktop/COVID16S")

NoS_F_input_data <- read.table("/Users/chengguo/Desktop/COVID16S/exported.NoS/picrust2_out_pipeline/pathways_out/path_abun_unstrat_descrip_ForMaaslin.NoS_F.txt", header=T, sep = "\t",row.names = 1, stringsAsFactors = FALSE)
NoS_F_input_metadata <-read.table("/Users/chengguo/Desktop/COVID16S/mapping_all_20201013_F.txt", header=T, sep = "\t",row.names = 1, stringsAsFactors = FALSE)

#https://forum.biobakery.org/t/why-do-coefs-differ-from-raw-glm-lmer-and-why-do-they-depend-on-number-of-input-features/500
fit_data <- Maaslin2(
  NoS_F_input_data, NoS_F_input_metadata, 'Pathway_NoS_F.output_Masslin1013_F', transform = "NONE",
  fixed_effects = c('Group','Detection','Sex','Antibiotic','FType2'),
  random_effects = c('PatientID'),
  normalization = 'TSS',
  min_abundance = 0.0005,
  min_prevalence = 0.1,
  standardize = FALSE)

##
NoS_T_input_data <- read.table("/Users/chengguo/Desktop/COVID16S/exported.NoS/picrust2_out_pipeline/pathways_out/path_abun_unstrat_descrip_ForMaaslin.NoS_T.txt", header=T, sep = "\t",row.names = 1, stringsAsFactors = FALSE)
NoS_T_input_metadata <-read.table("/Users/chengguo/Desktop/COVID16S/mapping_all_20201013_T.txt", header=T, sep = "\t",row.names = 1, stringsAsFactors = FALSE)

fit_data <- Maaslin2(
  NoS_T_input_data, NoS_T_input_metadata, 'Pathway_NoS_T.output_Masslin1013_T', transform = "NONE",
  fixed_effects = c('Group','Detection','Sex','age','Antibiotic','TType2'),
  random_effects = c('PatientID'),
  normalization = 'TSS',
  min_abundance = 0.0005,
  min_prevalence = 0.1,
  standardize = FALSE)