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
	if ($resj>$resi)# This is to ensure that j>i	
	{
	$RESI[$a]=$resi;		
	$RESJ[$a]=$resj;
	$RESW[$resi][$resj]=1;	
	$a++;
	}
	else
	{
	$RESI[$a]=$resj;
	$RESJ[$a]=$resi;
	$RESW[$resj][$resi]=1;
	print "WARNING : $resi $resj\n";	
	last;
	$a++;
	}
$Total++;
}
close (CONT);
print "Total contacts = $Total, Only tertiary contacts = $a\n";

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

#=for comment;
# Count the no. of intra & inter contacts (both are equal in no.) for each residue
        for ($d=0;$d<$a;$d++)
        {
	$WEIGHT=0;
	$intra=0;
	$inter=0;
########################## This part is for intra contacts
			if (defined $CONT[$RESI[$d]][$RESJ[$d]])
			{
			$WEIGHT=$WEIGHT+$CONT[$RESI[$d]][$RESJ[$d]];
			$intra=$CONT[$RESI[$d]][$RESJ[$d]];
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
			$inter=$CONT[$RESI[$d]][$RESJ[$d]+120];
##				if ($b==93)	# This condition is just for check !! 
##				{				
##				$J=$RESJ[$d]+120;
##				print "$RESI[$d] $J $CONT[$RESI[$d]][$RESJ[$d]+120]\n";
##				}
			}
#########################
#	print "$RESI[$d] $RESJ[$d] $WEIGHT\n";
	$TOTALWEIGHT[$RESI[$d]][$RESJ[$d]]=$WEIGHT;	
		if ($intra>$inter)
		{
		$COL[$RESI[$d]][$RESJ[$d]]=0.5; # intra
		}
		elsif ($intra<$inter)
		{
		$COL[$RESI[$d]][$RESJ[$d]]=1.0; # inter 
		}
		else 
		{
		$COL[$RESI[$d]][$RESJ[$d]]=0.2; # equal
		}
        }

#=for comment;
$output=$ARGV[2];
chomp ($output);
open (OUTPUT,">$output") || die ("cannot open");
for ($x=1;$x<=120;$x++)
{
        for ($y=1;$y<=120;$y++)
        {
        $prob=0;
                if (defined ($TOTALWEIGHT[$x][$y]))
                {
		$prob=$COL[$x][$y];
                }
	        if (defined ($TOTALWEIGHT[$y][$x]))
		{
		$prob=$TOTALWEIGHT[$y][$x];
		}
        print OUTPUT ("$x $y $prob\n");
        }
}
close (OUTPUT);
=cut;
