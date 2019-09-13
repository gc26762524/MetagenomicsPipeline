#/usr/bin/perl

use strict;
use warnings;
local $SIG{__WARN__} = sub { die "ERROR in $0: ", $_[0] };

use Cwd 'abs_path';
use Getopt::Long;
use Data::Dumper;
#use Statistics::R;

(my $ScriptPath = abs_path($0)) =~ s/\/[^\/]*$//;

unless (scalar @ARGV == 4) {
	print "\n\n1.Please provide the pathway list in a single column (`cut -f1 all.merged.abundance.KeepID.Pathway.txt > all.merged.abundance.KeepID.Pathway.list`).\n";
	print "2.Please provide the KO list in a single column (`cut -f1 all.merged.abundance.KeepID.KO.txt > all.merged.abundance.KeepID.KO.list`).\n";
	print "3.Please provide the 1vsALL file\n";
	print "4.Please provide the ALLvsALL file\n";
	
	print "\nUsage: # perl $0 all.merged.abundance.KeepID.Pathway.list all.merged.abundance.KeepID.KO.list all.merged.abundance.KeepID.KO.Group1.lefse.txt.1vsALL.res.txt all.merged.abundance.KeepID.KO.Group1.lefse.txt.ALLvsALL.res.txt > all.merged.abundance.KeepID.Pathway.list.withpath.txt\n\n\n";

	exit;
}

my $pathway_list_file = shift @ARGV;
my $KO_list_file = shift @ARGV;
my $ONEvsALL_file = shift @ARGV;
my $ALLvsALL_file = shift @ARGV;

my $orthology2pathwayFile = "$ScriptPath/FMAP_data/KEGG_orthology2pathway.txt";
my $pathwayDefinitionFile = "$ScriptPath/FMAP_data/KEGG_pathway.txt";

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
#print Dumper (\%module2KO);

my %KO_condition = ();
open (FH2, "<$KO_list_file") or die $!;
while(<FH2>){
	chomp;
	if ($. == 1){
		$header = $_;
		next;
	}
	$KO_condition{$_} = 'exist';
}
close(FH2);
#print Dumper (\%KO_condition);

open (FH3, "<$ONEvsALL_file ") or die $!;
while(<FH3>){
	chomp;
	my @array = split(/\t/);
	if ($array[2] ne ''){
		my $condition = $array[2]. '_1vsall';
		$KO_condition{$array[0]} = $condition;
	}
}
close(FH3);

open (FH4, "<$ALLvsALL_file ") or die $!;
while(<FH4>){
	chomp;
	my @array = split(/\t/);
	if ($array[2] ne ''){
		my $condition = $array[2]. '_allvsall';
		$KO_condition{$array[0]} = $condition;
		#print $array[0], "\n";
	}
}
close(FH4);
#print Dumper (\%KO_condition);

open (FH5, "<$pathway_list_file") or die $!;
while(<FH5>){
	chomp;
	if ($. == 1){
		$header = $_;
		next;
	}
	my $string = $module2KO{$_};
	my ($path_string, $color) = '';
	my @array = split (/,/, $string);
	foreach my $element (@array){
		my $color = '';
		if (!defined $KO_condition{$element}){
			next;
		}else{
			if ($KO_condition{$element} eq 'exist'){ $color = 'gray'; }
			elsif ($KO_condition{$element} eq 'D_1vsall'){ $color = 'green'; }
			elsif ($KO_condition{$element} eq 'D_allvsall'){ $color = 'green,yellow'; }
			elsif ($KO_condition{$element} eq 'M_1vsall'){ $color = 'blue'; }
			elsif ($KO_condition{$element} eq 'M_allvsall'){ $color = 'blue,yellow'; }
			elsif ($KO_condition{$element} eq 'C_1vsall'){ $color = 'red'; }
			elsif ($KO_condition{$element} eq 'C_allvsall'){ $color = 'red,yellow'; }
			else{
				next;
			}
		}
		$path_string = $path_string. $element. '+'. $color. '%0d%0a';
	}
	#print $string, "\n";
	$path_string = 'https://www.kegg.jp/kegg-bin/show_pathway?map='. $_. '&multi_query='. $path_string;
	print $_, "\t", $path_string, "\n";
}
close(FH5);

