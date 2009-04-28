#!/usr/bin/perl

use strict;
use Shell;

my $numArgs = $#ARGV + 1;
if ( $numArgs != 1 ) {
    die(" USAGE: " . "./makeLatexTables.pl  filename\n Example: ./makeLatexTables.pl data/output/analysisClass_tables.dat\n");

}

my $file = "/home/prumerio/cms/phys/lq/rootNtupleAnalyzer_QCDBkgStudies/data/output_eejj_std/analysisClass_eejjSample_tables.dat";
my @cutVariables = ("nocut ", "skim ", "nEle_PtPreCut_ID "); # please KEEP A SPACE at the end of each cut variable name

sub texFileHeader {
    my $tmp=("\\documentclass{cmspaper} \n\\begin{document} \n\n");
    return $tmp;
}

sub tableHeader {
#    my $tmp=("\\begin{table}[htbp] \n\\begin{center} \n\\begin{tabular}{|c|c|c|c|} \n\\hline\\hline \n\& \$N_{ev}\$ \$100pb^{-1}\$ \& \$N_{ev}\$ & \$\\varepsilon\$ \\\\ \n\\hline\\hline \n\n");
    my $tmp=("\\begin{table}[htbp] \n\\begin{center} \n\\begin{tabular}{|c|c|c|c|} \n\\hline\\hline \n Cut \& \$N_{evt}\$ passed for \$100pb^{-1}\$ \& \$\\varepsilon_{rel}\$ \& \$\\varepsilon_{abs}\$ \\\\ \n\\hline\\hline \n");
    return $tmp;
}

sub tableTrailer {
    my $tmp=("\\hline\\hline \n\\end{tabular} \n\\end{center} \n\\caption{} \n\\label{tab:} \n\\end{table} \n\n");
    return $tmp;
}

sub texFileTrailer {
    my $tmp=("\\end{document} \n\n");
    return $tmp;
}

# Perl trim function to remove whitespace from the start and end of the string
sub trim($)
{
    my $string = shift;
    $string =~ s/^\s+//;
    $string =~ s/\s+$//;
    return $string;
}

open(DAT, $file) || die("Could not open file!");
my @lines=<DAT>;
#print @lines[1];
close(DAT);

my @selectedLines;

foreach my $line (@lines){
    foreach my $cutVariable (@cutVariables) {
	if ( ($line =~ /$cutVariable/) ) {
	    $line=" " . $line;
	    $line =~ s/\s+/ /g;
	    $line=$line . "\n";
	    push(@selectedLines, $line);
	}
    }
}
#print @selectedLines;

my @tableLines;
my $sizeOfTableLine;
foreach my $selectedLine (@selectedLines){
    my @tableLine=();
    my @t= split(/\s/, $selectedLine);
    $t[1] =~ s/_//g; #remove underscores from names as latex interpretes them 
    my @tableLineEntries=(@t[1]," \& ", @t[6],"\$\\pm\$",@t[7]," \& ", @t[8],"\$\\pm\$",@t[9], " \& ", @t[10],"\$\\pm\$",@t[11], "\\\\");
    $sizeOfTableLine = @tableLineEntries;
    foreach my $tableLineEntry (@tableLineEntries){
	push(@tableLine, $tableLineEntry);
	#push(@tableLine, "\&");
    }
    push(@tableLine, "\n");
#    push(@tableLine, "\n");
    @tableLines=(@tableLines, @tableLine);
} 


open (OUTFILE, '> tmp.tex');

print OUTFILE &texFileHeader;

my $firstVar = trim(@cutVariables[0]);
my $lastVar = trim(@cutVariables[@cutVariables-1]);
$firstVar =~ s/_//g; #remove underscores from names as latex interpretes them
$lastVar =~ s/_//g; #remove underscores from names as latex interpretes them


my $posLastTableElement;
my $count=0;
my $metLastVar=0; #set to false
foreach my $tableLine (@tableLines){
    $count ++;
    if ( ( $tableLine =~ /$firstVar/) ) {
	print OUTFILE &tableHeader;
    }
    print OUTFILE $tableLine;
    if ( ( $tableLine =~ /$lastVar/) ) {
	$posLastTableElement = $count+$sizeOfTableLine;
	$metLastVar=1;
    }
    if ( ( $tableLine =~ /.*\n/) && ( $metLastVar == 1 ) ) {
	print OUTFILE &tableTrailer;
	$metLastVar=0; #set to false
    }
}

#print &tableTrailer;
print OUTFILE &texFileTrailer;

close (OUTFILE); 




