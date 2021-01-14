#!usr/bin/perl -w
# This script will take the pairs section from the AA .top file of SMOG output and it will take the .pdb from SMOG output as input.
# The output will be C-alpha contacts and their weights.
# The numbering of the contacts will be based on the .pdb file. This .pdb file and the contacts file produced can then be used as input to SMOG again.

print ("type the name of the .txt file containing the pairs section from AA .top file\n");
$TOP=<STDIN>;
chomp ($TOP);
open (TOP,"$TOP") || die (".top file not found\n");

print ("Type the name of the .gro file from the SMOG output\n");
$pdb=<STDIN>;
chomp ($pdb);
open (PDB,"$pdb") || die ("cannot open the .pdb file\n");

$pdbcount=0;
while ($inpdb=<PDB>)
{
chomp ($inpdb);
#	if (substr($inpdb,0,6) eq "ATOM  ")
#	{
	$atomno=substr($inpdb,15,5);
	$atomno=~s/^\s+|\s+$//g;
	$resino=substr($inpdb,0,5);
	$resino=~s/^\s+|\s+$//g;

	$MAP[$atomno]=$resino;
	$pdbcount++;
#	}
}
print ("total no of atoms in the pdb are $pdbcount\n");
close (PDB);

open (MAPD,">MAP.txt") || die ("CANNOT OPEN MAPPED\n");
$AAcont=0;
while ($intop=<TOP>)
{
chomp ($intop);
@line=split(" ",$intop);
	print MAPD "$MAP[$line[0]] $MAP[$line[1]]\n"; 
        $AAcont++;
}
print ("Total AA contacts are $AAcont\n");
close (TOP);
undef @MAP;
close (MAPD);
