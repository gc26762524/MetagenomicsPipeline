use strict;
use warnings;

my $mapping_file = shift;
my $input_file = shift;


my %hash = ();

open (FH, "<$mapping_file") or die $!;
while(<FH>){
	chomp;
	my @array = split(/\t/);
	$hash{$array[0]} = $array[1];
}
close(FH);

open (FH2, "<$input_file") or die $!;
while(<FH2>){
	chomp;
	if ($. == 1){
		print $_, "\n";
		next;
	}
	my @array = split(/\t/);
	my $temp = $_;
	$temp =~ s/$array[0]/$hash{$array[0]}/;
	print $temp, "\n";
}
close(FH2);