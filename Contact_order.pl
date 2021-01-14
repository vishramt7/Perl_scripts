#!usr/bin/perl -w 
#This script calculates the Absolute Contact Order as in Protein Science (2003), 12:2057–2062
#Inputs are 1.pairs section from .top file 2.*.gro file 
#Output: Absolute Contact Order , CA_CONT.txt

print "Type the pairs section from .top file\n";
$pairs=<STDIN>;
#$pairs="/home/user/Vishram/Scripts/IF3_Scaff_102/pairs_top.txt";
chomp ($pairs);

print "Type the .gro file\n";
$gro=<STDIN>;
#$gro="/home/user/Vishram/Scripts/IF3_Scaff_102/Scaff_cent.gro";
chomp ($gro);

print "Type the ouput file name\n";
$out=<STDIN>;
chomp ($out);

$last_line=`awk 'END {print FNR}' $gro`;
chomp ($last_line);
open (GRO,"$gro") || die ("CANNOT OPEN .gro\n");
$count=0;		# This counts the lines in the .gro file
while ($line=<GRO>)
{
chomp ($line);
$count++;
	if (($count>2) && ($count<$last_line)) 
	{	
	$Res_no=substr($line,0,5);
	$Res_no=~s/^\s+|\s+$//g;
	$Atom_no=substr($line,15,5);
	$Atom_no=~s/^\s+|\s+$//g;
	$MAP[$Atom_no]=$Res_no;
	}
}
close (GRO);

open (PAIRS,"$pairs") || die ("CANNOT OPEN .top\n");
open (CACONT,">CA_CONT.txt") || die ("CANNOT OPEN CA_CONT.txt\n");
open (OUTFILE,">$out") || die ("CANNOT OPEN OUTPUT\n");
$Cont_no=0;
$dL=0;
while ($contact=<PAIRS>)
{
$diffL=0;
chomp ($contact);
$Cont_no++;		# This counts the no. of contacts.
@SPLIT=split(" ",$contact);
$I=$SPLIT[0];
$J=$SPLIT[1];
$RESI=$MAP[$I];
$RESJ=$MAP[$J];
$diffL=abs($J-$I);	# This calculates difference from Atom no.	
print OUTFILE "$diffL\n";
$dL=$dL+$diffL;
	if ($RESJ>$RESI)
	{
	print CACONT "$RESI $RESJ\n";
	}
	else
	{
	print CACONT "$RESJ $RESI\n";
	}
}
close (PAIRS);
close (CACONT);

$ABS_CO=($dL/$Cont_no);
print "The Absolute CO is $ABS_CO\n";

=for comment;
open (CCONT,"CA_CONT.txt") || die ("CANNOT OPEN CA_CONT.txt\n");
$Calpha=0;
$delL=0;
while ($ca_cont=<CCONT>)
{
chomp ($ca_cont);
$diff=0;
@SPLIT1=split(" ",$ca_cont);
$CI=$SPLIT1[0];
$CJ=$SPLIT1[1];
$diff=abs($CJ-$CI);
	if (!defined($UNIQ[$CI][$CJ]))
	{
	$UNIQ[$CI][$CJ]=$diff;
	$delL=$delL+$diff;
	print OUTFILE "$diff\n";
	$Calpha++;
	}
}
close (CCONT);
$ABS_CO=($delL/$Calpha);

print "Total lines are $count Total contacts are $Cont_no Total Ca-contacts are $Calpha \n";
print "Absolute CO is $ABS_CO\n";
=cut;

close (OUTFILE);
undef @MAP;
undef @UNIQ;
`rm CA_CONT.txt`;
