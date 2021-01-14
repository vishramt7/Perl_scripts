#!usr/bin/perl -w
#This script will take HILLS file from Metadynamics as input and will provide the free energy profile.

#=for comment;
print "Enter the biasd HILLS file\n";
$infile=<STDIN>;
chomp ($infile);

print "Enter the ouput file\n";
$outfile=<STDIN>;
chomp ($outfile);

print "Enter the number of bins\n";
$CV_BIN=<STDIN>;
chomp ($CV_BIN);

print "Enter the unbiasd HILLS file\n";
$infile2=<STDIN>;
chomp ($infile2);

print "Enter the temperature\n";
$T=<STDIN>;
chomp ($T);

$kBT=0.008314*$T;
$cut_off=sqrt(2*6.25);                  #################----KernelFunctions.cpp-----##################
$x=0;
open (INFILE, "$infile") || die ("CANNOT OPEN THE HILLS FILE\n");
open (OUTFILE, ">$outfile.bias") || die ("CANNOT OPEN THE OUTPUT\n");
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
$lnP[$y]=-$V;
$cv_min=$cv_min+$BIN_SIZE;
}
@Sortedlnp=sort{$a<=>$b}@lnP;
for ($f=0;$f<=$CV_BIN;$f++)
{
$Norm_lnP=($lnP[$f]-$Sortedlnp[0]);
print OUTFILE "$CV_MIN[$f] $Norm_lnP\n";
}

###############################-------------------------THE CV_MIN used above are used as bin centers----------#######################################
open (INFILE2, "$infile2") || die ("CANNOT OPEN THE HILLS FILE\n");
open (OUTFILE2, ">$outfile.nobias") || die ("CANNOT OPEN THE OUTPUT\n");
$count=0;
while ($HILLS2=<INFILE2>)
{
chomp ($HILLS2);
        if ($HILLS2=~/^\#/)
        {
        }
        else
        {       
        @LINE2=split (" ",$HILLS2);
        $CV1=$LINE2[1];     
		if (($CV1>=$MIN_CV1) && ($CV1<=$MAX_CV1))
		{
		$bin=($CV1-$MIN_CV1/$BIN_SIZE);
		$a=sprintf("%.0f",$bin);
		$BIN[$a]++;
		$count++;
		}
		elsif ($CV1<$MIN_CV1)
		{	
		print "There are values smaller than minimum\n";	
		$BIN[0]++;
		}
		elsif ($CV1>$MAX_CV1)
		{
		print "There are values greater than maximum\n";
		$BIN[$CV_BIN]++;
		}
	}
}
close (INFILE2);
print "The total number of points considered are $count\n";
for ($z=0;$z<=$CV_BIN;$z++)
{
	if (defined($BIN[$z]))
	{ 
	$LNP[$z]=-log($BIN[$z]*(exp(-($lnP[$z]/$kBT))));
	}
	else
	{
	$LNP[$z]=0;
	}
}

@SortedLNP=sort{$a<=>$b}@LNP;
for ($f=0;$f<=$CV_BIN;$f++)
{
$Norm_lnP=($LNP[$f]-$SortedLNP[0]);
print OUTFILE2 "$CV_MIN[$f] $Norm_lnP\n";
}
close (OUTFILE);
close (OUTFILE2);
