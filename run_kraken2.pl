#! /usr/bin/perl

use strict;
use warnings;
use File::Basename;
use Log::Log4perl qw(:easy);
use FileUtils;

#my $KRAKEN2_EXEC=FileUtils::get_exec ("kraken2","./config.yml");
my $KRAKEN2_EXEC="/home/cheng/softwares/kraken2/kraken2/kraken2";


unless (scalar @ARGV > 3) {
	print "\n\n1.Please provide the filtered and host-subtracted R1 fastq file list containing complete path names.\n";
	print "2.Please provide number of threads for your job [1-12]\n";
	print "3.Please provide the full path of the kraken database\n";
	print "4.Please provide the mode SE|PE \n";
	
	print "\nUsage: # perl run_kraken2.pl TCY.hostsubR1gz.list 2 /share/data/software/kraken2/kraken2/Oct_2018/ PE\n\n\n";

	exit;
} 

my $file_list = shift @ARGV;
my $num_threads = shift @ARGV;
my $db_path = shift @ARGV;
my $mode = shift @ARGV;
my $MEM="50G";
my $CONFIDENCE=0.2;
#my $CONFIDENCE=1;

open (SAMPLES, "<$file_list");
my $logger = Log::Log4perl->get_logger('Starting kraken wrapper for $file_list');

MAIN: {

	my $target_dir = ""; 
  	my $queue_hold_job_id = "";
 
  	while(<SAMPLES>){
		chomp;
        	my $in_fastq1  = $_;
		my $in_fastq2 = '';
		if ($mode eq 'PE'){
			$in_fastq2 = derive_r2_filename($in_fastq1);
		}  
        	if (-e $in_fastq1 && -f $in_fastq1) {
                
		   	my ($sample_file, $dir) = fileparse($in_fastq1);
	           	my @directories = split(/Raw_fastq|Filtered|Primer_Trimmed|Host_subtracted/, $dir);
	           	#my $out_dir = dirname($directories[0]);
	           	$target_dir=$directories[0]."/Kraken2/";
		    	
		   	my @names = split(/\./,$sample_file);
			my $sample_name=$names[0];
		    	if (!(-e $target_dir)){ system("mkdir -p $target_dir"); } 
		   	
		    	print "\nTarget directory: $target_dir\n";
	           	print "\nSample Name : $sample_name\n";
	            	my $kraken_output =  $target_dir. $sample_name . ".output";
			my $kraken_report = $target_dir. $sample_name . ".report";
			#my $CMD = "echo $KRAKEN2_EXEC --db $db_path --confidence 0 --paired $in_fastq1 $in_fastq2 --use-mpa-style --report $kraken_output | qsub -S /bin/bash -V -N $sample_name\_kraken-translate -l h_vmem=$MEM -o $target_dir -e $target_dir";
        		if ($mode eq 'SE'){
				my $CMD = "echo '$KRAKEN2_EXEC --db $db_path --threads $num_threads --confidence $CONFIDENCE --report $kraken_report $in_fastq1 > $kraken_output' | qsub -S /bin/bash -V -N $sample_name\_kraken-translate -l h_vmem=$MEM -o $target_dir -e $target_dir -pe smp $num_threads";
                                FileUtils::run_cmd($CMD);
			}elsif($mode eq 'PE'){
				my $CMD = "echo '$KRAKEN2_EXEC --db $db_path --threads $num_threads --confidence $CONFIDENCE --report $kraken_report --paired $in_fastq1 $in_fastq2 > $kraken_output' | qsub -S /bin/bash -V -N $sample_name\_kraken-translate -l h_vmem=$MEM -o $target_dir -e $target_dir -pe smp $num_threads";
                        	FileUtils::run_cmd($CMD);
			}else{
				print "The mode should be either SE or PE, EXIT\n";
				exit;
			}
        	}
	}
    	close(SAMPLES);
}

sub derive_r2_filename{

	my $r1_file = $_[0];
	my $r2_file = $r1_file;
	$r2_file =~ s/R1\.fastq/R2\.fastq/;

	if (-e $r2_file && -f $r2_file){
		print "R2 file $r2_file exists! proceed! \n";
		return $r2_file;
	}
	else{
		print "R2 file $r2_file does not exist! Stop. \n";
		exit;
	}
}
