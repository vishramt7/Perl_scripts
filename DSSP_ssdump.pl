#!usr/bin/perl -w
#This script will take input from do_dssp -ssdump *.dat file and provide the % of secondary structure formed.
#Coil (C ~), Alpha-helix (H),3-10 helix (G), Pi-helix (I)
#Turn (T), Beta-bridge (B), Extended strand/Strand (E).
#Bend (S)

print "Type the output from the do_dssp -ssdump \n";
$infile=<STDIN>;
chomp ($infile);

print "Type the output file name\n";
$output=<STDIN>;
chomp ($output);

open (DAT,"$infile") || die ("CANNOT OPEN .dat FILE\n");
open (OUTPUT,">$output") || die ("CANNOT OPEN OUTPUT \n");
$Total=0; # Total no. of frames.
$Check=0;
$C=0; # Coil
$T=0; # Turn;
$E=0; # Extended Configuration/Strand
$B=0; # Isolated Beta-Bridge
$H=0; # Alpha Helix
$G=0; # 3-10 Helix
$I=0; # Pi-Helix
$S=0; # Bend
$Helix_count=0; # Helix containing frames
while ($line=<DAT>)
{
chomp ($line);
	if ($line=~/[[:digit:]]/)
	{
	$Residues=$line;
	print "No of residues are $line\n";
	}
	else 
	{
	@LINE=split (//,$line);
		foreach $element(@LINE)
		{
			if ($element eq "~")	
			{
			$C++;
			}
			elsif ($element eq "T")
			{
			$T++;
			}
			elsif ($element eq "E")
			{
			$E++;
			}
			elsif ($element eq "B")
			{
			$B++;
			}
			elsif ($element eq "H")
			{
			$H++;
			}
			elsif ($element eq "G")
			{
			$G++;
			}	
			elsif ($element eq "I")	
			{
			$I++;
			}
			elsif ($element eq "S")
			{
			$S++;
			}
			else
			{
			print "NOT A VALID SS\n";
			}
		}	
		foreach $ele(@LINE)
		{					
			if (($ele eq "G") || ($ele eq "H") || ($ele eq "I"))
			{		
			$Helix_count++;
			last;
			}
		}
	$Total++;
	}
}
$Check=$C+$T+$E+$B+$H+$G+$I+$S;
        if ($Check!=$Total*$Residues)
        {
        print "$Check $Total SS is not calculated properly\n";
        }
$Coil=sprintf ("%.4f",(($C/$Check)*100));
$Turn=sprintf ("%.4f",(($T/$Check)*100));
$Strand=sprintf ("%.4f",(($E/$Check)*100));
$Bridge=sprintf ("%.4f",(($B/$Check)*100));
$A_Helix=sprintf ("%.4f",(($H/$Check)*100));
$Three_ten_helix=sprintf ("%.4f",(($G/$Check)*100));
$Pi_helix=sprintf ("%.4f",(($I/$Check)*100));
$Bend=sprintf ("%.4f",(($S/$Check)*100));

$HELICAL_PERCENT=sprintf ("%.4f",(($Helix_count/$Total)*100));

print OUTPUT ("% of Turn T = $Turn\n% of Extended Configuration E = $Strand\n% of Isolated Bridge B = $Bridge\n");
print OUTPUT ("% of Alpha_Helix H = $A_Helix\n% of 3-10 Helix G = $Three_ten_helix\n% of Pi-helix I = $Pi_helix\n");
print OUTPUT ("% of Coil C = $Coil\n% of Bend S = $Bend\n");
print OUTPUT ("% of frames having helix formation = $HELICAL_PERCENT\n");

close (DAT);
close (OUTPUT);
