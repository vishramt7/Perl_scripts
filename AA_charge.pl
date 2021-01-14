#!usr/bin/perl -w 
#This script will take AA pairs_top file and give distance and epsilon.

$PDB=$ARGV[0];
chomp ($PDB);

$CONTFILE=$ARGV[1];
chomp ($CONTFILE);

open (PDBFI,"$PDB") || die ("CANNOT OPEN PDB\n");
while ($inpdb=<PDBFI>)
{
chomp ($inpdb);
	if (substr($inpdb,0,6) eq "ATOM  ")
	{
	$RES=substr($inpdb,17,3);
		if (($RES eq "ARG") || ($RES eq "LYS") || ($RES eq "ASP") || ($RES eq "GLU"))
		{
		$ANAME=substr($inpdb,12,4);
		$ANAME=~s/^\s+|\s+$//g;		
			if (($ANAME eq "NH1") || ($ANAME eq "NZ") || ($ANAME eq "OE1") || ($ANAME eq "OD1")) #Only ARG has NH1, LYS has NZ, only GLU has OE2 , ASP has OD2
			{
			$ATOMNO=substr($inpdb,6,5);
			$ATOMNO=~s/^\s+|\s+$//g;
			$RESNO=substr($inpdb,22,4);	
			$RESNO=~s/^\s+|\s+$//g;
			$MAP[$ATOMNO]=$RESNO;
			$RESIDUE[$ATOMNO]=$RES;
			}
		}
	}
}
close (PDBFI);

open (CONTFI,"$CONTFILE") || die ("CANNOT OPEN CONTFILE \n");
while ($line=<CONTFI>)
{
chomp ($line);
@VALUES=split(" ",$line);
$I=$VALUES[0];
$J=$VALUES[1];
$C6=$VALUES[2];
$C12=$VALUES[3];
$R=((2*$C12)/$C6)**(1/6);
$R12=$R**12;
$E=$C12/$R12;
	if ((defined ($MAP[$I])) && (defined ($MAP[$J])))
	{
	print "$RESIDUE[$I] $MAP[$I] $RESIDUE[$J] $MAP[$J] $I $J dist $R strength $E\n";
	}
	else 
	{
	print "\n"; 
	}
}
close (CONTFI);
