#!usr/bin/perl -w
#This script will take .dat ouput of paths.sh and give averaged paths
#THE SCRIPT ASSUMES THAT TRANSITIONS ARE SORTED AS IN paths.sh

#print "Enter the .dat file from paths.sh\n";
#$dat=<STDIN>;
$dat=$ARGV[0];
chomp ($dat);

$outfile=$dat;
$outfile=~s/.dat/.xvg/g;

$minQ=0.1;
$maxQ=1.0;
$bins=15;

$bin_size=($maxQ-$minQ)/$bins;
for ($i=1;$i<=$bins;$i++)
{
$min=$minQ+(($i-1)*$bin_size);
$max=$minQ+($i*$bin_size);
$avg=($min+$max)/2;
$MAXQ[$i]=$max;
$AVGQ[$i]=$avg;
}

$sum=0;
$j=0;
$k=1;
open (INFILE,"$dat") || die ("CANNOT OPEN .dat\n");
open (OUTFILE, ">$outfile") || die ("CANNOT OPEN OUTPUT\n");
while ($DAT=<INFILE>)
{
chomp ($DAT);
        if ($DAT=~/^\&/)
        {
	print OUTFILE "&\n";
	$sum=0;
	$j=0;
	$k=1;
        $transition++;
        }
        else
        {
        @SPLIT=split(" ",$DAT);
	$Q=$SPLIT[0];
	$fraqQ=$SPLIT[1];
		if ($Q<=$MAXQ[$j+1])
		{
		$sum=$sum+$fraqQ;
		$k++;
		}
		else 
		{
		$average=$sum/$k;
		print OUTFILE "$AVGQ[$j+1] $average\n";
		$sum=$fraqQ;
		$k=1;
		$j++;	
		}
	}
}
print "The no. of transitions are $transition\n";
close (INFILE);
close (OUTFILE);
