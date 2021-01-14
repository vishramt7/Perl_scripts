#!usr/bin/perl -w 
#This script will take the .tml file from VMD, Timeline as input.
#The output will be % of residues in Turn (T), Extended Configuration (E), Isolated Bridge (B), 
#Alpha Helix (H), 3-10 Helix (G), Pi-helix (I), Coil (C)
#The script will not read beyond "#" symbol

print "Type the .tml file name\n";
$infile=<STDIN>;
#$infile="temp.tml";
chomp ($infile);

print "Type the output file name\n";
$output=<STDIN>;
chomp ($output);

open (TML,"$infile") || die ("CANNOT OPEN THE .tml FILE\n");
open (OUTPUT,">$output") || die ("CANNOT OPEN OUTPUT\n");
$Total=0;
$Check=0;
$FRAMES=0;
$Helix_count=0;
$T=0; # Turn;
$E=0; # Extended Configuration
$B=0; # Isolated Bridge
$H=0; # Alpha Helix
$G=0; # 3-10 Helix
$I=0; # Pi-Helix
$C=0; # Coil
while ($line=<TML>)
{
chomp ($line);
@LINE=split(' ',$line);
$Res_no=$LINE[0];
$frame=$LINE[3];
$SS=$LINE[4];
		if ($Res_no eq "#")
		{
		print "Its a comment\n";
		}	
		else
		{		
		$Total++;
			if ($SS eq "T")
			{
			$T++;	
			}
			elsif ($SS eq "E")
			{
			$E++;
			}
			elsif ($SS eq "B")
			{	
			$B++;	
			}
			elsif ($SS eq "H")
			{
			$H++;
			}
			elsif ($SS eq "G")
			{
			$G++;
			}
			elsif ($SS eq "I")
			{
			$I++;
			}
			elsif ($SS eq "C")
			{
			$C++;
			}
			else 
			{
			print "NOT A VALID SS\n";
			}
			
			if (!defined ($UNIQ[$frame]))
			{
			$UNIQ[$frame]=$FRAMES;
			$FRAMES++;
			}
			
			if (!defined ($HEL[$frame]))
			{			
				if (($SS eq "H") || ($SS eq "G") || ($SS eq "I"))
				{
				$HEL[$frame]=$Helix_count;
				$Helix_count++;
				}
			}
		}
}
$Check=$T+$E+$B+$H+$G+$I+$C;
	if ($Check!=$Total)
	{
	print "SS is not calculated properly\n";
	}
$Turn=sprintf ("%.4f",(($T/$Check)*100));
$Extended=sprintf ("%.4f",(($E/$Check)*100));
$Bridge=sprintf ("%.4f",(($B/$Check)*100));
$A_helix=sprintf ("%.4f",(($H/$Check)*100));
$Three_ten_helix=sprintf ("%.4f",(($G/$Check)*100));
$Pi_helix=sprintf ("%.4f",(($I/$Check)*100));
$Coil=sprintf ("%.4f",(($C/$Check)*100));

$HELICAL_PERCENT=sprintf ("%.4f",(($Helix_count/$FRAMES)*100));

print OUTPUT "% of Turn T = $Turn\n% of Extended Configuration E = $Extended\n% of Isolated Bridge B = $Bridge\n";
print OUTPUT "% of Alpha_Helix H = $A_helix\n% of 3-10 Helix G = $Three_ten_helix\n% of Pi-helix I = $Pi_helix\n% of Coil C = $Coil\n";
print OUTPUT ("% of frames having helix formation = $HELICAL_PERCENT\n");
print ("Total frames are $FRAMES\n");

print "The total no. of residues with assigned structure $Total\n";
close (TML);
close (OUTPUT);
undef @UNIQ;
undef @HEL;
