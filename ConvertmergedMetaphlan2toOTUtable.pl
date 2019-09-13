#! /usr/bin/perl

use strict;
use warnings;
use File::Basename;
use Getopt::Long qw(GetOptions);
use Pod::Usage qw(pod2usage);
use Data::Dumper;
$Data::Dumper::Sortkeys = 1;

my $inputfile= shift @ARGV;
my $outputfile = shift @ARGV;

unless (defined $inputfile && defined $outputfile){
	print "\nPlease provide following files with FULL path: \n";
	print "         1) input file from Kraken2 output in mpa-report format\n";
	print "         1) converted file for OTU table \n";
	print "\n\nUsage: \n";
	print "         perl $0 /share/home/cheng/pipelines/Github/IlluminaPipeline/SE/accession_list_from_viral_megablast.fasta /share/home/cheng/pipelines/Github/IlluminaPipeline/SE/test.sortedbam.list /share/home/cheng/pipelines/Github/IlluminaPipeline/SE/Mapping_summary.txt 5\n\n";
        
	exit;
}

my $header = '';
my $otu_count = 1;

open (FH1, "<$inputfile") or die $!;
open (OFH, ">$outputfile") or die $!;

while(<FH1>){
	chomp;
	if ($. == 1){
		$header = $_;
		$header =~ s/ID/#OTU ID/;
		$header = $header . "\ttaxonomy";
		print OFH $header, "\n";
		next;
	}
	next if /^#/;
	my @array = split(/\t/);
	my $string = sprintf ("%05d", $otu_count);
	$string = 'OTU'. $string;
	$array[0] =~ s/\|/;/g;
	$array[($#array)+1] = $array[0];
	$array[0] = $string;
	$otu_count ++;
	print OFH join("\t",@array),"\n";
}

close(FH1);
close(OFH);


__DATA__
ID	ESS1_1.fastq.paired.mpa.report.OTU	ESS2_1.fastq.paired.mpa.report.OTU
#SampleID	Metaphlan2_Analysis	Metaphlan2_Analysis
k__Bacteria|p__Acidobacteria|c__Acidobacteriia|o__Acidobacteriales|f__Acidobacteriaceae	0.0	1
k__Bacteria|p__Acidobacteria|c__Acidobacteriia|o__Acidobacteriales|f__Acidobacteriaceae|g__Acidobacterium|s__Acidobacterium_capsulatum	0.0	2
k__Bacteria|p__Acidobacteria|c__Acidobacteriia|o__Acidobacteriales|f__Acidobacteriaceae|g__Granulicella|s__Granulicella_tundricola	1	0.0
k__Bacteria|p__Acidobacteria|c__Acidobacteriia|o__Acidobacteriales|f__Acidobacteriaceae|g__Terriglobus|s__Terriglobus_roseus	0.0	2
k__Bacteria|p__Acidobacteria|c__Acidobacteriia|o__Acidobacteriales|f__Acidobacteriaceae|g__Terriglobus|s__Terriglobus_saanensis	1	1
k__Bacteria|p__Acidobacteria|c__Acidobacteriia|o__Acidobacteriales|f__Acidobacteriaceae|s__Acidobacteriaceae_bacterium_SBC82	0.0	1
k__Bacteria|p__Acidobacteria|c__Blastocatellia	0.0	1
k__Bacteria|p__Acidobacteria|c__Blastocatellia|g__Chloracidobacterium|s__Chloracidobacterium_thermophilum	0.0	1
