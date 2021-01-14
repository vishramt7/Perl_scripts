#!usr/bin/perl -w 
#This script will take a pdb file as input.
#The output will be contacts based on a Cutoff value. The format for output will be i j dist(A).

print "Enter the .pdb file\n";
$pdb=<STDIN>;
#$pdb="/data1/Molecular_Simulations/Project/1AYI/1AYI_AA.15200.pdb.sb/1AYI_AA.15200.pdb";
chomp ($pdb);

print "Enter the output file name\n";
$output=<STDIN>;
#$output="/data1/Molecular_Simulations/Project/1AYI/1AYI_AA.15200.pdb.sb/temp.txt";
chomp ($output);

$Cutoff=4.5;	# The default value is 4.5 A.
$DIFF=3;	# j>i+3 

open (PDB,"$pdb") || die ("CANNOT OPEN .pdb file\n");
open (OUTPUT,">$output") || die ("CANNOT OPEN OUTPUT FILE\n");
$line=0;
while ($input=<PDB>)
{
chomp ($input);
$ATOM=substr($input,0,6);
$ATOM=~s/^\s+|\s+$//g;
	if ($ATOM eq "ATOM")
	{
	$line++;
	$atom_no=substr($input,6,5);
	$resi_no=substr($input,22,4);
	$x=substr($input,30,8);	
	$y=substr($input,38,8);
	$z=substr($input,46,8);
	
	$atom_no=~s/^\s+|\s+$//g;
	$resi_no=~s/^\s+|\s+$//g;
	$x=~s/^\s+|\s+$//g;
	$y=~s/^\s+|\s+$//g;
	$z=~s/^\s+|\s+$//g;

	$ATOM_NO[$line]=$atom_no;
	$RESI_NO[$line]=$resi_no;
	$X[$line]=$x;
	$Y[$line]=$y;
	$Z[$line]=$z;

	$MAP[$atom_no]=$resi_no;	
	}
}
close (PDB);
for ($a=1;$a<=$line;$a++)
{	
	for ($b=1;$b<=$line;$b++)
	{
	$diff=abs($RESI_NO[$b]-$RESI_NO[$a]);
		if ($diff>$DIFF)
		{
		$R=sqrt((($X[$b]-$X[$a])**2)+(($Y[$b]-$Y[$a])**2)+(($Z[$b]-$Z[$a])**2));	
			if ($R<=$Cutoff)			
			{
				if ($ATOM_NO[$b]>$ATOM_NO[$a])
				{
				$PAIR[$ATOM_NO[$a]][$ATOM_NO[$b]]=$R;
				}
				else
				{
				$PAIR[$ATOM_NO[$b]][$ATOM_NO[$a]]=$R;
				}	
			}
		}
	}
}
for ($x=1;$x<=$line;$x++)
{
	for ($y=1;$y<=$line;$y++)
	{
		if (defined($PAIR[$ATOM_NO[$x]][$ATOM_NO[$y]]))
		{	
#		print OUTPUT "$ATOM_NO[$x] $ATOM_NO[$y] $PAIR[$ATOM_NO[$x]][$ATOM_NO[$y]]\n"; # This line gives AA contacts and distance;
		$I=$MAP[$ATOM_NO[$x]];
		$J=$MAP[$ATOM_NO[$y]];		
			if (defined($CA[$I][$J]))
			{	
			$CA[$I][$J]++;
			}
			else
			{
			print OUTPUT "1 $I 1 $J\n"; # This line gives CA contacts which are unsorted;
			$CA[$I][$J]=1;	
			}
		}
	}
}

$l=$RESI_NO[1];
$m=$RESI_NO[$line];
for ($c=$l;$c<=$m;$c++)
{
	for ($d=$l;$d<=$m;$d++)
	{
		if (defined($CA[$c][$d]))	
		{
#		print OUTPUT "1 $c 1 $d\n";
		}
	}
}
close (OUTPUT);
