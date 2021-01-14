#!usr/bin/perl
# This script will take the pairs section from the AA .top file of SMOG output and it will take the .pdb from SMOG output as input.
# The output will be C-alpha contacts and their weights.
# The numbering of the contacts will be based on the .pdb file. This .pdb file and the contacts file produced can then be used as input to SMOG again.

print ("type the name of the .txt file containing the pairs section from AA .top file\n");
$TOP=<STDIN>;
chomp ($TOP);
open (TOP,"$TOP") || die (".top file not found\n");

print ("Type the name of the .pdb file from the SMOG output\n");
$pdb=<STDIN>;
chomp ($pdb);
open (PDB,"$pdb") || die ("cannot open the .pdb file\n");

$AAcont=0;
undef @allcont;
while ($intop=<TOP>)
{
chomp ($intop);
$intop=~s/^\s+|\s+$//g;
@line=split(/\s+/,$intop);
	if ($line[0]=~/[[:digit:]]/)
	{
	push (@allcont,"$line[0] $line[1]");
	$AAcont++;
	}
	else
	{
	print ("LINE HAS NO NUMERIC VALUES\n");
	}
#print ("$intop\n");
}
print ("Total AA contacts are $AAcont\n");
close (TOP);

$pdbcount=0;
undef @mapped;
while ($inpdb=<PDB>)
{
chomp ($inpdb);
	if (substr($inpdb,0,6) eq "ATOM  ")
	{
	$atomno=substr($inpdb,6,5);
	$atomno=~s/^\s+|\s+$//g;
	$resino=substr($inpdb,22,4);
	$resino=~s/^\s+|\s+$//g;
#	print ("$atomno\n");
		foreach $pair(@allcont)	
		{
		@val=split(/\s+/,$pair);
		$atom1=$val[0];
		$atom2=$val[1];
			if ($atomno==$atom1)
			{
			push (@mapped,"$atom1 $resino");
			}
			elsif ($atomno==$atom2)
			{
			push (@mapped,"$atom2 $resino");
			}
		}
	$pdbcount++;
	}
#print ("$inpdb\n");
}
print ("total no of atoms in the pdb are $pdbcount\n");
close (PDB);

undef @mapped_pairs;
foreach $pairline(@allcont)
{
$resival1=0;
$resival2=0;
@VAL=split(/\s+/,$pairline);
$ATOM1=$VAL[0];
$ATOM2=$VAL[1];
	foreach $element(@mapped)
	{
	@ELEMENT=split (/\s+/,$element);
	$ATOMNO1=$ELEMENT[0];
	$RESNO=$ELEMENT[1];
		if ($ATOM1==$ATOMNO1)
		{
		$resival1=$RESNO;
		}
		elsif ($ATOM2==$ATOMNO1)
		{
		$resival2=$RESNO;
		}
	}	
#print ("$ATOM1 $ATOM2 $resival1 $resival2\n");
push (@mapped_pairs,"$resival1 $resival2"); 
}
@sortd_pairs=sort{$a<=>$b}@mapped_pairs;

open (TEMPO,">tempo.txt")|| die ("cannot open output\n");
foreach $sort(@sortd_pairs)
{
print TEMPO ("$sort\n");
}
$tot_aa_cont=scalar(@sortd_pairs);
print ("Total sorted AA contacts are $tot_aa_cont\n");
close (TEMPO);

`cat tempo.txt | sort -n | uniq -c > tempo2.txt`;
`awk '{print 1,\$2,1,\$3}' tempo2.txt > contacts.txt`; 
$total=`awk '{sum+=\$1} END {print sum}' tempo2.txt`;
chomp ($total);
print "Total all atom contacts are $total\n";
$ca_contacts=`awk 'END{print FNR}' contacts.txt`;
chomp ($ca_contacts);
print ("Total C-alpha contacts are $ca_contacts\n");
$weight=($ca_contacts/$total);
`awk '{print \$2,\$3,\$1*$weight}' tempo2.txt > contacts_weight.txt`;
$conf_weight=`awk '{sum+=\$3} END {print sum}' contacts_weight.txt`;
chomp ($conf_weight);
print ("The addition of weights is $conf_weight\n");

`rm tempo.txt`;
`rm tempo2.txt`; 
