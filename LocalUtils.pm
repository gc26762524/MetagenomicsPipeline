package LocalUtils;
use strict;
use warnings;
use List::Util qw[reduce min];

############################################################################################################################################
#
#	LocalUtils.pm : This module contains subtroutines used in current pipeline
#
#############################################################################################################################################

#split the database config file by pipe and derive the variables corresponding to database fields.
sub init_db_variables {
    
    my $line = $_[0];
    my @config_fields = split(/\|/, $line);
    my $db_id = $config_fields[0];
    my $db_name = $config_fields[1];
    my $db_path = $config_fields[2];
    my $db_flag = $config_fields[3];
    return ($db_id, $db_name, $db_path, $db_flag);
}

#Returns the prefix string from an array of strings
sub get_prefix {

	my @string_arr = @{$_[0]};

	my $prefix = reduce {
	    my $len = min(length $a, length $b);
	    my ($current_prefix, $string) = (substr($a, 0, $len), substr($b, 0, $len));

	    while($current_prefix ne $string) {
	        chop $current_prefix;
	        chop $string;
	    }

	    return $current_prefix;
	} @string_arr;

	return $prefix;

}

sub get_running_time {

	my $start_time = $_[0];
	my $end_time = $_[1];

	print "Done\n";
	my $end_run = time();
	my $run_time = $end_time - $start_time;
	print "Job took $run_time seconds\n";

}

1;
