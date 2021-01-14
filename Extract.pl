#!usr/bin/perl -w 
#This script will extract the transitions given the boundaries.

$INFILE=$ARGV[0];
chomp ($INFILE);

$a=0;
open (INPUT,"$INFILE") || die ("CANNOT OPEN INFILE\n");
while ($line=<INPUT>)
{
chomp ($line);
@PAIRS=split(" ",$line);
$a++;
$START=$PAIRS[0];
$END=$PAIRS[1];
	open (FRAMES,">frames_$a.ndx") || die ("CANNOT OPEN FRAMES \n");
	{
	print FRAMES "[ frames ]\n";
		for ($i=$START;$i<=$END;$i++)
		{		
		print FRAMES "$i\n";
		}
	}	
`echo 0 | trjconv -f Output.xtc -s Output.tpr -fr frames_$a.ndx -o T_$a.xtc `;	
}
close (INPUT);
