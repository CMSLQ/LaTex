#!/usr/bin/perl

use strict;
use Shell;

my $numArgs = $#ARGV + 1;
if ( $numArgs != 1 ) {
    print "\n USAGE: " . "./makeLatexTables.pl  filename\n Example: ./makeLatexTables.pl data/output/analysisClass_tables.dat\n";
    print "\n Note: the name of the cut variables that have to be used for generating the efficiency tables\n";
    print "       should be inserted in the array \@cutVariables in the script, so please edit the script.\n\n";
    exit -1;
}

#my $file = "/home/prumerio/cms/phys/lq/rootNtupleAnalyzer_QCDBkgStudies/data/output_eejj_std/analysisClass_eejjSample_tables.dat";
my $file = $ARGV[0];

# Please insert in @cutVariables the names of the variables that you want to appear in the tables, and KEEP A SPACE at the end of each cut variable name
my @cutVariables = ("nocut ", "skim ","nEle_PtPreCut ", "nEle_PtPreCut_ID ", "nEle_PtPreCut_IDISO ", "Pt2ndEleIDISO ", "nJet_PtPreCut_DIS ", "Eta2ndJet_DIS ", "invMass_ee ", "sT "); 
my @cutDescriptions = ("None", "Skim", "2 ele \$P_T>20\~\$GeV", "2 ele (ID) \$P_T>20\~\$GeV", "2 ele (ID+Iso) \$P_T>20\~\$GeV", "2 ele (ID+Iso) \$P_T>30\~\$GeV", "2 jets (Cleaned) \$P_T>20\~\$GeV", "2 jets (Cleaned), \$P_T>50\~\$GeV, \$ \| \\eta \|<3\$", "\$M_\{ee\}>100\~\$GeV", "\$ S_T>620\~\$GeV "); 

my $caption="Sample of FIXME: Sequence of selection cuts with number of events selected in 100\$\~pb\^{-1}\$, efficiency relative to the preceeding cut and absolute efficiency.";


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
    my $tmp=("\\hline\\hline \n\\end{tabular} \n\\end{center} \n\\caption{$caption} \n\\label{tab:} \n\\end{table} \n\n");
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

my $firstVar = trim(@cutVariables[0]);
my $lastVar = trim(@cutVariables[@cutVariables-1]);
$firstVar =~ s/_//g; #remove underscores from names as latex interpretes them
$lastVar =~ s/_//g; #remove underscores from names as latex interpretes them

my @tableLines;
my $sizeOfTableLine;
my $Den=-1;
my $DenErr=-1;
my $Num=-1;
my $NumErr=-1;
my $effRel=-1;
my $effRelErr=-1;
foreach my $selectedLine (@selectedLines){
    my @tableLine=();
    my @t= split(/\s/, $selectedLine);
    $t[1] =~ s/_//g; #remove underscores from names as latex interpretes them 
    $Num=@t[6];
    $NumErr=@t[7];
    if ( ( $selectedLine =~ /$firstVar/) ) {
	$effRel=1;
	$effRelErr=0;
    } else {
	if ( $Den == 0 ){
	    $effRel=0;
	    $effRelErr=0;	    
	} else {
	    $effRel=$Num/$Den;
	    if ( $Num == 0 ){
		$effRelErr=sqrt(($DenErr/$Den)**2);		
	    } else {
		$effRelErr=sqrt(($NumErr/$Num)**2+($DenErr/$Den)**2);
	    }
	}
    }
    $Den=@t[6];
    $DenErr=@t[7];
    #my @tableLineEntries=(@t[1]," \& ", @t[6],"\$\~\\pm\~\$",@t[7]," \& ", @t[8],"\$\~\\pm\~\$",@t[9], " \& ", @t[10],"\$\~\\pm\~\$",@t[11], "\\\\");
    my @tableLineEntries=(@t[1]," \& ", sprintf("%.3e",@t[6]),"\$\~\\pm\~\$",sprintf("%.3e",@t[7])," \& ", sprintf("%.3e", $effRel),"\$\~\\pm\~\$",sprintf("%.3e",$effRelErr), " \& ", sprintf("%.3e",@t[10]),"\$\~\\pm\~\$",sprintf("%.3e",@t[11]), "\\\\");
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


my $posLastTableElement;
my $count=0;
my $metLastVar=0; #set to false
foreach my $tableLine (@tableLines){
    $count ++;
    if ( ( $tableLine =~ /$firstVar/) ) {
	print OUTFILE &tableHeader;
    }
    if ( ( $tableLine =~ /$lastVar/) ) {
	$posLastTableElement = $count+$sizeOfTableLine;
	$metLastVar=1;
    }

    my $cv;
    my $cd;
    my $nc=0;
    foreach my $cutVar (@cutVariables){
	my $cv=trim($cutVar);
	$cv =~ s/_//g; #remove underscores 
	my $cd=@cutDescriptions[$nc];
	$nc++;
	$tableLine = $tableLine . " ";
	$tableLine =~ s/$cv /$cd/g; # replace @cutVariables with proper descriptions from @cutDescriptions 
    }

    print OUTFILE $tableLine;

    if ( ( $tableLine =~ /.*\n/) && ( $metLastVar == 1 ) ) {
	print OUTFILE &tableTrailer;
	$metLastVar=0; #set to false
    }
}

#print &tableTrailer;
print OUTFILE &texFileTrailer;
close (OUTFILE); 

print "Efficiency tables have been written to file tmp.tex in current directory.\n";



