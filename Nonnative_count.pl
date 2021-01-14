#!usr/bin/local/perl
# This script takes a distance.xvg file (output of g_bond command) and asks for a cutoff either 0.8 / 0.9 and gives the count of contacts formed
#at each time point.
# The output file is named as Count.txt

print ("Enter the output file name of g_dist\n");
$file=<STDIN>;
chomp ($file);
`egrep -v "#|@|&" $file > new.txt`;

print ("If Nonnative hydrophobic, enter 0.8, if Nonnative charged enter 0.9\n");
$cutoff=<STDIN>;
chomp ($cutoff);

open (INFILE, "new.txt")|| die ("cannot open");
open (OUTFILE, ">Count_$cutoff.txt")|| die ("cannot open");
@total=<INFILE>;
chomp (@total);

foreach $new (@total)
{
$count=0;
@array=split (/\d +/, $new);
#print ($array[0],"\n");
	for ($val=1; $val<=@array-1; $val++)
	{
		
		if ($array[$val]<=$cutoff)
		{
		$count++;
		}
	}
printf OUTFILE ("$count\n");
}

`rm new.txt`;

