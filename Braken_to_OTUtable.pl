#! /usr/bin/perl

use strict;
use warnings;
use File::Basename;
use Log::Log4perl qw(:easy);
use FileUtils;
use Data::Dumper;


unless (scalar @ARGV >= 2) {
	print "\n\n1.Please provide the full path of the taxid2OTU mapping file.\n";
	print "2.Please provide the full path of the kraken2 output list file.\n";
	
	print "\nUsage: # perl $0 /share/data/Databases/GenBank/Nov_2018/taxdmp/taxid2OTU_ranks.txt ZZG.Nov2018_standard.output.list \n\n\n";

	exit;
} 

my $taxaID_taxa_mapping_file = shift @ARGV;
my $kraken2_output_file_list = shift @ARGV;
#my $mapping_file = shift @ARGV;
#my $group = shift @ARGV;
#my $MEM="50G";
my $PERL="perl";
my $SHELL="sh";
my $SCRIPT_BASEDIR=dirname $0;
print "Running $0:\n";
print $SCRIPT_BASEDIR, "\n";


#my $PERL="perl";
#my $SHELL="sh";
#my $SCRIPT_BASEDIR=dirname $0;
#print "Running $0:\n";
#print $SCRIPT_BASEDIR, "\n";

my $target_dir = ""; 
my $queue_hold_job_id = "";
my (%taxa_count, %taxaID_taxa) = ();
my $header = "#SampleID\tKraken2";



open FH, "<$taxaID_taxa_mapping_file" or die $!;
while(<FH>){
	chomp;
	next if ($.==1);
	my @array = split(/\t/);
	$taxaID_taxa{$array[0]} = $array[1];
}
close(FH);

open FH2, "<$kraken2_output_file_list" or die $!;
while(<FH2>){
        chomp;
        my $in_report  = $_;
	my ($sample_file, $dir) = fileparse($in_report);
	$target_dir=$dir;
	my @names = split(/\.|_/,$sample_file);
	my $sample_name=$names[0];
	if (!(-e $target_dir)){ system("mkdir -p $target_dir"); }
	my $sampe_output =  $target_dir. $sample_name . ".txt";
	open OFH, ">$sampe_output" or die $!;
	if (-e $in_report && -f $in_report) {
		open FH3, "<$in_report" or die $!;
		while(<FH3>){
			chomp;
        		my @array = split(/\t/);
			if (not defined $taxa_count{$array[2]}){
			#print $array[2], "\n";
			$taxa_count{$array[1]} = $array[5];
			}
			else{
				$taxa_count{$array[2]} = $taxa_count{$array[2]} + $array[5];
			}
		}
		close(FH3);
	}

	print OFH $header, "\n";
	foreach my $key (sort {$a cmp $b} keys (%taxa_count)){
		if (not defined $taxaID_taxa{$key}){
			print STDERR "unidentified taxa will be excluded from the OTU table:", $key, "\t", $taxa_count{$key}, "\n";
			next;
		}else{
			print OFH $taxaID_taxa{$key}, "\t", $taxa_count{$key}, "\n";
		}
	}
	close(OFH);
	%taxa_count=();
}
close(FH2);


my $CMD2 = "${SCRIPT_BASEDIR}/merge_metaphlan_tables.py ${target_dir}*txt > ${target_dir}All.Taxa.txt";
FileUtils::run_cmd($CMD2);

my $CMD3 = "$PERL ${SCRIPT_BASEDIR}/ConvertmergedMetaphlan2toOTUtable.pl  ${target_dir}All.Taxa.txt ${target_dir}All.Taxa.OTU.txt";	
FileUtils::run_cmd($CMD3);

#print Dumper(\%taxa_count);


__DATA__
name    taxonomy_id     taxonomy_lvl    kraken_assigned_reads   added_reads     new_est_reads   fraction_total_reads
Streptococcus salivarius        1304    S       12      28      40      0.00007
Candidatus Arthromitus sp. SFB-mouse-NL 1508644 S       230     2292    2522    0.00457
Bacteroides caecimuris  1796613 S       7312    16517   23829   0.04319
Turicibacter sp. H121   1712675 S       1029    1047    2076    0.00376
Streptococcus oralis    1303    S       36      151     187     0.00034
Chryseobacterium gallinarum     1324352 S       6028    6901    12929   0.02343
Ruminococcus albus      1264    S       48      12      60      0.00011
Streptococcus suis      1307    S       337     1610    1947    0.00353
Bacteroides helcogenes  290053  S       69      4       73      0.00013
Anaerostipes hadrus     649756  S       332     974     1306    0.00237
