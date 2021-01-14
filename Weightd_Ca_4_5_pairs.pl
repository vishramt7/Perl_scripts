#!usr/bin/perl -w 
#This script will take the output of Contacts_AA_2_CA.pl (contacts_weight.txt) and obtain the contacts and weights from that file.
#The format for this file is: i j weight.
#The second input is the pairs section of the .top file from the SMOG output.
#The output will be in the same format of the pairs section with weights multiplied to C10 and C12.
##CAUTION: The numbering of residues in the contacts_weight.txt file and the pairs section file should be consistent. 


print ("Type the name of the file containing the pairs section\n");
$pairs=<STDIN>;
chomp ($pairs);

print ("type the file containing the contacts and their weights i j weight\n");
$weights=<STDIN>;
chomp ($weights);

open (PFILE,"$pairs") || die ("cannot open");
open (PAIRS,">weighted_pairs.txt")|| die ("cannot open");
open (EXCLU,">New_exclusions.txt") || die ("CANNOT OPEN EXCLUSIONS\n");
$COUNT=0;
$WCTEN=0;
$WCTWELVE=0;
while ($PAIRS=<PFILE>)
{
chomp ($PAIRS);
$COUNT++;
$PAIRS=~s/^\s+|\s+$//g;
@VALUES=split(/\s+/,$PAIRS);
$RESIDUE1=$VALUES[0];
$RESIDUE2=$VALUES[1];
$ONE=$VALUES[2];
$CTEN=$VALUES[3];
$CTWELVE=$VALUES[4];
$WLINE=`awk 'NR==$COUNT' $weights`;
chomp ($WLINE);
@SPLIT=split(/\s+/,$WLINE);
	if (($RESIDUE1==$SPLIT[0])&& ($RESIDUE2==$SPLIT[1]))
	{
	$WCTEN=$CTEN*$SPLIT[2];
	$WCTWELVE=$CTWELVE*$SPLIT[2];
	printf PAIRS ("%6d%7d%2d   %0.9E   %0.9E\n",$RESIDUE1,$RESIDUE2,$ONE,$WCTEN,$WCTWELVE);
	printf EXCLU ("%6d%7d\n",$RESIDUE1,$RESIDUE2);
	}	
	else
	{
	print ("WARNING:RESIDUE PAIR MISSING\n");
	}
}
close (PFILE);
close (PAIRS);
close (EXCLU);
