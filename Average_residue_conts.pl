#! usr/bin/perl -w 
#This script will calculate average contact formation for each residue
#The input is pcol file, contacts file and .pdb file

#print ("Type the name of the pairs file \n");
$infile=$ARGV[0];
chomp ($infile);

open (CONT,"$infile") || die ("cannot open\n");
$a=0;
$Total=0;
while ($line=<CONT>)
{
chomp ($line);
@val=split(" ",$line);
$resi=$val[0];
$resj=$val[1];
#	if ($resj>$resi)# This is to ensure that j>i	
	if ($resj>$resi+5)	# This ensures only the non-local contacts	
	{
	$RESI[$a]=$resi;		
	$RESJ[$a]=$resj;
	$RESW[$resi][$resj]=1;	
	$a++;
	}
#	else
#	{
#	$RESI[$a]=$resj;
#	$RESJ[$a]=$resi;
#	$RESW[$resj][$resi]=1;
#	print "WARNING : $resi $resj\n";	
#	last;
#	$a++;
#	}
$Total++;
}
close (CONT);
#print "Total contacts = $Total, Only tertiary contacts = $a\n";

#print ("Type the name of the Avg_pcol*.txt file \n");
$pcol=$ARGV[1];
chomp ($pcol);
$e=0;
open (PCOL,"$pcol") || die ("cannot open\n");
while ($pline=<PCOL>)
{
chomp ($pline);
@PVAL=split(" ",$pline);
$i=$PVAL[0];
$j=$PVAL[1];
$w=$PVAL[2];
#	if (($j>$i) && ($i<=120) && ($j<=120) && ($w>0))# This is only for intra contacts
#	if (($j>$i) && ($i<=120) && ($j>120) && ($w>0)) # This is only for inter contacts
	if (($j>$i) && ($w>0))				# This is to obtain all contacts	
	{
	$CONTI[$e]=$i;
	$CONTJ[$e]=$j;
	$CONT[$CONTI[$e]][$CONTJ[$e]]=$w;
	$e++;	
	}
}
close (PCOL);

# Count the no. of intra & inter contacts (both are equal in no.) for each residue
for ($b=1;$b<=120;$b++)
{
$c=0;
$WEIGHT=0;
$BFACTOR[$b]=0;
        for ($d=0;$d<$a;$d++)
        {
		if (($b==$RESI[$d]) || ($b==$RESJ[$d]))
		{
		$c++;
########################## This part is for intra contacts
			if (defined $CONT[$RESI[$d]][$RESJ[$d]])
			{
			$WEIGHT=$WEIGHT+$CONT[$RESI[$d]][$RESJ[$d]];		
#				if ($b==61)	# This condition is just for check !! 
#				{	
#				print "$RESI[$d] $RESJ[$d] $CONT[$RESI[$d]][$RESJ[$d]]\n";
#				}
			}
########################## 

######################### This part is for inter contacts		
	                if (defined $CONT[$RESI[$d]][$RESJ[$d]+120])
      		        {
	              	$WEIGHT=$WEIGHT+$CONT[$RESI[$d]][$RESJ[$d]+120];			
##				if ($b==93)	# This condition is just for check !! 
##				{				
##				$J=$RESJ[$d]+120;
##				print "$RESI[$d] $J $CONT[$RESI[$d]][$RESJ[$d]+120]\n";
##				}
			}
		}
##########################
        }
$CONTACTS[$b]=$c;
	if ($c>0)
	{
	$BFACTOR[$b]=($WEIGHT/$CONTACTS[$b]);
	}
}	

#=for comment;
#print ("Type the name of the pdb file \n");
$pdb=$ARGV[2];
chomp ($pdb);
open (PDB,"$pdb") || die ("cannot open\n");
while ($pdbline=<PDB>)
{
chomp ($pdbline);
        if (substr($pdbline,0,6) eq "ATOM  ")
        {	
	$RESIDUE_ID=substr($pdbline,22,4);
	$RESIDUE_ID=~s/^\s+|\s+$//g;
	$t=$BFACTOR[$RESIDUE_ID];
	$temp_fact=sprintf("%6.3f",$t);
	substr($pdbline,60,6,$temp_fact);
	print "$pdbline\n";
	}
}
close (PDB);
#=cut;
