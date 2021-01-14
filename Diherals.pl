#!usr/bin/perl -w 
#This script will change the strength of improper dihedrals.
#Input 1. dihedrals section 2. .gro file . #It will ask for the multiplication factor.
#Output dihedrals file with the changed epsilon.

print "Give the file containing the dihedrals section\n";
$dihed=<STDIN>;
#$dihed="/home/user/Desktop/2CI2_32_36_BB_CB/dihedrals.txt";
chomp ($dihed);

print "Output file name\n";
$dihed_out=<STDIN>;
#$dihed_out="/home/user/Desktop/2CI2_32_36_BB_CB/tempo.txt";

print "Type the strength for impropers eg. 1/2/3\n";
$strength=<STDIN>;
chomp ($strength);

print "Type the name of the .gro file\n";
$gro_file=<STDIN>;
#$gro_file="/home/user/Desktop/2CI2_32_36_BB_CB/2CI2_32_36_BB_CB.14263.pdb.gro";
chomp ($gro_file);
open (GROIN,"$gro_file") || die ("CANNOT OPEN .gro FILE\n");
@gro_fi=<GROIN>;
chomp(@gro_fi);
close (GROIN);
undef @Cbeta;
foreach $value(@gro_fi)
{
$atom_name=substr($value,10,5);
$atom_name=~s/^\s+|\s+$//g;
$atom_no=substr($value,15,5);
$atom_no=~s/^\s+|\s+$//g;
	if (($atom_name eq CB))
	{
	push (@Cbeta,$atom_no);
	}
}
print "@Cbeta\n";

open (INFILE,$dihed) || die ("CANNOT OPEN\n");
open (OUTFILE,">$dihed_out") || die ("CANNOT OPEN\n");
while ($line=<INFILE>)
{
chomp ($line);
@ANGLES=split(" ",$line);
$Ai=$ANGLES[0];
$Aj=$ANGLES[1];
$Ak=$ANGLES[2];
$Al=$ANGLES[3];
$func=$ANGLES[4];
$phi=$ANGLES[5];
$Kd=$ANGLES[6];
$mult=$ANGLES[7];
	if ($func==1) # functn 1= proper dihedrals; functn 2 = Improper and planar dihedrals(harmonic)
	{
	$newKd=$Kd*$strength;
#	printf OUTFILE ("%6d%7d%7d%7d%2d%18.9E%18.9E\n",$Ai,$Aj,$Ak,$Al,$func,$phi,$newKd);
		if (grep(/^$Ai$/,@Cbeta) || grep(/^$Al$/,@Cbeta)) #This condition will change only the C-beta containing propers/impropers.
		{
		printf OUTFILE ("%6d%7d%7d%7d%2d%18.9E%18.9E%2d\n",$Ai,$Aj,$Ak,$Al,$func,$phi,$newKd,$mult);
		}
		else
		{
		print OUTFILE ("$line\n");
		}
	}
	else 
	{
	print OUTFILE "$line\n";
	}	
}
close (INFILE);
close (OUTFILE);
