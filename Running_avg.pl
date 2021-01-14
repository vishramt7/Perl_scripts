#!/usr/bin/perl -w
# This script calculates runnning averages from .xvg files of GROMACS.
# The usage is perl Running_avg.pl input.xvg Length_of_average output_file

$INFILE=$ARGV[0];
chomp($INFILE);

$AVG=$ARGV[1];
chomp($AVG);

$OUT=$ARGV[2];
chomp($OUT);

`egrep -v "@|#|&" $INFILE > parsd_infile.dat`;

$a=0;
$line=0;
open(FILE,"parsd_infile.dat") or die "parsed file missing";
open(OUTFILE,">$OUT") or die "parsed file missing";
while(<FILE>){
     	$LINE=$_;
       	chomp($LINE);
	
	$line++;
	@SPLIT=split (" ",$LINE);
	$Time[$line]=$SPLIT[0];
	$Energy[$line]=$SPLIT[1];	

        if($line-$a==$AVG)
	{
	$a++;
	$SUM_t=0;
	$SUM_E=0;
		if ($a==1)
		{		
			for ($x=$a;$x<=$line;$x++)
			{	      
			$SUM_t=$SUM_t+$Time[$x];	        
			$SUM_E=$SUM_E+$Energy[$x];
			}
	       	$AVG_t[$a]=$SUM_t/$AVG;
		$AVG_E[$a]=$SUM_E/$AVG;
		}
		elsif ($a>1)
		{
		$AVG_t[$a]=$AVG_t[$a-1]+(($Time[$line]-$Time[$line-$AVG])/$AVG);
		$AVG_E[$a]=$AVG_E[$a-1]+(($Energy[$line]-$Energy[$line-$AVG])/$AVG);
		}
	print OUTFILE "$AVG_t[$a] $AVG_E[$a]\n";
#	undef ($Time[$a]);
#	undef ($Energy[$a]);
        }
}
close FILE;
close OUTFILE;
`rm parsd_infile.dat`;
