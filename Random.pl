#!/usr/bin/perl -w
#This script will generate random nos for a peptide of length $Length

#print "This is a test\n";

$Length=17;
$count=0;
for ($x=1;$x<=$Length;$x++)
{
	while ($count<$Length)
	{
	$RNUM=&rand_gen;
	$random[$RNUM]++;
		if (($random[$RNUM]==1))
		{
		print "$x $RNUM\n";
		$count++;
		last;
		}
	}
}

sub rand_gen
{
use Math::Random::Secure qw(rand);
$num=int(rand($Length))+1;
$num;
}
