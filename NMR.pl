#!/usr/bin/perl -w

$pdb=$ARGV[0];
chomp ($pdb);

open(PDB,"$pdb") or die "pdb file missing somehow";
while(<PDB>){
	$LINE=$_;
	chomp($LINE);

	if(substr($LINE,0,5) eq "MODEL")
	{
	$MODEL=(substr($LINE,12,2));	
	$MODEL=~s/^\s+|\s+$//g;
	print "$MODEL\n";
	open (OUTPUT,">2PNI_model$MODEL.pdb") || die ("CANNOT OPEN PDB FILE\n");	
	print OUTPUT "$LINE\n";
	}	

	if ((substr($LINE,0,4)) eq "ATOM")
	{
	print OUTPUT  "$LINE\n";
	}

	if (substr($LINE,0,6) eq "ENDMDL")
	{
	print OUTPUT "END\n";
	close (OUTPUT);
	}
}
