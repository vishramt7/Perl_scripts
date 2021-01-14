#!usr/bin/perl -w
#This script will take HILLS file from Metadynamics as input and will provide the free energy profile.

print "Enter the HILLS file\n";
$infile=<STDIN>;
chomp ($infile);

print "Enter the ouput file\n";
$outfile=<STDIN>;
chomp ($outfile);

print "Enter the number of bins\n";
$CV_BIN=<STDIN>;
chomp ($CV_BIN);

$cut_off=sqrt(2*6.25);                  #################----KernelFunctions.cpp-----##################
$x=0;
open (INFILE, "$infile") || die ("CANNOT OPEN THE HILLS FILE\n");
open (OUTFILE, ">$outfile") || die ("CANNOT OPEN THE OUTPUT\n");
while ($HILLS=<INFILE>)
{
chomp ($HILLS);
	if ($HILLS=~/^\#/)
	{
	}
	else
	{	
	@LINE=split (" ",$HILLS);
#	$TIME[$x]=$LINE[0];
	$CV1[$x]=$LINE[1];	
	$SIGMA=$LINE[2];	# SIGMA is constant throughout.
	$HEIGHT[$x]=$LINE[3];
#	$BIAS[$x]=$LINE[4];
	$x++;		
	}	
}
close (INFILE);

@SortedCV1=sort{$a<=>$b}@CV1;
$size=scalar(@SortedCV1);
$MIN_CV1=$SortedCV1[0]-($cut_off*$SIGMA);
$MAX_CV1=$SortedCV1[$size-1]+($cut_off*$SIGMA);
#$GRID_SPACING=(1.76*$SIGMA)/5;		############------This value was obtained from the fes.dat files-----############
$BIN_SIZE=($MAX_CV1-$MIN_CV1)/$CV_BIN;
$cv_min=$MIN_CV1;
$DENO=(2*($SIGMA**2));
for ($y=0;$y<=$CV_BIN;$y++)
{
$V=0;
	for ($a=0;$a<$x;$a++)
	{
	$Exp=exp(-($cv_min-$CV1[$a])**2/$DENO);
	$Height=$HEIGHT[$a];
	$Gaussian=$Height*$Exp;
	$V=$V+$Gaussian;
	}
$CV_MIN[$y]=$cv_min;
$cv_min=$cv_min+$BIN_SIZE;
$lnP[$y]=-$V;
}

@Sortedlnp=sort{$a<=>$b}@lnP;
for ($f=0;$f<=$CV_BIN;$f++)
{
$Norm_lnP=($lnP[$f]-$Sortedlnp[0]);
print OUTFILE "$CV_MIN[$f] $Norm_lnP\n";
}
close (OUTFILE);
