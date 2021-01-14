#!usr/bin/perl -w
#This script will take energy/Q file as input
#The output will be a complete transtion eg. A=>B=>A

#print "Type the name of E/.Q file\n";
$E_file=$ARGV[0];
#$E_file="energy.txt";
chomp ($E_file);

$A=1290;		# limit of Basin A
$B=870;			# limit of Basin B 
$Ecount=0;
$trans=0;
$line_no=0;
#$trans2=0;
$new_trans=1;

# This part will only get the start and end line nos of the transtions
open (INPUT,"$E_file") || die ("CANNOT OPEN\n");
while ($line=<INPUT>)
{
chomp ($line);
$Ecount++;
@SPLIT=split (" ",$line);
$energy=$SPLIT[0];

# This condition checks if it starts from basin A
	if (($B<$A) && ($energy>=$A))		 
	{
	$Start=$Ecount;
	}
        if (($B>$A) && ($energy<=$A))
        {
        $Start=$Ecount;
        }
# This condition checks if it visits basin B										
	if (($B<$A) && ($energy<=$B))				
	{
		if ((defined($Start)) && ($Ecount>$Start) && (!defined($Bstart_line[$trans])))
		{
		$Astart_line[$trans]=$Start;
		$Bstart_line[$trans]=$Ecount;	
		}
	}
        if (($B>$A) && ($energy>=$B))
        {
                if ((defined($Start)) && ($Ecount>$Start) && (!defined($Bstart_line[$trans])))
                {
		$Astart_line[$trans]=$Start;
                $Bstart_line[$trans]=$Ecount;
	        }
	}	
# This condition checks if it revists basin A
	if (($B<$A) && ($energy>=$A))
	{
		if ((defined($Bstart_line[$trans])) && ($Ecount>$Bstart_line[$trans]) && (!defined($Aend_line[$trans])))
		{	
		$Aend_line[$trans]=$Ecount;		
#		print "$Astart_line[$trans] $Bstart_line[$trans] $Aend_line[$trans]\n";
		$trans++;
		}	
	}
        if (($B>$A) && ($energy<=$A))
        {
                if ((defined($Bstart_line[$trans])) && ($Ecount>$Bstart_line[$trans]) && (!defined($Aend_line[$trans])))
                {
                $Aend_line[$trans]=$Ecount;
                $trans++;
                }
        }
}
close (INPUT);
print "$trans\n";

# Check 1: If each transition visits the B state
# Check 2: If all the transitions are continous 
# Print the complete transition frames / energy and the frame/energy of the B state entry.
# These conditions are satisfied in the above part of the code

for ($a=0;$a<$trans;$a++)
{
$line_no=0;
	open (INPUT2,"$E_file") || die ("CANNOT OPEN\n");
	while ($line2=<INPUT2>)
	{
	chomp ($line2);
	$line_no++;	
	@SPLIT2=split (" ",$line2);
	$E=$SPLIT2[0];
		if (($line_no==$Astart_line[$a]))
		{
		$b=0;
		}
		if (($line_no>=$Astart_line[$a]) && ($line_no<=$Aend_line[$a]))
		{
		$LINE[$b]=$line_no;
		$ENERGY[$b]=$E;
		$b++;
		}
		if ($line_no>$Aend_line[$a])
		{
		open (OUTPUT,">E_$new_trans.ndx") || die ("CANNOT OPEN\n");
		print OUTPUT "[ frames ]\n";
#		print OUTPUT join("\n",@ENERGY),"\n"; # This print the energy for complete transition		
#		print OUTPUT join("\n",@LINE),"\n";   # This prints the frames for complete transition
			for ($x=0;$x<$b;$x++)
			{
				if (($B<$A) && ($ENERGY[$x]<=$B))
				{
				print OUTPUT "$LINE[$x]\n";
				last;	
				}
				if (($B>$A) && ($ENERGY[$x]>=$B))
				{	
				print OUTPUT "$LINE[$x]\n";
				last;	
				}
			}
		close (OUTPUT);		
		undef @LINE;
		undef @ENERGY;
		$new_trans++;
		last;
		}
	}
}

=for comment
open (INPUT2,"$E_file") || die ("CANNOT OPEN FILE\n");
while ($line2=<INPUT2>)
{
chomp ($line2);
$line_no++;
@SPLIT2=split (" ",$line2);
$E=$SPLIT2[0];
# Get the line nos and the E values for all the transitions
        if (($line_no==$Astart_line[$trans2]))
        {
        $a=0;
        }
        if (($line_no>=$Astart_line[$trans2]) && ($line_no<=$Aend_line[$trans2]))
        {
        $LINE[$a]=$line_no;
        $ENERGY[$a]=$E;
        $a++;
        }
        if ($line_no==$Aend_line[$trans2])
        {
        $StateB=0;
#########################################################################################
#This part of the check is not needed but just an extra check
                for ($b=0;$b<$a;$b++)
                {
                        if ((defined($LINE[$b+1]))) 
                        {
			# This condition checks for continuity in the trajectory
                                if ($LINE[$b+1]==$LINE[$b]+1)   
                                {

                                }
                                else
                                {
				print "Traj $trans2 has a problem in line no. $LINE[$b+1]\n";
#                               undef @LINE;
#                               undef @ENERGY;
                                }
			}
			# This condition checks if the trajectory visits the state B
                        if ($LINE[$b]==$Bstart_line[$trans2])           
                        {       
                        $StateB=1;
#			print "This $LINE[$b] is the first line of state B\n";
                        }	
		}
#########################################################################################
$size_line=scalar(@LINE);
$size_energy=scalar(@ENERGY);
		if (($size_line>0) && ($size_energy>0) && ($StateB==1))
		{
#		open (OUTPUT,">frames_$new_trans.ndx") || die ("CANNOT OPEN\n");
#		print OUTPUT "[ frames ]\n";
#		print OUTPUT join("\n",@ENERGY),"\n"; # This print the energy for complete transition
#		print OUTPUT join("\n",@LINE),"\n";   # This prints the frames for complete transition
#		close (OUTPUT);
		$new_trans++;
		}	
	undef @LINE;
	undef @ENERGY;		
        $trans2++;
        }

        if ($trans2==$trans)
        {
        last;
        }
}
close (INPUT);
print "$trans2\n";
print "SECOND AND THIRD PARTS OF THE CODE CANNOT BE USED SIMULTANEOUSLY\n";
