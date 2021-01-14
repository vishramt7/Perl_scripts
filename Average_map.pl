#! usr/bin/perl -w 
#This script will print contacts and their average value for chain A and B 
#

#print ("Type the name of the pcol file \n");
$infile=$ARGV[0];
chomp ($infile);

open (CONT,"$infile") || die ("cannot open\n");
open (OUTPUT,">Avg_$infile") || die ("CANNOT OPEN\n");
$a=0;
while ($line=<CONT>)
{
chomp ($line);
@val=split(" ",$line);
$resi=$val[0];
$resj=$val[1];
$weight=$val[2]; # The weights can be added here. Default value is 1.
	if (($resj>$resi) && ($resi<=240) && ($resj<=240))# This condition is to get only the contacts above the diagonal
	{
	$RESI[$a]=$resi;
	$RESJ[$a]=$resj;
	$RESW[$resi][$resj]=$weight;	
	$a++;
	}
}
close (CONT);
print "$a\n";

# Use a condition such that it will NOT print only if both are > 120

$b=0;
$d=0;
$e=0;	
for ($c=0;$c<$a;$c++)
{
	if (($RESI[$c]<=120) && ($RESJ[$c]<=120))# This condition gives intraA contacts
	{
	$d++;
	$ChBI=$RESI[$c]+120;
	$ChBJ=$RESJ[$c]+120;
	$ChBW=$RESW[$ChBI][$ChBJ];		# This condition gives intraB contacts
	$AvgW=($RESW[$RESI[$c]][$RESJ[$c]]+$ChBW)/2;	
#	print "$RESI[$c] $RESJ[$c] $RESW[$RESI[$c]][$RESJ[$c]] $ChBI $ChBJ $ChBW $AvgW\n";
	print OUTPUT "$RESI[$c] $RESJ[$c] $AvgW\n";
	}
	elsif (($RESJ[$c]>240) && ($RESW[$RESI[$c]][$RESJ[$c]]>0))
	{
	print "WARNING:$RESJ[$c]\n";		
	}
	elsif (($RESI[$c]<=120) && ($RESJ[$c]>=120))	# This condition gives inter A-B contacts
	{
	$b++;
	$ChBI=$RESJ[$c]-120;	
	$ChBJ=$RESI[$c]+120;
	$ChBW=$RESW[$ChBI][$ChBJ];
		if (!defined ($CHECK[$ChBI][$ChBJ]) && !defined ($CHECK[$RESI[$c]][$RESJ[$c]]))
		{
		$e++;	
		$AvgW=($RESW[$RESI[$c]][$RESJ[$c]]+$ChBW)/2;
#		print "$RESI[$c] $RESJ[$c] $RESW[$RESI[$c]][$RESJ[$c]] $ChBI $ChBJ $ChBW $AvgW\n";      
		print OUTPUT "$RESI[$c] $RESJ[$c] $AvgW\n";
		$CHECK[$ChBI][$ChBJ]=1;
		$CHECK[$RESI[$c]][$RESJ[$c]]=1;		
		}			
		else
		{
		$CHECK[$ChBI][$ChBJ]++;
		$CHECK[$RESI[$c]][$RESJ[$c]]++;
		}
	}
}
print "$d $b $e\n";
close (OUTPUT);
