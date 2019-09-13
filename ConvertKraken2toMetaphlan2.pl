#! /usr/bin/perl

use strict;
use warnings;
use File::Basename;
use Getopt::Long qw(GetOptions);
use Pod::Usage qw(pod2usage);
use Data::Dumper;
$Data::Dumper::Sortkeys = 1;

my $inputfile= shift @ARGV;
my $outputfile = shift @ARGV;

unless (defined $inputfile && defined $outputfile){
	print "\nPlease provide following files with FULL path: \n";
	print "         1) input file from Kraken2 output in mpa-report format\n";
	print "         1) converted file for OTU table \n";
	print "\n\nUsage: \n";
	print "         perl $0 /share/home/cheng/pipelines/Github/IlluminaPipeline/SE/accession_list_from_viral_megablast.fasta /share/home/cheng/pipelines/Github/IlluminaPipeline/SE/test.sortedbam.list /share/home/cheng/pipelines/Github/IlluminaPipeline/SE/Mapping_summary.txt 5\n\n";
        
	exit;
}

my (@species, @genus, @family, @order, @class, @phylum, @kingdom, @temp_array) = ();
my (%otu, %data, %species, %genus, %family, %order, %class, %phylum, %kingdom) = ();
my $header = "#SampleID\tMetaphlan2_Analysis";
#my ($species, $genus) = '';

open (FH1, "<$inputfile") or die $!;
while(<FH1>){

	chomp;
	my @array = split(/\t/);
	#if ($array[0] =~ /s__/){
	#	push (@species, $array[0]);
	#}
	#$data{$array[0]}{'input'} = $array[1];
	next unless /__Bacteria/; #include only bacteria
	$array[0] =~ s/d__/k__/;
	$array[0] =~ s/\s/_/g;
	if ($array[0] =~  /\|s/){
		$species{$array[0]} = $array[1];
	}
	else{
		if ($array[0] =~  /\|g/){
			$genus{$array[0]} = $array[1];
		}
		else{
			if ($array[0] =~  /\|f/){
				$family{$array[0]} = $array[1];
			}
			else{
				if ($array[0] =~  /\|o/){
					$order{$array[0]} = $array[1];
				}
				else{
					if ($array[0] =~  /\|c/){
						$class{$array[0]} = $array[1];
					}
					else{
						if ($array[0] =~  /\|p/){
							$phylum{$array[0]} = $array[1];
						}
						else{
							if ($array[0] =~  /d__/){
								$kingdom{$array[0]} = $array[1];
							}
						}
					}
				}
			}
		}
	}
}
close(FH1);
#print Dumper(\%kingdom), "\n";

foreach my $key1 (keys %kingdom){
	$otu{$key1} = $kingdom{$key1};
	foreach my $key2 (keys %phylum){
		if ($key2 =~ m/\Q$key1/){
			$otu{$key1} -= $phylum{$key2};
		}
	}
}

foreach my $key1 (keys %phylum){
	$otu{$key1} = $phylum{$key1};
	foreach my $key2 (keys %class){
		if ($key2 =~ m/\Q$key1/){
			$otu{$key1} -= $class{$key2};
		}
	}
}

foreach my $key1 (keys %class){
	$otu{$key1} = $class{$key1};
	foreach my $key2 (keys %order){
		if ($key2 =~ m/\Q$key1/){
			$otu{$key1} -= $order{$key2};
		}
	}
}

foreach my $key1 (keys %order){
	$otu{$key1} = $order{$key1};
	foreach my $key2 (keys %family){
		if ($key2 =~ m/\Q$key1/){
			$otu{$key1} -= $family{$key2};
		}
	}
}

foreach my $key1 (keys %family){
	$otu{$key1} = $family{$key1};
	foreach my $key2 (keys %genus){
		if ($key2 =~ m/\Q$key1/){
			$otu{$key1} -= $genus{$key2};
		}
	}
}


foreach my $key1 (keys %genus){
	$otu{$key1} = $genus{$key1};
	foreach my $key2 (keys %species){
		if ($key2 =~ m/\Q$key1/){
			$otu{$key1} -= $species{$key2};
		}
	}
}

foreach my $key1 (keys %species){
	$otu{$key1} = $species{$key1};
}

foreach my $key (keys %otu){
	if ($otu{$key} == 0){
		delete $otu{$key};
	}
}
#print Dumper(\%otu), "\n";

open (OFH, ">$outputfile") or die $!;
	print OFH $header, "\n";
	for my $key (sort {$a cmp $b} keys %otu){
		print OFH $key, "\t", $otu{$key}, "\n";
	}
close(OFH);





=pod
foreach my $element (@species){ my $temp = $element; $temp =~ s/(.*)\|s.*/$1/; push (@temp_array, $temp);}
@genus = uniq(@temp_array);
@temp_array = ();

foreach my $element (@genus){ my $temp = $element; $temp =~ s/(.*)\|g.*/$1/; push (@temp_array, $temp);}
@family = uniq(@temp_array);
@temp_array = ();

foreach my $element (@family){ my $temp = $element; $temp =~ s/(.*)\|f.*/$1/; push (@temp_array, $temp);}
@order = uniq(@temp_array);
@temp_array = ();

foreach my $element (@order){ my $temp = $element; $temp =~ s/(.*)\|o.*/$1/; push (@temp_array, $temp);}
@class = uniq(@temp_array);
@temp_array = ();

foreach my $element (@class){ my $temp = $element; $temp =~ s/(.*)\|c.*/$1/; push (@temp_array, $temp);}
@phylum = uniq(@temp_array);
@temp_array = ();

foreach my $element (@phylum){ my $temp = $element; $temp =~ s/(.*)\|p.*/$1/; push (@temp_array, $temp);}
@kingdom = uniq(@temp_array);
@temp_array = ();

print Dumper(\@phylum), "\n";

sub uniq {
    my %seen;
    grep !$seen{$_}++, @_;
}
=cut














__DATA__
d__Bacteria	22924
d__Bacteria|p__Bacteroidetes	16262
d__Bacteria|p__Bacteroidetes|c__Bacteroidia	16049
d__Bacteria|p__Bacteroidetes|c__Bacteroidia|o__Bacteroidales	16044
d__Bacteria|p__Bacteroidetes|c__Bacteroidia|o__Bacteroidales|f__Bacteroidaceae	13776
d__Bacteria|p__Bacteroidetes|c__Bacteroidia|o__Bacteroidales|f__Bacteroidaceae|g__Bacteroides	13776
d__Bacteria|p__Bacteroidetes|c__Bacteroidia|o__Bacteroidales|f__Bacteroidaceae|g__Bacteroides|s__Bacteroides vulgatus	6577
d__Bacteria|p__Bacteroidetes|c__Bacteroidia|o__Bacteroidales|f__Bacteroidaceae|g__Bacteroides|s__Bacteroides caccae	1741
d__Bacteria|p__Bacteroidetes|c__Bacteroidia|o__Bacteroidales|f__Bacteroidaceae|g__Bacteroides|s__Bacteroides thetaiotaomicron	886
d__Bacteria|p__Bacteroidetes|c__Bacteroidia|o__Bacteroidales|f__Bacteroidaceae|g__Bacteroides|s__Bacteroides cellulosilyticus	856
d__Bacteria|p__Bacteroidetes|c__Bacteroidia|o__Bacteroidales|f__Bacteroidaceae|g__Bacteroides|s__Bacteroides ovatus	766
d__Bacteria|p__Bacteroidetes|c__Bacteroidia|o__Bacteroidales|f__Bacteroidaceae|g__Bacteroides|s__Bacteroides fragilis	500
d__Bacteria|p__Bacteroidetes|c__Bacteroidia|o__Bacteroidales|f__Bacteroidaceae|g__Bacteroides|s__Bacteroides dorei	447 
d__Bacteria|p__Bacteroidetes|c__Bacteroidia|o__Bacteroidales|f__Bacteroidaceae|g__Bacteroides|s__Bacteroides caecimuris	439
d__Bacteria|p__Bacteroidetes|c__Bacteroidia|o__Bacteroidales|f__Bacteroidaceae|g__Bacteroides|s__Bacteroides helcogenes	301
d__Bacteria|p__Bacteroidetes|c__Bacteroidia|o__Bacteroidales|f__Bacteroidaceae|g__Bacteroides|s__Bacteroides heparinolyticus	179
d__Bacteria|p__Bacteroidetes|c__Bacteroidia|o__Bacteroidales|f__Bacteroidaceae|g__Bacteroides|s__Bacteroides zoogleoformans	127
d__Bacteria|p__Bacteroidetes|c__Bacteroidia|o__Bacteroidales|f__Bacteroidaceae|g__Bacteroides|s__Bacteroides salanitronis	78
d__Bacteria|p__Bacteroidetes|c__Bacteroidia|o__Bacteroidales|f__Bacteroidaceae|g__Bacteroides|s__Bacteroides coprosuis	10
d__Bacteria|p__Bacteroidetes|c__Flavobacteriia|o__Flavobacteriales|f__Flavobacteriaceae|g__Flavobacterium	9
d__Bacteria|p__Elusimicrobia|c__Elusimicrobia|o__Elusimicrobiales	1
d__Bacteria|p__Elusimicrobia|c__Elusimicrobia|o__Elusimicrobiales|f__Elusimicrobiaceae	1
d__Bacteria|p__Elusimicrobia|c__Elusimicrobia|o__Elusimicrobiales|f__Elusimicrobiaceae|g__Elusimicrobium	1
d__Bacteria|p__Elusimicrobia|c__Elusimicrobia|o__Elusimicrobiales|f__Elusimicrobiaceae|g__Elusimicrobium|s__Elusimicrobium minutum	1
d__Bacteria|p__Thermotogae	2
d__Bacteria|p__Thermotogae|c__Thermotogae	2
d__Bacteria|p__Thermotogae|c__Thermotogae|o__Thermotogales	2
d__Bacteria|p__Thermotogae|c__Thermotogae|o__Thermotogales|f__Fervidobacteriaceae	2
d__Bacteria|p__Thermotogae|c__Thermotogae|o__Thermotogales|f__Fervidobacteriaceae|g__Fervidobacterium	2
d__Bacteria|p__Thermotogae|c__Thermotogae|o__Thermotogales|f__Fervidobacteriaceae|g__Fervidobacterium|s__Fervidobacterium islandicum	1
d__Bacteria|p__Thermotogae|c__Thermotogae|o__Thermotogales|f__Fervidobacteriaceae|g__Fervidobacterium|s__Fervidobacterium nodosum	1
d__Bacteria|p__Thermodesulfobacteria	1
d__Bacteria|p__Thermodesulfobacteria|c__Thermodesulfobacteria	1
d__Bacteria|p__Thermodesulfobacteria|c__Thermodesulfobacteria|o__Thermodesulfobacteriales	1
d__Bacteria|p__Thermodesulfobacteria|c__Thermodesulfobacteria|o__Thermodesulfobacteriales|f__Thermodesulfobacteriaceae	1
d__Bacteria|p__Thermodesulfobacteria|c__Thermodesulfobacteria|o__Thermodesulfobacteriales|f__Thermodesulfobacteriaceae|g__Thermodesulfobacterium	1