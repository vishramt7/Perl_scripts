#!/usr/bin/perl -w
#This script will take .Q file as input and give trajectories going from MinimaA to MinimaB
#Two conditions are checked 1. The trajectory originates in Minima A and goes to Minima B 2. It does not re-enter Minima A
#These .Q files need two columns, X axis and Y axis

#print "Type the name of .Q file\n";
$Q_file=$ARGV[0];
#$Q_file="energy.txt";
chomp ($Q_file);

$Axmin=75;
$Axmax=100;
$Aymin=31;
$Aymax=44;

$Bxmin=0;
$Bxmax=50;
$Bymin=0;
$Bymax=10;

$Qline=0;
$a=0;
$e=0;
$trans=0;

open (INPUT,"$Q_file") || die ("CANNOT OPEN\n");
while ($line=<INPUT>)
{
chomp ($line);
$Qline++;
@SPLIT=split (" ",$line);
$Q1=$SPLIT[0];
$Q2=$SPLIT[1];
#	if (($Q1>=$Axmin) && ($Q2<=$Aymax))	# This condition takes all the values on the lower right side of basin A on a 2D plot 
	if (($Q1<=$Axmax) && ($Q2<=$Aymax))     # This condition takes all the values on lower left side of basin A on a 2D plot
	{
#	print "$Qline $line\n";
        $a++;
        $LINE_NO[$a]=$Qline;
        $Xval[$a]=$Q1;
	$Yval[$a]=$Q2;
	}
}
close (INPUT);
#print "Total lines are $a\n";

for ($b=1;$b<=$a;$b++)
{
	if ((defined($LINE_NO[$b+1])) && (defined($Xval[$b+1])) && (defined($Yval[$b+1])))
	{
		if ($LINE_NO[$b+1]==$LINE_NO[$b]+1)     # Check for continous stretches
		{
		$FRAMES[$e]=$LINE_NO[$b];
		$X1val[$e]=$Xval[$b];
		$Y1val[$e]=$Yval[$b];		
		$e++;
		}
		else
		{
		$Start=0;
		$Start_frame=0;
		$End=0;
		$End_frame=0;
			for ($d=0;$d<$e;$d++)		# Here $d goes from 0 to < $e, since $e is incremented after
			{
				if (($X1val[$d]>=$Axmin) && ($X1val[$d]<=$Axmax) && ($Y1val[$d]>=$Aymin) && ($Y1val[$d]<=$Aymax))   # Condition 1. Starts in MinimaA
				{
				$Start++;
				$Start_frame=$d;	# This takes the last point in the Minima A as the start frame 	
				}					
#				if ((($X1val[$d]>=$Axmax) && ($Y1val[$d]<=$Aymax)) || (($X1val[$d]<=$Axmax) && ($Y1val[$d]<=$Aymin)))# This condition checks for re-entry into basin A	
				if (($X1val[$d]>=$Bxmin) && ($X1val[$d]<=$Bxmax) && ($Y1val[$d]>=$Bymin) && ($Y1val[$d]<=$Bymax))# This checks for entry into basin B 
				{
#				print "$X1val[$d] $Y1val[$d]\n";
				$End++;
				$End_frame=$d; 		# This takes the first point in the Minima B as the end frame
				last;
				}
			}		
			if ($End>1)
			{
			print "WARNING:Something wrong with Minima B definition\n";	
			}		
			if (($Start>0) && ($End>0) && ($Start_frame<$End_frame))	# This is to confirm the trajectory goes from A=>B
			{
			$trans++;	
#			open (OUTPUT,">IN_$trans.ndx") || die ("CANNOT OPEN\n");
#			open (OUTPUT1,">IN_$trans.Q") || die ("CANNOT OPEN\n");
#			print OUTPUT "[ frames ]\n";
				for ($f=$Start_frame;$f<=$End_frame;$f++)		# This loop prints the entire trajectory
				{
#				print OUTPUT1 "$X1val[$f] $Y1val[$f]\n";			# This prints the Q values
#				print OUTPUT "$FRAMES[$f]\n";				# This prints the frame no.		
				}	
#			close (OUTPUT);	
#			close (OUTPUT1);
			}
		undef @FRAMES;
		undef @X1val;
		undef @Y1val;	
		$e=0;		
		}
	}
}
print "$trans\n";
