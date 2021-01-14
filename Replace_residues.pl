#!/usr/bin/perl -w
#This script will replace residues in the given pairs section as per the input
#The inputs are i. File with residues and their replacement
#		ii.Pairs section 


$INFILE=$ARGV[0];
chomp ($INFILE);
open(INPUT,"$INFILE") || die "CANNOT OPEN INFILE\n";
while ($LINE=<INPUT>)
{
chomp ($LINE);	
@SPLIT=split(" ",$LINE);
$RES=$SPLIT[0];
$REPLACED_RES=$SPLIT[1];
$NEW_VALUES[$RES]=$REPLACED_RES;
#print "$RES $NEW_VALUES[$RES]\n";
}
close (INPUT);


$INFILE2=$ARGV[1];
chomp ($INFILE2);
open(PFILE,"$INFILE2") || die "CANNOT OPEN INFILE\n";
while ($PAIRS=<PFILE>)
{
chomp ($PAIRS);
$RESIDUE1=substr($PAIRS,0,6);
$RESIDUE2=substr($PAIRS,7,6);

$RESIDUE1=~s/^\s+|\s+$//g;
$RESIDUE2=~s/^\s+|\s+$//g;

	if (defined ($NEW_VALUES[$RESIDUE1]))
	{
	$i=$NEW_VALUES[$RESIDUE1];
	}
	else
	{
	$i=$RESIDUE1;
	}

	if (defined ($NEW_VALUES[$RESIDUE2]))
	{
	$j=$NEW_VALUES[$RESIDUE2];
	}
	else
	{
	$j=$RESIDUE2;
	}

	if ((!defined ($NEW_VALUES[$RESIDUE1])) && (!defined ($NEW_VALUES[$RESIDUE2])))
	{
	print "WARNING: NEITHER I OR J COULD BE MATCHED\n";
	}

$ONE=substr($PAIRS,14,1);       # These are for pairs section
$CTEN=substr($PAIRS,16,17);     # These are for pairs section
$CTWELVE=substr($PAIRS,34,17);  # These are for pairs section

$I=sprintf("%6d",$i);
$J=sprintf("%6d",$j);

#print ("$I $J $ONE $CTEN $CTWELVE\n");
print ("$I $J\n");
}
close (PAIRS);
