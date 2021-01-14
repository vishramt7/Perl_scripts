#!usr/bin/perl -w 
#This script will extract the transitions given the boundaries.

$INFILE=$ARGV[0];
chomp ($INFILE);

$a=0;
$b=0;
open (INPUT,"$INFILE") || die ("CANNOT OPEN INFILE\n");
while ($line=<INPUT>)
{
chomp ($line);
@PAIRS=split(" ",$line);
$a++;
$TOTAL_Q=$PAIRS[2];
	if ($TOTAL_Q==186) # This is 0.4 Q 
	{
	$LINE_NO[$b]=$a;
	$b++;
	}	
}
close (INPUT);
print "Total no. of structures are $b\n";

$c=int($b/20); # This is to get the interval;

open (FRAMES,">Q_04.ndx") || die ("CANNOT OPEN FRAMES \n");
print FRAMES "[ frames ]\n";	
	for ($x=0;$x<$b;$x=$x+$c)
	{
	print FRAMES "$LINE_NO[$x]\n";	
	}
close (FRAMES);	
`echo 1 | trjconv -f Output.xtc -s ../2H2Z_CA_cent.pdb -fr Q_04.ndx -o Q_04_frame.pdb -sep`;
