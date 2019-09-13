#/usr/bin/perl

use strict;
use warnings;
local $SIG{__WARN__} = sub { die "ERROR in $0: ", $_[0] };

use Cwd 'abs_path';
use Getopt::Long;
use Data::Dumper;
#use Statistics::R;

(my $fmapPath = abs_path($0)) =~ s/\/[^\/]*$//;

GetOptions('h' => \(my $help = ''),
	'p=s' => \(my $orthology2pathwayFile = "$fmapPath/FMAP_data/KEGG_orthology2pathway.txt"),
	'd=s' => \(my $pathwayDefinitionFile = "$fmapPath/FMAP_data/KEGG_pathway.txt"),
);
if($help || scalar(@ARGV) == 0) {
	die <<EOF;

Usage:   perl ConvergeKO2Pathway.pl all.merged.abundance.KeepID.txt > all.merged.abundance.KeepID.Pathway.txt

Options: -h       display this help message

EOF
}

my ($input_file) = @ARGV;
foreach($input_file, $orthology2pathwayFile, $pathwayDefinitionFile) {
	die "ERROR in $0: '$_' is not readable.\n" unless(-r $_);
}

sub sum_array{
	my ($array1_ref, $array2_ref) = @_;
	my @array1 = @{ $array1_ref};
	my @array2 = @{ $array2_ref};
	my @array_sum = ();
	my $max = ($#array1 > $#array2) ? $#array1 : $#array2;
	@array_sum = map { $array1[$_] + $array2[$_] } (0..$max);
	return @array_sum;
}

my $header = '';
my (%KO_abundance, %module_abundance, %module2KO) = ();

open (FH, "<$orthology2pathwayFile") or die $!;
while(<FH>){
	chomp;
	my @array = split(/\t/);
	if (!defined($module2KO{$array[1]})){
		$module2KO{$array[1]} = $array[0];
	}
	else{
		$module2KO{$array[1]} = $module2KO{$array[1]}. ','. $array[0];
	}
}
close(FH);

open (FH2, "<$input_file") or die $!;
while(<FH2>){
	chomp;
	if ($. == 1){
		$header = $_;
		next;
	}
	my @array = split(/\t/);
	my $KO_ID = shift(@array);
	#print "AAAAAA", $KO_ID, "\n";
	$KO_abundance{$KO_ID} = [@array];
}
close(FH2);

for (sort keys %KO_abundance ) {
    my @value_array = @{$KO_abundance{$_}};
}

my %module_KO_counts = ();

for my $module_ID (sort keys %module2KO ) {
    my @array = split (/,/, $module2KO{$module_ID});
    my $module_KO_count = $#array + 1;
    $module_KO_counts{$module_ID} = $module_KO_count;
    my $element_count = 0;
    foreach my $element2 (@array){
    	if (exists $KO_abundance{$element2}){
    		$element_count ++;
    	}
    }

    foreach my $element (@array){
    	if (defined $KO_abundance{$element}){
	    	if (!defined $module_abundance{$module_ID}){
	    		@{$module_abundance{$module_ID}} = @{$KO_abundance{$element}};
	    	}else{
	    		@{$module_abundance{$module_ID}} = sum_array(\@{$module_abundance{$module_ID}}, \@{$KO_abundance{$element}});
	    	}
	    }else{
	    	next;
	    }
    }
}

#divide by the participated KO #.
print $header, "\n";
for my $module_existed (sort keys %module_abundance){
	my @normalized_module_abundance = map {($_ / $module_KO_counts{$module_existed})} @{$module_abundance{$module_existed}};
	#print the non-normalized abundance.
	#print $module_existed, "\t", join("\t", @{$module_abundance{$module_existed}}), "\n";
	print $module_existed, "\t", join("\t", @normalized_module_abundance), "\n";
}


