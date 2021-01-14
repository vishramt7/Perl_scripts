#! usr/bin/perl
# This script will take the contacts file from CSU and the ./test2 of CSU to give all atom contacts between any pair of Calpha contacts.
##CAUTION: The numbering of residues in the contact file, in the pdb file and the pairs section file should be consistent. 

print ("Enter the contacts file given by CSU\n");
$Cacont=<STDIN>;
chomp ($Cacont);

print ("Enter the pdb name\n");
$pdb=<STDIN>;
chomp ($pdb);

$aatotal=0;
$Catotal=0;
open (CONT,"$Cacont")||die ("cannot open");
while ($line=<CONT>)
{
chomp ($line);
$line=~s/^\s+|\s+$//g;
#print ("$line\n");
@pair=split (/\s+/,$line);
$res1=$pair[0];
$res2=$pair[1];
#print ("This is the pair $res1 $res2\n");
`rm contacts`;
`./test2 $pdb $res1 > aainfo.txt`;
open (INFO,"aainfo.txt")|| die ("cannot open");
$lineno=1;
	while ($cont=<INFO>)
	{
	chomp ($cont);
		if (substr($cont,0,8) eq "Table IV")
		{
		$tab=$lineno;	
		}			
	$lineno++;
	}
close (INFO);

`awk 'NR>=$tab' aainfo.txt > tempo.txt`;
@atom_cont=`awk 'NR>7' tempo.txt | awk '{print \$4}'`;
chomp (@atom_cont);
$contact=0;
foreach $value(@atom_cont)
{
	if($value==$res2) 
	{
	$contact++;
	}
}
#print ("The atomic contacts of $res1 with $res2 are $contact\n");
`echo $res1 $res2 $contact >> cont.txt`;
`rm tempo.txt`;
`rm aainfo.txt`;
$aatotal=$aatotal+$contact;
$Catotal++;
}
close (CONT);
print ("The total all atom contacts are $aatotal and Calpha contacts are $Catotal\n");

open (CONTACTS,"cont.txt") or die ("cannot open");
open (OUTPUT,">weights.txt") or die ("cannot open");
while ($input=<CONTACTS>)
{
chomp ($input);
@LINE=split(/\s+/,$input);
$RES1=$LINE[0];
$RES2=$LINE[1];
$RES3=$LINE[2];
$WEIGHT=$RES3*($Catotal/$aatotal);
print OUTPUT ("$RES1 $RES2 $WEIGHT\n");
}
close (CONTACTS);
close (OUTPUT);
`rm contacts`;
`rm cont.txt`;

print ("Type the name of the file containing the pairs section\n");
$pairs=<STDIN>;
open (PFILE,"$pairs") || die ("cannot open");
open (PAIRS,">weighted_pairs.txt")|| die ("cannot open");
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
$WLINE=`awk 'NR==$COUNT' weights.txt`;
chomp ($WLINE);
@SPLIT=split(/\s+/,$WLINE);
	if (($RESIDUE1==$SPLIT[0])&& ($RESIDUE2==$SPLIT[1]))
	{
	$WCTEN=$CTEN*$SPLIT[2];
	$WCTWELVE=$CTWELVE*$SPLIT[2];
	printf PAIRS ("%6d%7d%2d   %0.9E   %0.9E\n",$RESIDUE1,$RESIDUE2,$ONE,$WCTEN,$WCTWELVE);
	}	
        else
        {
        print ("WARNING:RESIDUE PAIR MISSING\n");
        }
}
close (PFILE);
close (PAIRS);
