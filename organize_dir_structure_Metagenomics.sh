#/bin/sh -S
#########
#Please address any bugs to Cheng. 
#Date 2017.12.19
#########
mapping_file=$1
category_1=$2
SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"

if [ -z "$2" ]; then
	echo "##########

		  Please prepare the directory structure before starting the program like below:
		  raw/fastq_files ...
		  mapping_file
		  manifest_file
		  \n\n"

	echo "Please provide following input parameters
		1) Full path of the mapping file. (Accept both .csv or txt format.)
		2) The name of the first category in the mapping file. 

		Sample Usage:
		sh ~/pipelines/Github/CII_meta/organize_dir_structure_Metagenomics.sh ~/Desktop/demo.mapping.txt Group1
		"
	exit 0
else
	echo "################
	Running: sh $0 $1 $2"
fi

check_file() {
	echo "Checking file for $1 ..."
	file_name=$1
	if [ -f $file_name ]; then
		echo "File $file_name exists"
	else
		echo "File $file_name does not exist"
		exit
	fi
}

check_dir() {
	echo "Cheking the directory for $1 ..."
	dir_name=$1
	if [ ! -d "$dir_name" ]; then
		echo "Creating directory $dir_name"
		mkdir -pv $dir_name
	else
		echo "Directory $dir_name exists."
	fi
}

organize_result_structure() {

	mkdir -p ./Result_Metagenomics/ \
	./Result_Metagenomics/1-QCStats/1-QC_report_Rawfastq/ \
	./Result_Metagenomics/1-QCStats/2-QC_report_Filtered/ \
	./Result_Metagenomics/2-TaxaAundanceAnalysis/ \
	./Result_Metagenomics/2-TaxaAundanceAnalysis/1-AbundanceSummary/1-RelativeAbundance/ \
	./Result_Metagenomics/2-TaxaAundanceAnalysis/1-AbundanceSummary/2-Barplots/ \
	./Result_Metagenomics/2-TaxaAundanceAnalysis/1-AbundanceSummary/3-Heatmaps/ \
	./Result_Metagenomics/2-TaxaAundanceAnalysis/1-AbundanceSummary/4-Abundance_Metaphlan2/ \
	./Result_Metagenomics/2-TaxaAundanceAnalysis/2-AbundanceComparison/ANCOM/ \
	./Result_Metagenomics/2-TaxaAundanceAnalysis/2-AbundanceComparison/LEfSe/ \
	./Result_Metagenomics/2-TaxaAundanceAnalysis/2-AbundanceComparison/VennAndFlower/ \
	./Result_Metagenomics/2-TaxaAundanceAnalysis/3-DiversityAnalysis/ \
	./Result_Metagenomics/3-Assembly/quast_results/ \
	./Result_Metagenomics/4-ORFPrediction/ \
	./Result_Metagenomics/5-FuctionAnalysis/1-KEGG/ \
	./Result_Metagenomics/5-FuctionAnalysis/1-KEGG/LEfSe/ \
	./Result_Metagenomics/5-FuctionAnalysis/2-Metacyc_Humann2/ \
	./Result_Metagenomics/6-AMRAnalysis/1-Summary/ \
	./Result_Metagenomics/6-AMRAnalysis/2-Heatmaps/ \
	./Result_Metagenomics/6-AMRAnalysis/3-SignificanceAnalysis/ \
	./Result_Metagenomics/7-AdvancedAnalysis/1-AssociationAnalysis/ \
	./Result_Metagenomics/7-AdvancedAnalysis/2-PHI/ \
	./Result_Metagenomics/7-AdvancedAnalysis/3-VFDB/ \
	./Result_Metagenomics/7-AdvancedAnalysis/4-Enterotyping/ \
	./Result_Metagenomics/7-AdvancedAnalysis/5-PhagenomeAnalysis/ \
	./Result_Metagenomics/7-AdvancedAnalysis/6-AYASDI/ \
	./Result_Metagenomics/8-FiguresTablesForReport/

	echo "Start organize the files for deliverables ..."
	
	cp ${SCRIPTPATH}/Result_README.pdf ${SCRIPTPATH}/结题报告.html ./Result_Metagenomics/
	cp -r ${SCRIPTPATH}/src ./Result_Metagenomics/8-FiguresTablesForReport/
	cp $mapping_file ./Result_Metagenomics/mapping_file.txt


	cp -r QC_report/*R[12]_fastqc.html ./Result_Metagenomics/1-QCStats/1-QC_report_Rawfastq/
	cp -r QC_report/*good*html ./Result_Metagenomics/1-QCStats/2-QC_report_Filtered/
	cp -r Kraken2/All*_Qiime2_output*/feature-table.taxonomy* Kraken2/All*_Qiime2_output*/Relative/Classified_stat_relative.png ./Result_Metagenomics/2-TaxaAundanceAnalysis/1-AbundanceSummary/
	cp -r Kraken2/All*_Qiime2_output*/Relative/*relative.txt ./Result_Metagenomics/2-TaxaAundanceAnalysis/1-AbundanceSummary/1-RelativeAbundance/
	cp -r Kraken2/All*_Qiime2_output*/Barplot-of-Group-Mean Kraken2/All.Taxa_Qiime2_output_demo.Bracken/taxa-bar-plots-top20-group-ordered Kraken2/All.Taxa_Qiime2_output_demo.Bracken/All.Taxa.taxa-bar-plots Kraken2/All.Taxa_Qiime2_output_demo.Bracken/All.Taxa.taxa-bar-plots.100 ./Result_Metagenomics/2-TaxaAundanceAnalysis/1-AbundanceSummary/2-Barplots/
	cp -r Kraken2/All*_Qiime2_output*/Heatmap/* ./Result_Metagenomics/2-TaxaAundanceAnalysis/1-AbundanceSummary/3-Heatmaps/
	cp -r Metagenome/Metaphan/All.Metaphlan2.profile.txt ./Result_Metagenomics/2-TaxaAundanceAnalysis/1-AbundanceSummary/4-Abundance_Metaphlan2/
	cp -r Kraken2/All*_Qiime2_output*/ANCOM/*ANCOM* ./Result_Metagenomics/2-TaxaAundanceAnalysis/2-AbundanceComparison/ANCOM/
	cp -r Kraken2/All*_Qiime2_output*/LEfSe/*res.txt Kraken2/All.Taxa_Qiime2_output_demo.Bracken/LEfSe/*res.p* ./Result_Metagenomics/2-TaxaAundanceAnalysis/2-AbundanceComparison/LEfSe/
	cp -r Kraken2/All*_Qiime2_output*/VennAndFlower/* ./Result_Metagenomics/2-TaxaAundanceAnalysis/2-AbundanceComparison/VennAndFlower/
	cp -r Kraken2/All*_Qiime2_output*/PCoA-NMDS/* Kraken2/All*_Qiime2_output*/core-metrics-results/alpha/alpha* Kraken2/All*_Qiime2_output*/core-metrics-results/alpha/*.p* Kraken2/All*_Qiime2_output*/core-metrics-results/alpha-rarefaction Kraken2/All*_Qiime2_output*/core-metrics-results/bray_curtis_emperor ./Result_Metagenomics/2-TaxaAundanceAnalysis/3-DiversityAnalysis/
	cp -r Assembly/Assembly/final.contigs.fa ./Result_Metagenomics/3-Assembly/
	cp -r Assembly/Assembly/quast_results/results* ./Result_Metagenomics/3-Assembly/quast_results/
	cp -r Assembly/Assembly/ORF* ./Result_Metagenomics/4-ORFPrediction/
	cp -r FMAP/all*KO.txt FMAP/all*Module.txt FMAP/all*Pathway.txt FMAP/*Level* ./Result_Metagenomics/5-FuctionAnalysis/1-KEGG/
	cp -r FMAP/all*lefse*res.txt FMAP/all*lefse*res.png FMAP/all*lefse*res.pdf ./Result_Metagenomics/5-FuctionAnalysis/1-KEGG/LEfSe/
	cp -r Metagenome/Humann/All.Humann2.*tsv ./Result_Metagenomics/5-FuctionAnalysis/2-Metacyc_Humann2/
	cp -r AMR/all.AMR.abundance.txt AMR/all.AMR.abundance_barplot* ./Result_Metagenomics/6-AMRAnalysis/1-Summary/
	cp -r AMR/*heatmap* ./Result_Metagenomics/6-AMRAnalysis/2-Heatmaps/
	cp -r AMR/*res.txt AMR/*res.png AMR/*res.pdf ./Result_Metagenomics/6-AMRAnalysis/3-SignificanceAnalysis/

}

organize_figure_structure() {
	cp Result_Metagenomics/2-TaxaAundanceAnalysis/1-AbundanceSummary/Classified_stat_relative.png Result_Metagenomics/8-FiguresTablesForReport/Figure4-1.png
	cp Result_Metagenomics/2-TaxaAundanceAnalysis/1-AbundanceSummary/2-Barplots/taxa-bar-plots-top20-group-ordered/Phylum_Group1_ordered_barplot.pdf Result_Metagenomics/8-FiguresTablesForReport/Figure4-2.pdf
	cp Result_Metagenomics/2-TaxaAundanceAnalysis/2-AbundanceComparison/LEfSe/otu_table.Species.relative.ForLEfSe.Group1.lefse.txt.1vsALL.res.png Result_Metagenomics/8-FiguresTablesForReport/Figure4-3.png
	cp Result_Metagenomics/2-TaxaAundanceAnalysis/2-AbundanceComparison/VennAndFlower/Group1_Venn_plot.png Result_Metagenomics/8-FiguresTablesForReport/Figure4-4.png
	cp Result_Metagenomics/4-ORFPrediction/ORF_summary.png Result_Metagenomics/8-FiguresTablesForReport/Figure6-1.png
	cp Result_Metagenomics/5-FuctionAnalysis/1-KEGG/all.Function.abundance.KeepID.Pathway.Level1.png Result_Metagenomics/8-FiguresTablesForReport/Figure7-1.png
	cp Result_Metagenomics/5-FuctionAnalysis/1-KEGG/LEfSe/all.Function.abundance.KeepID.Pathway.Group1.lefse.txt.1vsALL.res.png Result_Metagenomics/8-FiguresTablesForReport/Figure7-2.png
	cp Result_Metagenomics/6-AMRAnalysis/1-Summary/all.AMR.abundance_barplot.pdf Result_Metagenomics/8-FiguresTablesForReport/Figure8-1.pdf
	cp Result_Metagenomics/6-AMRAnalysis/2-Heatmaps/all.AMR.abundance_Group1_heatmap.pdf Result_Metagenomics/8-FiguresTablesForReport/Figure8-2.pdf
	cp Result_Metagenomics/7-AdvancedAnalysis/1-AssociationAnalysis/Species/Group1_RDA_sample_location_plot.pdf Result_Metagenomics/8-FiguresTablesForReport/Figure9-1.pdf
	cp -r Result_Metagenomics/2-TaxaAundanceAnalysis/1-AbundanceSummary/2-Barplots/All.Taxa.taxa-bar-plots.100 Result_Metagenomics/8-FiguresTablesForReport/page4-2
	cp -r Result_Metagenomics/2-TaxaAundanceAnalysis/3-DiversityAnalysis/bray_curtis_emperor/ Result_Metagenomics/8-FiguresTablesForReport/page4-5
	cp -r Result_Metagenomics/3-Assembly/quast_results/results*/ Result_Metagenomics/8-FiguresTablesForReport/page5-1
}

MAIN() {

	echo "##############################################################\n#Organize the Result folder"
	organize_result_structure
	organize_figure_structure
	
}

MAIN;
