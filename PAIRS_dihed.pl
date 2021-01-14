#!usr/bin/perl -w
#This script is to arrange the pairs section

$pairs=$ARGV[0];
chomp ($pairs);

open (PFILE,"$pairs") || die ("cannot open");
$COUNT=0;
while ($PAIRS=<PFILE>)
{
chomp ($PAIRS);
$COUNT++;

$RESIDUE1=substr($PAIRS,0,6);
$RESIDUE2=substr($PAIRS,7,6);
$RESIDUE3=substr($PAIRS,14,6);
$RESIDUE4=substr($PAIRS,21,6);

$ONE=substr($PAIRS,28,1);
$ANGLE=substr($PAIRS,30,17);
$K=substr($PAIRS,48,17);
$MULTI=substr($PAIRS,66,1);

	if ((($RESIDUE3>=13) && ($RESIDUE2<=14)) || (($RESIDUE3>=26) && ($RESIDUE2<=30)) || (($RESIDUE3>=49) && ($RESIDUE2<=51)) || (($RESIDUE3>=66) && ($RESIDUE2<=67)) || (($RESIDUE3>=71) && ($RESIDUE2<=74)))
	{	
	$NEW_K=$K*0.5; # This reduces the strength of dihedrals by 1/2.
	$MODI_K=sprintf ("%17.9E",$NEW_K);
	}
	else
	{	
	$NEW_K=$K;
	$MODI_K=$NEW_K;
	}
		$i=$RESIDUE1;
		$j=$RESIDUE2;
		$k=$RESIDUE3;
		$l=$RESIDUE4;	

		$I=sprintf("%6d",$i);	
		$J=sprintf("%6d",$j);
		$K=sprintf("%6d",$k);
		$L=sprintf("%6d",$l);

#		if ($ONE==1)
#		{
#		$MULTI=substr($PAIRS,66,1);	
		print ("$I $J $K $L $ONE $ANGLE $MODI_K $MULTI\n");
#		printf ("%6d %6d %6d %6d %1d   %0.9E   %0.9E %1d\n",$I,$J,$K,$L,$ONE,$CTEN,$NEW_CTWELVE,$MULTI);
#		}
#		else 
#		{
#		print ("$I $J $ONE $CTEN $CTWELVE\n");
#		}
#		print ("$I $J\n");		
}
close (PFILE);
