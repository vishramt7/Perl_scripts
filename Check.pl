#!usr/bin/perl -w 
#

$infile=$ARGV[0];
$X_cutoff=$ARGV[1];
$Y_cutoff=$ARGV[2];
$file_to_scan=$ARGV[3];
chomp ($infile);
chomp ($X_cutoff);
chomp ($Y_cutoff);

$X_min=$X_cutoff-0.1;
$a=0;
$transition=0;		####-------Numbering of transitions starts from 0. Since xmgrace numbers them from 0-----######
open (INFILE,"$infile") || die ("CANNOT OPEN INFILE\n");
while ($LINE=<INFILE>)
{
chomp ($LINE);
	if ($LINE=~/^\&/)
	{	
	$transition++;
	}
	else 
	{
	@SPLIT=split(" ",$LINE);
	$X=$SPLIT[0];
	$Y=$SPLIT[1];	
		if (($X>=0.57) && ($X<=0.7) && ($Y<=0.2))
		{	
			if (!defined($VALUES[$transition]))
			{
			$VALUES[$transition]++;
			$UNIQ[$a]=$transition;
			$frames=$transition+1;
			print "$frames ";
			$a++;
			}
			else
			{
			$VALUES[$transition]++;
			}
		}
	}
}	
print "Total number of transitions are $transition\n";
print "Total transitions in selected criteria are $a\n";
close (INFILE);

$transit=0;
$b=0;
open (INFILE,"$file_to_scan") || die ("CANNOT OPEN INFILE\n");
open (OUTFILE,">$infile\_Cutoff.dat") || die ("CANNOT OPEN OUTFILE");
print OUTFILE "# INPUT:$infile , X-RANGE: $X_min-$X_cutoff, Y-RANGE: >=$Y_cutoff, OUTPUT:$infile\_Cutoff.dat\n";
while ($LINE=<INFILE>)
{
chomp ($LINE);
        if ($LINE=~/^\&/)
        {
        $transit++;
        }
	if ($transit==$UNIQ[$b])	
	{
		if ($LINE=~/^\&/)
		{
		}
		else
		{
		print OUTFILE "$LINE\n";
		}
	}	        
        if ($transit>$UNIQ[$b])
        {
	print OUTFILE "&\n";
        $b++;
	}
	if ($b==$a)
	{
	last;
	}
}
close (INFILE);
close (OUTFILE);
