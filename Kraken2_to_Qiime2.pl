#! /usr/bin/perl

use strict;
use warnings;
use File::Basename;
use Log::Log4perl qw(:easy);
use FileUtils;

unless (scalar @ARGV >= 1) {
	print "\n\n1.Please provide the kraken report file.\n";
	
	print "\nUsage: # perl run_kraken.pl\n\n\n";

	exit;
} 

my $file_list = shift @ARGV;
my $mapping_file = shift @ARGV;
my $group = shift @ARGV;
#my $MEM="50G";

my $PERL="perl";
my $SHELL="sh";
my $SCRIPT_BASEDIR=dirname $0;
print "Running $0:\n";
print $SCRIPT_BASEDIR, "\n";

open (SAMPLES, "<$file_list");
my $logger = Log::Log4perl->get_logger('Starting kraken2 and qiime2 wrapper for $file_list');

MAIN: {

	my $target_dir = ""; 
  	my $queue_hold_job_id = "";
 
  	while(<SAMPLES>){
		chomp;
        	my $in_report  = $_;
		#my $in_fastq2 = derive_r2_filename($in_report);
        	if (-e $in_report && -f $in_report) {
                
		   	my ($sample_file, $dir) = fileparse($in_report);
	           	#my @directories = split(/Raw_fastq|Filtered|Primer_Trimmed/, $dir);
	           	#my $out_dir = dirname($dir);
	           	$target_dir=$dir;
		    	
		   		my @names = split(/\.|_/,$sample_file);
				my $sample_name=$names[0];
		    	#if (!(-e $target_dir)){ system("mkdir -p $target_dir"); } 
		   	
		    	print "\nTarget directory: $target_dir\n";
	           	print "\nSample Name : $sample_name\n";
	        	my $metaphlan2_output =  $dir. $sample_name . ".txt";
				my $CMD = "$PERL ${SCRIPT_BASEDIR}/ConvertKraken2toMetaphlan2.pl $in_report $metaphlan2_output";
        		FileUtils::run_cmd($CMD);
        		
        	}
		else{
			print "ERROR: file $in_report not found.\n";
			exit;
		}
	}
    	close(SAMPLES);

	my $CMD2 = "${SCRIPT_BASEDIR}/merge_metaphlan_tables.py ${target_dir}*txt > ${target_dir}All.merged.txt";
	FileUtils::run_cmd($CMD2);

	my $CMD3 = "$PERL ${SCRIPT_BASEDIR}/ConvertmergedMetaphlan2toOTUtable.pl  ${target_dir}All.merged.txt ${target_dir}All.merged.OTU.txt";	
	FileUtils::run_cmd($CMD3);
	
	#my $CMD4 = "$SHELL  ${SCRIPT_BASEDIR}/visualize_otu_table_by_qiime2.sh ${target_dir}All.merged.OTU.txt $mapping_file $group";
	#FileUtils::run_cmd($CMD4);
}

