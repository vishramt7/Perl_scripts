#!usr/bin/perl -w 

print "Type the meta.dat file\n";
$META=<STDIN>;
#$META="meta.dat";
chomp($META);

print "Type minimum Q\n";
$Qmin=<STDIN>;
#$Qmin=1;
chomp ($Qmin);

print "Type maximum Q\n";
$Qmax=<STDIN>;
#$Qmax=136;
chomp ($Qmax);


print "Type the Simulation temperature\n";
$Temp=<STDIN>;
#$Temp=120;
chomp ($Temp);

print "Type the no. of bins for Q\n";
$Qbin=<STDIN>;
#$Qbin=200;
chomp($Qbin);

$Qrange=$Qmax-$Qmin;
$bin_size=($Qrange/$Qbin);
$BETA=(1/(0.0083144621*$Temp)); # This calculates Beta in (mol/KJ)
$S=0;
$iteration=0;
$Tot=0;
open (METAFILE,"$META") || die ("CANNOT OPEN\n");
while ($input=<METAFILE>)
{
chomp ($input);
@INPUTS=split(" ",$input);
$file=$INPUTS[0];
$Q[$S]=$INPUTS[1];
$KAPPA[$S]=$INPUTS[2];
        open (FILE,"$file") || die ("CANNOT OPEN\n");
        while ($timept=<FILE>)
        {
        chomp ($timept);
        @DATA=split(" ",$timept);
	$bin=(($DATA[1]-$Qmin)/$bin_size)+0.5;
        $bin_no=sprintf("%.0f",$bin);
        $Count[$bin_no][$S]++;
        $N[$S]++;
        }
        close (FILE);
#print "$file $Q[$S] $KAPPA[$S]\n";
$S++;
}
close (METAFILE);


for ($ze=1;$ze<=$Qbin;$ze++)
{
$bmax=$Qmin+($ze*$bin_size);
$Qmid=$bmax-($bin_size/2);
	for ($simu=0;$simu<$S;$simu++)
	{
	$W=0.5*($KAPPA[$simu])*(($Qmid-$Q[$simu])**2);
	$C[$ze][$simu]=exp(-($W*$BETA));	
	}
}

while ($Tot<$S)
{
undef @Po_Unbias;
	for ($b=1;$b<=$Qbin;$b++)
	{
	$NUM=0;
	$DENO=0;
	$Po=0;
#	$bmax=$Qmin+($b*$bin_size);
#	$Qmid=$bmax-($bin_size/2);
	
	        for ($s=0;$s<$S;$s++)
	        {
	        $num=0;
	        $deno=0;
#	        $W=0;
#	        $C=0;
#	        $W=0.5*($KAPPA[$s])*(($Qmid-$Q[$s])**2);
#	        $C=exp(-($W*$BETA));
	                if (!defined ($Count[$b][$s]))
	                {
	                $Count[$b][$s]=0;
        	        }

			#This condition calculates the fi's 
	                if ($iteration==0)
	                {
	                $f[$s]=1;
			$diff[$s]=0;
	                }
	                elsif (($iteration>0)&&($b==1))
	                {
	                $fnext=0;
	                $fsum=0;
#	                $w=0;
#	                $c=0;
#	                $qmid=0;
	                $f_prod=0;
	                        for ($bnew=1;$bnew<=$Qbin;$bnew++)
	                        {
#	                        $bnew_max=$Qmin+($bin_size*$bnew);
#	                        $qmid=$bnew_max-($bin_size/2);
#	                        $w=0.5*($KAPPA[$s])*(($qmid-$Q[$s])**2);
#	                        $c=exp(-($w*$BETA));
	                        $f_prod=$C[$bnew][$s]*$New_Po[$bnew];
	                        $fsum=$fsum+$f_prod;
        	                }
			$fnext=(1/$fsum);
        	                $fdiff=abs($fnext-$f[$s]);
	                        if ($fdiff<=0.0002)
	                        {
	                        $diff[$s]=1;
	                        }
	                        else
	                        {
	                        $diff[$s]=0;
	                        }
			$f[$s]=$fnext;
			}
	        $num=$Count[$b][$s];
	        $deno=$N[$s]*$f[$s]*$C[$b][$s];
	        $NUM=$NUM+$num;
	        $DENO=$DENO+$deno;
		}
	$Po=($NUM/$DENO);
	$Po_Unbias[$b]=$Po;		
	}	
@New_Po=@Po_Unbias;	

        $Tot=0;
        for ($sim=0;$sim<$S;$sim++)
        {
        $Tot=$Tot+$diff[$sim];
        }
undef @diff;
$iteration++;
print "$iteration\n";
}

open (OUTFILE,">P_Q_long.txt") || die ("CANNOT OPEN OUTPUT\n");
{
	for ($box=1;$box<=$Qbin;$box++)
	{
	$box_max=$Qmin+($bin_size*$box);
	$mid_box=$box_max-($bin_size/2);
	print OUTFILE "$mid_box $New_Po[$box]\n";
	}
}
close (OUTFILE);
undef @Count;
undef @KAPPA;
undef @Q;
undef @New_Po;
undef @C;
