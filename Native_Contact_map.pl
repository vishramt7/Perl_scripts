#! usr/bin/perl -w
# This script will take the contacts from the pairs section of the .top file as input.
# The output will be a matrix as needed for the matlab (input for the Contact_map.m script).

#print ("Type the name of the file containing the pairs section\n");
$infile=$ARGV[0];
chomp ($infile);

#print ("Type the number of residues in the protein\n");
$resno=$ARGV[1];
chomp ($resno);

#print ("Type the output file name\n");
$output=$ARGV[2];
chomp ($output);

open (CONT,"$infile") || die ("cannot open");
while ($line=<CONT>)
{
chomp ($line);
#print ("$line\n");
$line=~s/^\s+|\s+$//g;
@val=split(" ",$line);
$resi=$val[0];
$resj=$val[1];
$weight=$val[2]; # The weights can be added here. Default value is 1.
#$weight=1;
$WEIGHT[$resi][$resj]=$weight;

}
close (CONT);

open (OUTPUT,">$output") || die ("cannot open");
for ($i=1;$i<=$resno;$i++)
{
	for ($j=1;$j<=$resno;$j++)
	{
	$prob=0;
		if (defined ($WEIGHT[$i][$j]))
		{
		$prob=$WEIGHT[$i][$j];
		}
		elsif (defined ($WEIGHT[$j][$i]))
		{
		$prob=$WEIGHT[$j][$i];
		}
	print OUTPUT ("$i $j $prob\n");
	}
}
close (OUTPUT);
