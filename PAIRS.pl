#!usr/bin/perl -w
#This script is to arrange the pairs section

$pairs=$ARGV[0];
chomp ($pairs);

$PDB=$ARGV[1];
chomp ($PDB);

open (PDBFI,"$PDB") || die ("CANNOT OPEN PDB\n");
while ($inpdb=<PDBFI>)
{
chomp ($inpdb);
        if (substr($inpdb,0,6) eq "ATOM  ")
        {
	$ATOMNO=substr($inpdb,6,5);
        $ATOMNO=~s/^\s+|\s+$//g;
        $RESNO=substr($inpdb,22,4);
        $RESNO=~s/^\s+|\s+$//g;
	
	$MAP[$ATOMNO]=$RESNO;
	
	}
}
close (PDBFI);

open (PFILE,"$pairs") || die ("cannot open");
$COUNT=0;
while ($PAIRS=<PFILE>)
{
chomp ($PAIRS);
$COUNT++;
@VALUES=split(" ",$PAIRS);
$RESIDUE1=$VALUES[0];
$RESIDUE2=$VALUES[1];
$ONE=$VALUES[2];
$CTEN=$VALUES[3];
$CTWELVE=$VALUES[4];
#	if (($RESIDUE1>784) && ($RESIDUE2<=784))
#	{
#		if ($RESIDUE1<$RESIDUE2)
#		{	
#		printf ("%6d%7d%2d   %0.9E   %0.9E\n",$RESIDUE1,$RESIDUE2,$ONE,$CTEN,$CTWELVE);
#		$RES1=$RESIDUE1;
#		$RES2=$RESIDUE2-784;
#			if ($MAP[$RES2]>$MAP[$RES1]+3)
#			{		
#			printf ("%6d%7d%2d   %0.9E   %0.9E\n",$RES1,$RES2,$ONE,$CTEN,$CTWELVE);		
			printf ("%6d%7d\n",$RESIDUE1,$RESIDUE2);			
#			print "$PAIRS\n";		
#			}
#		}
#		else
#		{
#		printf ("%6d%7d%2d   %0.9E   %0.9E\n",$RESIDUE2,$RESIDUE1,$ONE,$CTEN,$CTWELVE);
#		}
#	}
}
close (PFILE);
