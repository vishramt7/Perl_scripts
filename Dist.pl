#!usr/bin/perl -w
#This script will calculate distances for a given pair of atoms from a pdb file

#print "Enter the file containing the pairs\n";
#$pairs=<STDIN>;
$pairs=$ARGV[0];
chomp ($pairs);

#print "Enter the .pdb file\n";
#$pdb=<STDIN>;
$pdb=$ARGV[1];
chomp ($pdb);

open (PDB, $pdb) || die ("CANNOT OPEN .pdb FILE\n");
while ($line=<PDB>)
{
chomp ($line);
	if (substr($line,0,6) eq "ATOM  ")
	{
	$ATOM_NO=substr($line,6,5);
	$X[$ATOM_NO]=substr($line,30,8);
	$Y[$ATOM_NO]=substr($line,38,8);
	$Z[$ATOM_NO]=substr($line,46,8);
	}
}
close (PDB);

open (PAIRS, $pairs) || die ("CANNOT OPEN PAIRS FILE\n");
while ($pair=<PAIRS>)
{
chomp ($pair);
@VALUE=split (" ",$pair);
$i=$VALUE[1];
$j=$VALUE[3];
$dist=(sqrt((($X[$j]-$X[$i])**2)+(($Y[$j]-$Y[$i])**2)+(($Z[$j]-$Z[$i])**2)))*0.1;
$EXCL_VOL=$dist**12;	# Excluded volume in nm^12.
printf ("%d  %d  %0.9E  %0.9E\n",$i,$j,$dist,$EXCL_VOL);
}
close (PAIRS);
undef @X;
undef @Y;
undef @Z;
