#!usr/bin/perl -w
#
#

$infile=$ARGV[0];
chomp ($infile);

$infile2=$ARGV[1];
chomp ($infile2);

open (INPUT,"$infile") || die ("CANNOT OPEN\n");
while ($inline=<INPUT>)
{
chomp ($inline);
#@SPLIT=split ("\_",$inline);
#$q1=$SPLIT[0];
#$q2=$SPLIT[1];
#$pe=$SPLIT[2];

#print "$q1\.$q2\_$pe\n";
#`cat UBQ_106_$q1\.$q2/$q1\.$q2\_$pe.pdb.Q >> L5.Q`;
#`cat UBQ_106_$q1\.$q2/$q1\.$q2\_$pe.pdb_intra.CA.Qi >> L5_intra.Qi`;
#`cat UBQ_106_$q1\.$q2/$q1\.$q2\_$pe.pdb_inter.CA.Qi >> L5_inter.Qi`;

@SPLIT=split (" ",$inline);
$i=$SPLIT[0];
$j=$SPLIT[1];
$f=$SPLIT[2];
	if ($i>=$j)	# This part takes diagonal and the lower part of the intra contact map 
	{
#	print "$i $j $f\n";
	$Fintra[$i][$j]=$f;
	}
	else
	{
#	print "$i $j 0\n";
	}
}
close (INPUT);

open (INPUT2,"$infile2") || die ("CANNOT OPEN\n");
while ($inline2=<INPUT2>)
{
chomp ($inline2);
@SPLIT2=split (" ",$inline2);
$i2=$SPLIT2[0];
$j2=$SPLIT2[1];
$f2=$SPLIT2[2];	
	if ($i2<$j2)     # This part takes the upper part of the inter contact map
	{
	$Finter[$i2][$j2]=$f2;
	}
}
close (INPUT2);

for ($x=1;$x<=76;$x++)
{		
	for ($y=1;$y<=76;$y++)
	{
		if ($x>=$y)	
		{		
		$MEAN_Fintra=($Fintra[$x][$y]+$Fintra[$x+76][$y+76])/2;
		print "$x $y $MEAN_Fintra\n";
		}
		else		
		{
		$MEAN_Finter=($Finter[$x][$y+76]+$Finter[$y][$x+76])/2;	
		print "$x $y $MEAN_Finter\n";
		}
	}
}
