#! /usr/bin/perl

use strict;
use warnings;
use File::Basename;
use Log::Log4perl qw(:easy);
use FileUtils;

#my $METAPHLAN_DIR=FileUtils::get_exec ("metaphlandir","./config.yml");
#my $METAPHLAN_EXEC=FileUtils::get_exec ("metaphlan","./config.yml");
#my $BOWTIE_EXEC=FileUtils::get_exec ("bowtie2","./config.yml");

# Usage: # perl run_metaphlan.pl test.list PE 8 
#
# test.list
# /share/data/IlluminaData/GTC/Mar02_2016_MiSeq/Raw_fastq/GTC-463.R1.fastq


unless (scalar @ARGV > 2) {
	print "\n\n1.Please provide the filtered and host-subtracted R1 fastq file list containing complete path names.\n";
	print "2.Please provide number of threads for your job [1-12]\n";
	print "3.Please provide the full path of the kraken database\n";
	
	print "\nUsage: # perl run_kraken.pl test.list 2 /share/data/software/kraken/database/standard_kraken\n\n\n";

	exit;
} 

my $file_list = shift @ARGV;
my $num_threads = shift @ARGV;
my $db_path = shift @ARGV;
my $MEM="50G";

open (SAMPLES, "<$file_list");
my $logger = Log::Log4perl->get_logger('Starting kraken wrapper for $file_list');

MAIN: {

	my $target_dir = ""; 
  	my $queue_hold_job_id = "";
 
  	while(<SAMPLES>){
			chomp;
        	my $in_fastq1  = $_;

        	if (-e $in_fastq1 && -f $in_fastq1) {
                
                
		    	my ($sample_file, $dir) = fileparse($in_fastq1);
	            my @directories = split(/Raw_fastq/, $dir);
	            my $out_dir = dirname($dir);
	            $target_dir=$out_dir."/Metagenome/Kraken/";
		    	my $out1_fastq1 =  $target_dir. $sample_file . ".kraken";
		    	my $out2_fastq1 =  $target_dir. $sample_file . ".lables";
		    	
		   		my @names = split(/\./,$sample_file);
				my $sample_name=$names[0];
		    	if (!(-e $target_dir)){ system("mkdir -p $target_dir"); } 
		   
		    	print "\nTarget directory: $target_dir\n";
	           	print "\nSample Name : $sample_name\n";
	            	
		   		my $CMD = "echo /share/data/software/kraken/kraken -db $db_path --threads $num_threads --fastq-input $in_fastq1 --output $out1_fastq1 | qsub -S /bin/bash -V -N $sample_name\_kraken -l h_vmem=$MEM -o $target_dir -e $target_dir -pe smp $num_threads -j y";
				FileUtils::run_cmd($CMD);
				my $CMD2 = "echo /share/data/software/kraken/kraken-translate --mpa-format --db $db_path $out1_fastq1 | qsub -hold_jid $sample_name\_kraken -S /bin/bash -V -N $sample_name\_kraken-translate -l h_vmem=$MEM -o $out2_fastq1 -e $target_dir";		
        		FileUtils::run_cmd($CMD2);
        		
        	}
	}
    close(SAMPLES);
}

