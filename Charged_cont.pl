#!usr/bin/perl -w
#This script will take two inputs 
#1. Contacts file
#2. .pdb file
# PROVIDE THE CONTACTS FILE AND THE .pdb FILE WHICH WERE SUBMITTED TO SMOG SERVER.
#The ouput will be contacts between charged residues.

print "Enter the .pdb file\n";
$pdb=<STDIN>;
#$pdb="/run/media/user/Transcend/Vishram/Ubiquitin/1UBQ_4_5/1UBQ_SMOG.pdb";
chomp ($pdb);

print "Enter the contacts file\n";
$cont=<STDIN>;
#$cont="/run/media/user/Transcend/Vishram/Ubiquitin/1UBQ_4_5/contacts.txt";
chomp ($cont);

open (PDB,"$pdb") || die ("CANNOT OPEN .gro FILE\n");
while ($LINE=<PDB>)
{
chomp ($LINE);
	if (substr($LINE,0,6) eq "ATOM  ")
	{
	$RES=substr($LINE,17,3);
	$resno=substr($LINE,22,4);
	$resno=~s/^\s+|\s+$//g;
		if (($RES eq "ARG") || ($RES eq "HIS") || ($RES eq "LYS") || ($RES eq "ASP") || ($RES eq "GLU"))
		{	
		$CHARGED[$resno]=1;	
		}
		else
		{
		$CHARGED[$resno]=0;
		}	
	}
}
close (PDB);

open (CONT,"$cont") || die ("CANNOT OPEN CONTACTS FILE\n");
while ($line=<CONT>)
{
chomp ($line);
@CONTACTS=split (" ",$line);
$I=$CONTACTS[1];
$J=$CONTACTS[3];
	if (($CHARGED[$I]==1) && ($CHARGED[$J]==1))
	{
	print "$line\n";
	}	
}
close (CONT);
