use strict;
use warnings;

my $mapping_file = shift;
my $input_file = shift;

unless (defined $mapping_file && defined $input_file){

	print "\n\n1.Please provide the path of the ID/annotation mapping file.\n";
	print "2.Please provide sorted lefse output file\n";
	
	print "\nUsage: # perl $0  OTUID_taxa_mapper.txt otu_table.Species.relative.ForLEfSe.Group1.lefse.txt.1vsALL.res.txt \n\n\n";

	exit;
}

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
	#if ($. == 1){
	#	print $_, "\n";
	#	next;
	#}
	my @array = split(/\t/);
	my $temp = $_;
	$temp =~ s/$array[0]/$hash{$array[0]}/;
	print $temp, "\n";
}
close(FH2);