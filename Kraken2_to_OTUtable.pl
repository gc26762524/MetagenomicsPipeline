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
			next unless (/^C/);
			if (not defined $taxa_count{$array[2]}){
			#print $array[2], "\n";
			$taxa_count{$array[2]} = 1;
			}
			else{
				$taxa_count{$array[2]}++;
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


my $CMD2 = "${SCRIPT_BASEDIR}/merge_metaphlan_tables.py ${target_dir}*txt > ${target_dir}All.merged.txt";
FileUtils::run_cmd($CMD2);

my $CMD3 = "$PERL ${SCRIPT_BASEDIR}/ConvertmergedMetaphlan2toOTUtable.pl  ${target_dir}All.merged.txt ${target_dir}All.merged.OTU.txt";	
FileUtils::run_cmd($CMD3);

#print Dumper(\%taxa_count);


__DATA__
C	K00224:30:H7FGYBBXX:1:1101:7740:3793	649756	90|90	649756:33 0:8 649756:5 0:10 |:| 649756:12 0:20 649756:1 0:1 649756:19 0:3
C	K00224:30:H7FGYBBXX:1:1101:4117:3952	28116	90|90	28116:5 0:51 |:| 28116:56
C	K00224:30:H7FGYBBXX:1:1101:6908:4884	997877	90|90	997877:20 0:28 1:3 28384:5 |:| 0:2 997877:5 816:5 997877:6 0:29 1:9
C	K00224:30:H7FGYBBXX:1:1101:7496:4884	2	90|90	0:50 2:2 0:4 |:| 0:56
C	K00224:30:H7FGYBBXX:1:1101:4777:4813	997877	90|90	997877:34 0:3 997877:5 0:14 |:| 0:2 28118:19 0:35
C	K00224:30:H7FGYBBXX:1:1101:6542:4848	816	90|90	816:32 0:11 816:1 0:12 |:| 816:56
C	K00224:30:H7FGYBBXX:1:1101:9019:4848	2109691	90|90	2109691:31 0:25 |:| 2109691:55 0:1
C	K00224:30:H7FGYBBXX:1:1101:1580:4936	1	90|90	0:26 1028729:5 0:1 1:3 28384:5 0:16 |:| 0:31 1:25
C	K00224:30:H7FGYBBXX:1:1101:6766:4989	997877	90|90	997877:56 |:| 997877:35 0:3 997877:1 0:17
C	K00224:30:H7FGYBBXX:1:1101:6309:5288	679935	90|90	679935:56 |:| 0:19 679935:37
C	K00224:30:H7FGYBBXX:1:1101:8501:5323	28116	90|90	0:21 28116:3 0:5 28116:10 0:17 |:| 0:1 28116:12 0:40 28116:1 0:2
U	K00224:30:H7FGYBBXX:1:1101:2554:5112	0	90|90	0:56 |:| 0:56
C	K00224:30:H7FGYBBXX:1:1101:3904:5130	997877	90|90	0:30 997877:26 |:| 997877:40 816:7 997877:5 816:4
C	K00224:30:H7FGYBBXX:1:1101:4888:5042	28113	90|90	0:56 |:| 0:39 28113:5 0:12
U	K00224:30:H7FGYBBXX:1:1101:8278:5042	0	90|90	0:56 |:| 0:56
C	K00224:30:H7FGYBBXX:1:1101:6157:5059	818	90|90	0:11 818:5 0:20 171549:1 0:19 |:| 0:56
U	K00224:30:H7FGYBBXX:1:1101:4300:5077	0	90|90	0:56 |:| 0:56
U	K00224:30:H7FGYBBXX:1:1101:3254:5411	0	90|90	0:56 |:| 0:56
U	K00224:30:H7FGYBBXX:1:1101:9891:5411	0	90|90	0:56 |:| 0:56
C	K00224:30:H7FGYBBXX:1:1101:4797:5481	435590	90|90	0:40 435590:5 0:11 |:| 0:56
C	K00224:30:H7FGYBBXX:1:1101:5477:5534	816	90|90	816:30 0:22 816:1 0:3 |:| 0:1 816:55
U	K00224:30:H7FGYBBXX:1:1101:3762:5552	0	90|90	0:56 |:| 0:56
U	K00224:30:H7FGYBBXX:1:1101:7415:5552	0	90|90	0:56 |:| 0:56
C	K00224:30:H7FGYBBXX:1:1101:4310:5587	997877	90|90	0:4 816:5 0:18 816:5 0:5 816:4 0:11 816:1 0:3 |:| 0:4 997877:5 816:1 997877:8 816:38
C	K00224:30:H7FGYBBXX:1:1101:15635:5587	997877	90|90	0:7 816:5 0:10 816:1 0:3 816:5 0:2 816:21 821:2 |:| 0:1 816:22 997877:21 816:5 997877:2 816:5
U	K00224:30:H7FGYBBXX:1:1101:3315:5657	0	90|90	0:56 |:| 0:56
C	K00224:30:H7FGYBBXX:1:1101:7253:5833	28116	90|90	28116:56 |:| 28116:56
C	K00224:30:H7FGYBBXX:1:1101:5639:5886	997877	90|90	0:36 816:15 997877:5 |:| 0:15 816:1 0:1 816:17 997877:22
C	K00224:30:H7FGYBBXX:1:1101:5000:6079	28116	90|90	28116:26 0:30 |:| 28116:56
C	K00224:30:H7FGYBBXX:1:1101:10764:6114	818	90|90	0:1 2:5 0:1 816:1 0:5 976:5 818:12 816:3 0:23 |:| 0:56
C	K00224:30:H7FGYBBXX:1:1101:9232:6167	28116	90|90	0:18 28116:22 0:16 |:| 28116:42 0:14
C	K00224:30:H7FGYBBXX:1:1101:9841:6167	435590	90|90	0:12 435590:1 0:43 |:| 0:4 435590:52
C	K00224:30:H7FGYBBXX:1:1101:2199:6185	997877	90|90	0:20 997877:6 816:4 0:7 816:4 0:11 997877:1 0:3 |:| 997877:1 0:4 997877:35 816:13 997877:3
C	K00224:30:H7FGYBBXX:1:1101:6563:6185	997877	90|90	816:48 0:8 |:| 997877:56
U	K00224:30:H7FGYBBXX:1:1101:3934:6202	0	90|90	0:56 |:| 0:56
C	K00224:30:H7FGYBBXX:1:1101:4564:6202	28116	90|90	28116:49 816:2 28116:5 |:| 0:35 28116:7 0:2 28116:5 0:7
U	K00224:30:H7FGYBBXX:1:1101:5193:6202	0	90|90	0:56 |:| 0:56
C	K00224:30:H7FGYBBXX:1:1101:2777:6238	28116	90|90	0:47 28116:1 0:5 28116:3 |:| 0:4 28116:19 0:5 28116:3 0:25
C	K00224:30:H7FGYBBXX:1:1101:3325:6238	515619	90|90	0:56 |:| 0:38 515619:5 0:13
C	K00224:30:H7FGYBBXX:1:1101:4482:6238	1796613	90|90	0:18 1796613:38 |:| 0:18 1796613:3 0:7 1796613:28
