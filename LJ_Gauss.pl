#!usr/bin/perl -w
#This script will take LJ pairs and provide Gaussian pairs as input for GROMACS with Gaussian function for AA 

#print "Enter the LJ pairs\n";
$LJ_pairs=$ARGV[0];
#$LJ_pairs="/home/user/Vishram/MD/Go_/All_atom/Go_1SHF_AA/1SHF_Gaussian/pairs_LJ.dat";
chomp ($LJ_pairs);

#print "Enter the total no. of atoms\n";
$atoms=$ARGV[1];
chomp ($atoms);

#print "Enter the total no of contacts\n";
$contacts=$ARGV[2];
chomp ($contacts);

#The value of A (depth of well) can also be obtained from total contacts and atoms as described in Proteins,2009,75:430
#All contacts have the same value of A.
$A=($atoms*2)/($contacts*3);

$ftype_Gauss=6;
open (INFILE, $LJ_pairs) || die ("CANNOT OPEN INFILE\n");
while ($LINE=<INFILE>)
{
chomp ($LINE);
@VALUES=split (" ",$LINE);
$i=$VALUES[0];
#$i=27;
$j=$VALUES[1];
$ftype=$VALUES[2];
$C6=$VALUES[3];
$C12=$VALUES[4];
#printf ("%6d%7d%2d   %0.9E   %0.9E\n",$i,$j,$ftype,$C6,$C12);

$Mu=(($C12*2)/$C6)**(1/6); 	# This gives the contact distance in nm;
#$A=($C12/($Mu**12));		# This gives the depth of LJ and for the Gaussian;
$Sigma=($Mu*0.2)/((2*log(2))**(1/2));	# This gives the width of the Gaussian;
$Gauss_EX_VOL=0.01*(0.25**12);
$LJ_EX_VOL=$Mu**12;
#printf ("%6d%7d%2d   %0.9E   %0.9E   %0.9E   %0.9E\n",$i,$j,$ftype_Gauss,$A,$Mu,$Sigma,$Gauss_EX_VOL);
printf ("%6d%7d%2d   %0.9E   %0.9E   %0.9E   %0.9E\n",$i,$j,$ftype_Gauss,$A,$Mu,$Sigma,$LJ_EX_VOL);
}
close (INFILE);
