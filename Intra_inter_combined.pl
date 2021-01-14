#!usr/bin/perl -w
#This script is going to take the output of temp.pl which has both intra and inter contact maps.
#The output will be a combined map.

$infile=$ARGV[0];
chomp ($infile);

open (INPUT,"$infile") || die ("CANNOT OPEN\n");
while ($inline=<INPUT>)
{
chomp ($inline);
@SPLIT=split (" ",$inline);
$i=$SPLIT[0];
$j=$SPLIT[1];
$f=$SPLIT[2];
$Freq[$i][$j]=$f;
}
close (INPUT);

for ($x=1;$x<=76;$x++)
{
        for ($y=1;$y<=76;$y++)
        {
		if ($Freq[$x][$y]>=$Freq[$y][$x])
		{
		$NEW_Freq=$Freq[$x][$y];
		}
		else
		{
		$NEW_Freq=$Freq[$y][$x];
		}
	print "$x $y $NEW_Freq\n";
        }
}
