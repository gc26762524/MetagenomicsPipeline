#! /usr/bin/perl

use strict;
use warnings;
use File::Basename;
use Log::Log4perl qw(:easy);
use FileUtils;

#my $METAPHLAN_DIR=FileUtils::get_exec ("metaphlandir","./config.yml");
#my $METAPHLAN_EXEC=FileUtils::get_exec ("metaphlan","./config.yml");
#my $BOWTIE_EXEC=FileUtils::get_exec ("bowtie2","./config.yml");
#my $PYTHON_EXEC=FileUtils::get_exec ("python","./config.yml");
my $METAPHLAN_DIR="/home/cheng/softwares/metaphlan2/metaphlan2/";
my $METAPHLAN_EXEC="/home/cheng/softwares/metaphlan2/metaphlan2/metaphlan2.py";
my $BOWTIE_EXEC="/home/cheng/softwares/miniconda2/bin/bowtie2";
my $PYTHON_EXEC="/usr/bin/python";





#my $METAPHLAN_DIR= "/ifs/home/msph/cii/cg2984/software/metaphlan2";
#my $METAPHLAN_EXEC= "/ifs/home/msph/cii/cg2984/software/metaphlan2/metaphlan2.py";

# Usage: # perl run_metaphlan.pl test.list PE 8 
#
# test.list
# /share/data/IlluminaData/GTC/Mar02_2016_MiSeq/Raw_fastq/GTC-463.R1.fastq


unless (scalar @ARGV > 2) {
	print "1.Please provide the sample fastq file list containing complete path names \n";
	print "2.Please provide sequence type for prinseq [SE/PE]\n";
	print "3.Please provide number of threads for your job [1-8]\n";
	
	print "\n\nUsage: # perl run_metaphlan.pl test.list PE 2\n";
	print "test.list:\n";
	print "/share/data/IlluminaData/BRZ/MiSeq/test_Cheng/Host_subtracted_2017-10-02/bowtie/host_repeats_genomic/BRZ-2_S2_L001_R1_001.host_repeats_genomic.unmapped.fastq.gz\n";

	exit;
} 

my $file_list = shift @ARGV;
my $mode = shift @ARGV;
my $num_threads = shift @ARGV;
my $MEM="6G";

open (SAMPLES, "<$file_list");
my $logger = Log::Log4perl->get_logger('Starting running Metaphlan2 script for $file_list ...');

print "\nChecking file list ...\n";
if (FileUtils::file_exists($file_list) eq "no") {$logger->logdie("ERROR: File $file_list not Found!\n");}
else {$logger->info("running Metaphlan2 for $file_list\n"); $logger->debug("AAAAAAAAAAAAAAAAAAAAAAA\n");}


MAIN: {
	
	my $target_dir = ""; 
  	my $queue_hold_job_id = "";
 
  	while(<SAMPLES>){
		chomp;
        my $in_fastq1  = $_;
        my $in_fastq2  = "";
        my $input_files= "";
        print "Running Metaphlan2 for ", $in_fastq1, "\n";
        
        if (-e $in_fastq1 && -f $in_fastq1) {                
	    	my ($sample_file, $dir) = fileparse($in_fastq1);
          	my @directories = split(/Raw_fastq|Filtered|Primer_trimmed|Host_subtracted/, $dir);
            my $out_dir = $directories[0];
			$target_dir=$out_dir."/Metagenome/Metaphlan/";
	  		my @names = split(/\./,$sample_file);
			my $sample_name=$names[0];
	    	
	    	if (!(-e $target_dir)){ system("mkdir -p $target_dir"); } 
	   		print "\nTarget directory: $target_dir\n";
            print "Sample Name : $sample_name\n";
			if ($mode eq "SE"){
				$input_files = $in_fastq1;	
	   		}
			elsif ($mode eq "PE"){	
				$in_fastq2 = derive_r2_filename($in_fastq1);
				if ($in_fastq1 =~ /\.gz&/){
					$input_files = "<(zcat " . $in_fastq1 . "," . $in_fastq2 . ")"; 
				} 
				else{
					$input_files = $in_fastq1.",".$in_fastq2;  
				}
	    	}
			else{
				print "\nInvalid mode of sequence. Please, try either SE for Single-end reads & PE for Paired-end reads\n"; exit;
	    	}	
           
	  		my $CMD = "echo $PYTHON_EXEC $METAPHLAN_EXEC --input_type multifastq --bowtie2_exe $BOWTIE_EXEC --nproc $num_threads --bowtie2out $target_dir$sample_name.metagenome.bt2.out.txt $input_files -o $target_dir$sample_name.metaphlan.profile.txt | qsub -S /bin/bash -V -N $sample_name\_metaphlan -l h_vmem=$MEM -o $target_dir -e $target_dir -pe smp $num_threads";
	   		#print $CMD, "\n";
			FileUtils::run_cmd($CMD);
		}
	}
	close(SAMPLES);
}

sub derive_r2_filename{

	my $r1_file = $_[0];
	my $r2_file = $r1_file;
	$r2_file =~ s/R1/R2/g;

	if (-e $r2_file && -f $r2_file){
		print "R2 file $r2_file exists! proceed! \n";
		return $r2_file;
	}
	else{
		print "R2 file $r2_file does not exist! Stop. \n";
		exit;
	}
}

