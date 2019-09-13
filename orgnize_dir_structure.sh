
mapping_file=$1
category_1=$2
#prefix=$3

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
        sh $0 M231_Mapping_2.tsv Group1 readme.pdf
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



echo "##############################################################\n#Organize the Result folder"

SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"
if [ -d "./Result_Metagenomics" ];then
    rm -r ./Result_Metagenomics;
fi;


mkdir -p Result_Metagenomics/8-FiguresTablesForReport \
    Result_Metagenomics/2-TaxaAundanceAnalysis/1-AbundanceSummary/1-RelativeAbundance \
    Result_Metagenomics/2-TaxaAundanceAnalysis/1-AbundanceSummary/2-Barplots \
    Result_Metagenomics/2-TaxaAundanceAnalysis/1-AbundanceSummary/4-Abundance_Metaphlan2 \
    Result_Metagenomics/2-TaxaAundanceAnalysis/1-AbundanceSummary/3-Heatmaps \
    Result_Metagenomics/2-TaxaAundanceAnalysis/2-AbundanceComparison/VennAndFlower \
    Result_Metagenomics/2-TaxaAundanceAnalysis/2-AbundanceComparison/ANCOM \
    Result_Metagenomics/2-TaxaAundanceAnalysis/2-AbundanceComparison/Paired_analysis_boxplot \
    Result_Metagenomics/2-TaxaAundanceAnalysis/2-AbundanceComparison/LEfSe \
    Result_Metagenomics/2-TaxaAundanceAnalysis/3-DiversityAnalysis \
    Result_Metagenomics/4-ORFPrediction \
    Result_Metagenomics/1-QCStats/2-QC_report_Filtered \
    Result_Metagenomics/1-QCStats/1-QC_report_Rawfastq \
    Result_Metagenomics/7-AdvancedAnalysis/4-Enterotyping \
    Result_Metagenomics/7-AdvancedAnalysis/5-PhagenomeAnalysis \
    Result_Metagenomics/7-AdvancedAnalysis/6-AYASDI \
    Result_Metagenomics/7-AdvancedAnalysis/1-AssociationAnalysis \
    Result_Metagenomics/7-AdvancedAnalysis/2-PHI \
    Result_Metagenomics/7-AdvancedAnalysis/3-VFDB \
    Result_Metagenomics/5-FuctionAnalysis/2-Metacyc_Humann2 \
    Result_Metagenomics/5-FuctionAnalysis/1-KEGG/LEfSe \
    Result_Metagenomics/3-Assembly/quast_results \
    Result_Metagenomics/6-AMRAnalysis/1-Summary \
    Result_Metagenomics/6-AMRAnalysis/2-Heatmaps \
    Result_Metagenomics/6-AMRAnalysis/3-SignificanceAnalysis \
    Result_Metagenomics/8-FiguresTablesForReport

cp $mapping_file Result_Metagenomics/
cp QC_report/*html Result_Metagenomics/1-QCStats/1-QC_report_Rawfastq/
mv Result_Metagenomics/1-QCStats/1-QC_report_Rawfastq/*good* Result_Metagenomics/1-QCStats/2-QC_report_Filtered/

cp Kraken2/*/Relative/Classified_stat_relative.png Kraken2/*/feature-table.taxonomy.biom Kraken2/*/feature-table.taxonomy.txt Result_Metagenomics/2-TaxaAundanceAnalysis/1-AbundanceSummary/
cp Kraken2/*/Relative/*relative.txt Result_Metagenomics/2-TaxaAundanceAnalysis/1-AbundanceSummary/1-RelativeAbundance/
cp -rp Kraken2/*/All.Taxa.taxa-bar-plots Kraken2/*/All.Taxa.taxa-bar-plots.1000  Kraken2/*/Barplot-of-Group-Mean Kraken2/*/taxa-bar-plots-top20-group-ordered Result_Metagenomics/2-TaxaAundanceAnalysis/1-AbundanceSummary/2-Barplots/
cp -r Kraken2/*/Heatmap/* Result_Metagenomics/2-TaxaAundanceAnalysis/1-AbundanceSummary/3-Heatmaps/
cp -r Metagenome/Metaphlan/All*txt Result_Metagenomics/2-TaxaAundanceAnalysis/1-AbundanceSummary/4-Abundance_Metaphlan2/


cp -r Kraken2/*/ANCOM/*ANCOM* Result_Metagenomics/2-TaxaAundanceAnalysis/2-AbundanceComparison/ANCOM/
cp -r Kraken2/*/Lefse/* Result_Metagenomics/2-TaxaAundanceAnalysis/2-AbundanceComparison/LEfSe/

cp -r Kraken2/*/VennAndFlower/*  Result_Metagenomics/2-TaxaAundanceAnalysis/2-AbundanceComparison/VennAndFlower/

cp -rp Kraken2/*/core-metrics/alpha Kraken2/*/core-metrics/bray_curtis_emperor Kraken2/*/PCoA-NMDS/* Result_Metagenomics/2-TaxaAundanceAnalysis/3-DiversityAnalysis/
rm -r Result_Metagenomics/2-TaxaAundanceAnalysis/3-DiversityAnalysis/alpha/chao1 \
    Result_Metagenomics/2-TaxaAundanceAnalysis/3-DiversityAnalysis/alpha/observed_otus \
    Result_Metagenomics/2-TaxaAundanceAnalysis/3-DiversityAnalysis/alpha/shannon

cp AMR/All.AMR.abundance.txt AMR/All.AMR.abundance_barplot.pdf Result_Metagenomics/6-AMRAnalysis/1-Summary/
cp AMR/All*heatmap* Result_Metagenomics/6-AMRAnalysis/2-Heatmaps/
cp AMR/All*lefse* Result_Metagenomics/6-AMRAnalysis/3-SignificanceAnalysis/


cp Assembly/Assembly/ORF* Result_Metagenomics/4-ORFPrediction/
cp -r Assembly/Assembly/quast_results/results*/* Result_Metagenomics/3-Assembly/quast_results/
#cp Assembly/Assembly/final.contigs.fa Result_Metagenomics/3-Assembly/


cp FMAP/All*.pdf FMAP/All*.txt Result_Metagenomics/5-FuctionAnalysis/1-KEGG/
mv Result_Metagenomics/5-FuctionAnalysis/1-KEGG/*lefse* Result_Metagenomics/5-FuctionAnalysis/1-KEGG/LEfSe/
cp Metagenome/Humann/All.*tsv Result_Metagenomics/5-FuctionAnalysis/2-Metacyc_Humann2/


################################################make FiguresTablesForReport
cp -rp ${SCRIPTPATH}/Report/src Result_Metagenomics/8-FiguresTablesForReport/
cp ${SCRIPTPATH}/Report/结题报告.html Result_Metagenomics/

cd Result_Metagenomics/8-FiguresTablesForReport
cp ../2-TaxaAundanceAnalysis/1-AbundanceSummary/Classified_stat_relative.png Figure4-1.png
cp ../2-TaxaAundanceAnalysis/1-AbundanceSummary/2-Barplots/taxa-bar-plots-top20-group-ordered/Phylum_${category_1}_ordered_barplot.pdf Figure4-2.pdf
#cp  Figure4-3.pdf
cp ../2-TaxaAundanceAnalysis/2-AbundanceComparison/VennAndFlower/${category_1}_Venn_plot.png Figure4-4.png
cp ../4-ORFPrediction/ORF_summary.pdf Figure6-1.pdf
cp ../5-FuctionAnalysis/1-KEGG/All.Function.abundance.KeepID.Pathway.Level1.pdf Figure7-1.pdf
#cp   Figure7-2.pdf
cp ../6-AMRAnalysis/1-Summary/All.AMR.abundance_barplot.pdf Figure8-1.pdf
cp ../6-AMRAnalysis/2-Heatmaps/All.AMR.abundance_${category_1}_heatmap.pdf Figure8-2.pdf

cp -r ../2-TaxaAundanceAnalysis/1-AbundanceSummary/2-Barplots/All.Taxa.taxa-bar-plots page4-2
cp -r ../2-TaxaAundanceAnalysis/3-DiversityAnalysis/bray_curtis_emperor page4-5
cp -r ../3-Assembly/quast_results page5-1

if [ -f Figure4-2.pdf ];then echo "Converting pdf to png"; for pdfs in *.pdf; do echo $pdfs; base=$(basename $pdfs .pdf); convert  -density 300 -quality 80 $pdfs ${base}.png; rm $pdfs;done;fi;
