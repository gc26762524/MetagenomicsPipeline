#Sept 18, 2017, Adrian, fixed bug in run_cmd function to check both the success code and the exit code

package FileUtils;
use strict;
use warnings;
use File::Basename;
#use YAML::Syck;
use Sys::Hostname;
use Data::Dumper;
use IO::CaptureOutput qw/capture_exec/;

############################################################################################################################################
#
#	FileUtils.pm : This module contains subtroutines to manage files. (mv, rm, etc.)	
#
#############################################################################################################################################

####################
# Global Variables #
####################


###############
# Subroutines #
###############


#Accessor
sub get_exec {

	my $tool=$_[0];
	my $config_file=$_[1];
	my $host = hostname;

	#print "get_utils_exec_path\t$tool\t$config_file\t$host\n";
 
 	if (file_exists($config_file) eq "no") {die("ERROR: file $config_file not Found!\n");}
 	
	my $config = LoadFile($config_file);
    	
 	foreach my $field (sort keys %{ $config }) {
 		if ($host =~ /$field/) {
 			return $config->{$field}->{$tool."_EXEC"};
		}
	}
	
	#else return not available
	return "NA";
}

#move the relevant output files to target directory
sub move_files {

	my $file=$_[0];
	my $target_dir=$_[1];

    print "Moving file:$file\n";
    my($this_file, $this_dir) = fileparse($file);
    my $desired_file = "$target_dir"."$this_file";
    
    my $cmd ="find $this_dir -name \"$this_file\"";
    #print $cmd,"\n";
    my @files = `$cmd`;

    foreach my $file_to_move (@files) {
            $file_to_move=~s/\n//g;
            print "Moving $file_to_move file under $target_dir\n";
            if(-e $file_to_move && -f $file_to_move) {
                    if(-e $desired_file && -f $desired_file) {
                            print "$desired_file already present in $target_dir\n";
                    } else {
                            my $success = system("mv $file_to_move $target_dir");
                            check_status($success);
                    }
            } else {
                    print "File: $file not found\n";
            }
    }
}

#check the return status from system command...
sub check_status {
    my $success = $_[0];
    my $task = $_[1];
    if($success == 0) {
    		if($task){print("$task ")};
            print "task successfully executed (exit code $success)\n";
    } else {
            print "ERROR($success): Command failed\n";
            #die;
    }
}

sub file_exists{
	my ($file_name) = $_[0];

	if(-f $file_name && -e $file_name){
		#print "File $file_name exists!\n";
		return "yes";
	}else{
		print "File $file_name does NOT exist!\n";
		return "no";
	}
}

#check if directory exists or not. create one if not...
sub check_dir{
    my ($dir_name) = @_;

    if (-d $dir_name){
            print "directory $dir_name already exists!\n";
    }else{
            my $ret=system("mkdir $dir_name");
            if ($ret == 0 ) {print "directory $dir_name successfully created!\n";}
            else{ print "error : failed to create $dir_name directory!\n";}
    }
}

sub remove_files{

	my ($file) = $_[0];

	#print "Removing file:$file\n";
    my($this_file, $this_dir) = fileparse($file);

    my $cmd ="find $this_dir -name \"$this_file\"";
    print $cmd,"\n";
    my @files = `$cmd`;

    foreach my $file_to_remove (@files) {
            $file_to_remove=~s/\n//g;
            print "Removing $file_to_remove file\n";
	my $success = system("rm $file_to_remove");
	check_status($success);
    }
}

sub file_line_counts{

	my $file = $_[0];

	my $cmd = "wc -l $file |  cut -d\" \" -f1";
	my $num_lines = `$cmd`;
	chomp($num_lines);

	return $num_lines;
}

sub file_gz_line_counts{

	my $file = $_[0];

	my $cmd = "zcat $file | wc -l ";
	my $num_lines = `$cmd`;
	chomp($num_lines);

	return $num_lines;
}

# find latest log file based on job id number, when searched with wildcard in a file name.
#
sub find_latest_log{

	my $log_file = $_[0];
	my @files=`ls $log_file 2>/dev/null`;
	my $max_job_id = 0;
	
	for (my $i=0; $i < scalar(@files); $i++){
		my @cols = split(/\./,$files[$i]);
		my $id = $cols[$#cols];	
		$id =~ s/e|o//g;
		if ($max_job_id < $id){ $max_job_id = $id;}	
	}		

	#my $latest_log = `ls $log_file | grep $max_job_id 2>/dev/null`;
	my $latest_log = `ls $log_file 2>/dev/null| grep $max_job_id`;
	chomp($latest_log);
	if (-f $latest_log && -e $latest_log){	
		return $latest_log;
	}else{
		return "none";
	}
}

# find oldest log file based on job id number, when searched with wildcard in a file name.
#
sub find_oldest_log{

	my $log_file = $_[0];
	
	my @files=`ls $log_file`;
	my $min_job_id =99999999;
	
	for (my $i=0; $i < scalar(@files); $i++){
		my @cols = split(/\./,$files[$i]);
		my $id = $cols[$#cols];	
		$id =~ s/e|o//g;
		if ($min_job_id > $id){ $min_job_id = $id;}	
	}		

	my $oldest_log = `ls $log_file | grep $min_job_id`;
	chomp($oldest_log);
	
	return $oldest_log;
}


#run a system command and return a qsub job from a given command and return the job id.
sub run_cmd {

    my $cmd = $_[0];
    my $task = $_[1]; #this is still under construction
    print "\nRunning command: $cmd\n";

    my ($stdout, $stderr, $success, $exit_code) = capture_exec($cmd);

    #For succeful executions, usually success is 1 and exit code is 0
	#print "stdout: $stdout\n";
	#print "stderr: $stderr\n";
	#print "Success: $success\n"; 
	#print "Exit code: $exit_code\n";

    if ($exit_code != 0) {die "ERROR($exit_code): Command FAILED: $cmd \n $stderr \n";}

    if ($stdout){
        if ($task){ 
			FileUtils::check_status($exit_code, $task);
			return $stdout; 
		} else{
            my @return_val_string = split (/\s/, $stdout);
            my $job_id = $return_val_string[2];
            print "Running job:$job_id\n";
            return $job_id;   
        }
    } else {
    	FileUtils::check_status($exit_code, $task);
        return 0; 
    }
}
 
1;
