#!usr/bin/perl -w
#This script will take energy file as input
#The output will be a complete transtion eg. U=>F=>U

#print "Type the name of .Q file\n";
$E_file=$ARGV[0];
#$E_file="energy.txt";
chomp ($E_file);

$Unfolded_E=300;	# Lower limit of Basin 1
$Folded_E=-40;		# Upperl limit of Basin 2 
$Ecount=0;
$a=0;
$c=0;
$e=0;
$trans=0;
$d=0;

open (INPUT,"$E_file") || die ("CANNOT OPEN\n");
while ($line=<INPUT>)
{
chomp ($line);
$Ecount++;
@SPLIT=split (" ",$line);
$energy=$SPLIT[0];

	if ($energy<$Unfolded_E)		# This condition takes all the values "<" Unfolded basin, 
	{
#	print "$energy $Ecount $FRAME[$energy]\n";
	$a++;		
	$LINE_NO[$a]=$Ecount;	
	$ENERGY[$a]=$energy;
	}

}
close (INPUT);

for ($b=1;$b<=$a;$b++)
{	
	if ((defined($LINE_NO[$b+1])) && (defined($ENERGY[$b+1])))
	{
		if ($LINE_NO[$b+1]==$LINE_NO[$b]+1)	# Check for continous stretches, which visit the desired state (FOLDED)
		{
#		print "$ENERGY[$b]\n";
#		print "$LINE_NO[$b]\n";	
		$FRAMES[$e]=$LINE_NO[$b];
		$ENER_VAL[$e]=$ENERGY[$b];
		$e++;		
		}
		else 
		{
#		print "&\n";				# This helps to separate stretch	
		$c++;
			for ($d=0;$d<=$e;$d++)		# This checks if it visits the desired state
			{
				if (defined($ENER_VAL[$d]) && ($ENER_VAL[$d]<=$Folded_E))				
				{
				$trans++;				
				open (OUTPUT,">TRANS_$trans.ndx") || die ("CANNOT OPEN\n");
				print OUTPUT "[ frames ]\n"; 				
#				print OUTPUT join("\n",@ENER_VAL),"\n"; 
				print OUTPUT "$FRAMES[$d]\n";				
				close (OUTPUT);
				last;
				}
			}
		undef @FRAMES;
		undef @ENER_VAL;
		$e=0;
		}
	}
}
print "$trans\n";
