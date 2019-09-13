#! /usr/bin/perl

use strict;
use warnings;
use File::Basename;
use Log::Log4perl qw(:easy);
use FileUtils;

my $HUMANN_EXEC= "humann2";

# Usage: # perl run_metaphlan.pl test.list PE 8 
#
# test.list
# /share/data/IlluminaData/GTC/Mar02_2016_MiSeq/Raw_fastq/GTC-463.R1.fastq


unless (scalar @ARGV > 1) {
	print "1.Please provide the sample fastq file list containing complete path names (for PE, use only R1 file. R2 name will be derivated) \n";
	print "2.Please provide sequence type for prinseq [SE/PE]\n";
	
	print "\n\nUsage: # perl run_humann.pl VIH_pool1.filteredR1gz.list SE\n";


	exit;
} 

my $file_list = shift @ARGV;
my $mode = shift @ARGV;
#my $num_threads = shift @ARGV;
my $MEM="35G";

open (SAMPLES, "<$file_list");
my $logger = Log::Log4perl->get_logger('Starting prinseq wrapper for $file_list');


MAIN: {
	my $target_dir = ""; 
  	my $queue_hold_job_id = "";
 
  	while(<SAMPLES>){
		chomp;
        	my $in_fastq1  = $_;
        	my $in_fastq2  = "";
        	my $input_files= "";
                print $in_fastq1, "%%%%%%%%%%%%%%\n";
        	if (-e $in_fastq1 && -f $in_fastq1) {
                        
	    		my ($sample_file, $dir) = fileparse($in_fastq1);
          		my @directories = split(/Raw_fastq|Filtered|Primer_trimmed|Host_subtracted/, $dir);
            		my $out_dir = $directories[0];
			$target_dir=$out_dir."/Metagenome/Humann/";
 
	    		my @names = split(/\./,$sample_file);
			my $sample_name=$names[0];
	    		if (!(-e $target_dir)){ system("mkdir -p $target_dir"); } 
	   
	    		print "Target directory: $target_dir\n";
            		print "Sample Name : $sample_name\n";
		
			if ($mode eq "SE"){
				$input_files = $in_fastq1;	
	   		 }
			elsif ($mode eq "PE"){	
				$in_fastq2 = derive_r2_filename($in_fastq1);
				$input_files = $in_fastq1.",".$in_fastq2;	
	    		}
			else{
				print "Invalid mode of sequence. Please, try either SE for Single-end reads & PE for Paired-end reads\n"; exit;
	    		}	
	  		#my $CMD = "echo $HUMANN_EXEC --input $input_files --bowtie2 /ifs/home/msph/cii/cg2984/software/bowtie2-2.2.9/ --metaphlan /ifs/home/msph/cii/cg2984/software/metaphlan2/ --diamond /ifs/home/msph/cii/cg2984/.local/bin --output $target_dir$sample_name | qsub -S /bin/bash -V -N $sample_name\_humann -l h_vmem=$MEM -o $target_dir -e $target_dir -j y";
	   		my $CMD = "echo $HUMANN_EXEC --input $input_files --bowtie2 ~/ --metaphlan /share/home/cheng/software/metaphlan2 --diamond /share/data/software/diamond/v0.8.38 --output $target_dir$sample_name --taxonomic-profile /share/data/IlluminaData/VIH/Nov17_2016/merged/humann2/Metagenome/kraken.species.revised.chocophlan.withvalue.txt | qsub -S /bin/bash -V -N $sample_name\_humann -l h_vmem=$MEM -o $target_dir -e $target_dir -j y";
			print $CMD, "\n";
			FileUtils::run_cmd($CMD);
			#my $CMD_2 = "echo rm -r $target_dir$sample_name/*humann2_temp/ | qsub -hold_jid $sample_name\_humann -S /bin/bash -V -N $sample_name\_deletingTemp -l h_vmem=$MEM -o $target_dir -e $target_dir -j y";
			#FileUtils::run_cmd($CMD_2);
        }
	}
    	close(SAMPLES);
  
}


sub derive_r2_filename{

	my $r1_file = $_[0];
	my $r2_file = $r1_file;
	$r2_file =~ s/\.R1\./\.R2\./g;

	if (-e $r2_file && -f $r2_file){
		print "R2 file $r2_file exists! proceed! \n";
		return $r2_file;
	}else{
		print "R2 file $r2_file does not exist! Stop. \n";
		exit;
	}
}

