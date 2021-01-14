#!usr/bin/perl -w
#This script will take HILLS file from Metadynamics as input and will provide the free energy profile.

#print "Enter the HILLS file\n";
$infile="/home/user/Vishram/MD/Go_/All_atom/Go_1PHT_AA/MetaD/1PHTAA_newSBM_RgQ1/HILLS";
#$infile=<STDIN>;
chomp ($infile);

#print "Enter the ouput file\n";
$outfile="RgQ";
#$outfile=<STDIN>;
chomp ($outfile);

#print "Enter the number of bins\n";
$CV1_BIN=200;
#$CV1_BIN=<STDIN>;
chomp ($CV1_BIN);
$CV2_BIN=$CV1_BIN;

$cut_off=sqrt(2*6.25);                  #################----KernelFunctions.cpp-----##################
$T=112;
$kB=0.00831451;
$kBT=$kB*$T;
$x=0;
open (INFILE, "$infile") || die ("CANNOT OPEN THE HILLS FILE\n");
open (OUTFILE, ">$outfile\_CV1") || die ("CANNOT OPEN THE OUTPUT\n");
open (OUTFILE1, ">$outfile\_CV2") || die ("CANNOT OPEN THE OUTPUT\n");
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
	$CV2[$x]=$LINE[2];	
	$SIGMA_CV1=$LINE[3];	# SIGMA is constant throughout.
	$SIGMA_CV2=$LINE[4];	
	$HEIGHT[$x]=$LINE[5];
#	$BIAS[$x]=$LINE[6];
	$x++;		
	}	
}
close (INFILE);

@SortedCV1=sort{$a<=>$b}@CV1;		
@SortedCV2=sort{$a<=>$b}@CV2;
print "Sorting is done\n";
$size_cv1=scalar(@SortedCV1);
$size_cv2=scalar(@SortedCV2);

$MIN_CV1=$SortedCV1[0]-($cut_off*$SIGMA_CV1);
$MAX_CV1=$SortedCV1[$size_cv1-1]+($cut_off*$SIGMA_CV1);
$MIN_CV2=$SortedCV2[0]-($cut_off*$SIGMA_CV2);
$MAX_CV2=$SortedCV2[$size_cv2-1]+($cut_off*$SIGMA_CV2);

undef @SortedCV1;
undef @SortedCV2;

#$GRID_SPACING_CV1=(1.76*$SIGMA_CV1)/5;	############------This value was obtained from the fes.dat files-----############
#$GRID_SPACING_CV2=(1.76*$SIGMA_CV2)/5;
$BIN_SIZE_CV1=($MAX_CV1-$MIN_CV1)/$CV1_BIN;
$BIN_SIZE_CV2=($MAX_CV2-$MIN_CV2)/$CV2_BIN;

$DENO_CV1=(2*($SIGMA_CV1**2));
$DENO_CV2=(2*($SIGMA_CV2**2));

for ($y=1;$y<=$CV1_BIN;$y++)
{
$cv_min=$MIN_CV1+($BIN_SIZE_CV1*($y-1));
$cv_max=$MIN_CV1+($BIN_SIZE_CV1*($y));
$cv_avg[$y]=($cv_min+$cv_max)/2;

$cv_min2=$MIN_CV2+($BIN_SIZE_CV2*($y-1));
$cv_max2=$MIN_CV2+($BIN_SIZE_CV2*($y));
$cv_avg2[$y]=($cv_min2+$cv_max2)/2;     
}

for ($a=0;$a<$x;$a++)
{
	for ($y=1;$y<=$CV1_BIN;$y++)
	{	
	$Exp_CV1[$y][$a]=exp(-(($cv_avg[$y]-$CV1[$a])**2/$DENO_CV1));		#[bin][time]
	$Exp_CV2[$y][$a]=exp(-(($cv_avg2[$y]-$CV2[$a])**2/$DENO_CV2));	
	}
}
undef @CV1;
undef @CV2;
print "Half done\n";
for ($y=1;$y<=$CV1_BIN;$y++)
{
	for ($z=1;$z<=$CV2_BIN;$z++)
	{
	$V=0;
		for ($a=0;$a<$x;$a++)
		{
		$Gaussian=$HEIGHT[$a]*($Exp_CV1[$y][$a])*($Exp_CV2[$z][$a]);	#bin,time
		$V=$V+$Gaussian;		
		}
	$P[$y][$z]=exp($V/$kBT); #[CV1][CV2]
	}
}

for ($y=1;$y<=$CV1_BIN;$y++)
{
$sum=0;
	for ($z=1;$z<=$CV2_BIN;$z++)
	{
	$sum=$sum+$P[$y][$z];
	}
print OUTFILE "$cv_avg[$y] $sum\n";
}

for ($z=1;$z<=$CV2_BIN;$z++)
{
$sum=0;
	for ($y=1;$y<=$CV1_BIN;$y++)
	{
	$sum=$sum+$P[$y][$z];
	}
print OUTFILE1 "$cv_avg2[$z] $sum\n";
}
close (OUTFILE);
close (OUTFILE1);
