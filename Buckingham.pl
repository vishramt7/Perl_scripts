#!usr/bin/perl -w 
# This script will write the values for Buckingham potential.

$A=10000;
$B=4.08;
$C=150;
$dr=0.002;
$length=20;
$Max_value=$length/$dr;
print "$Max_value\n";
open (POT,">Buckingham.txt") || die ("CANNOT OPEN\n");
for ($a=0;$a<=$Max_value;$a++)
{
$r=$a*0.002;
	if ($r>=0.004)
	{
#	$Rep=0.908/(($r)**12);	
	$Rep=$A*exp(-$B*$r);
	$VDW=$C/(($r)**6);
	$BUCK=($Rep-$VDW);
	print POT "$r $BUCK\n";
	}
}
close (POT);

