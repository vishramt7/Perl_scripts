#!usr/bin/perl -w 

print "Type the meta.dat file\n";
$META=<STDIN>;
#$META="meta_2d.txt";
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

print "Type the minimum Energy\n";
$Emin=<STDIN>;
#$Emin=-140;
chomp ($Emin);

print "Type the maximum Energy\n";
$Emax=<STDIN>;
#$Emax=160;
chomp ($Emax);

print "Type the new Temperature\n";
$Temp_o=<STDIN>;
#$Temp_o=119.3;
chomp ($Temp_o);

print "Type the no. of bins for energy\n";
$Ebin=<STDIN>;
#$Ebin=100;
chomp ($Ebin);

$Qrange=$Qmax-$Qmin;
$bin_size=($Qrange/$Qbin);
$BETA=(1/(0.0083144621*$Temp)); # This calculates Beta in (mol/KJ)
$BETA_o=(1/(0.0083144621*$Temp_o));

$Erange=$Emax-$Emin;
$ebin_size=($Erange/$Ebin);

$S=0;
$iteration=0;
$Tot=0;
$l=0;
$L=$Qbin*$Ebin;

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

	$ebin=(($DATA[2]-$Emin)/$ebin_size)+0.5;
	$ebin_no=sprintf("%.0f",$ebin);

	$l=$bin_no+($Qbin*($ebin_no-1));		
	$LCount[$l][$S]++;
        $N[$S]++;
        }
        close (FILE);
$S++;
}
close (METAFILE);
print "$L $S\n";


for ($ze=1;$ze<=$L;$ze++)
{
$K=sprintf("%.0f",(($ze/$Qbin)+0.5));
$J=$ze-($Qbin*($K-1));
$bmax=$Qmin+($J*$bin_size);
$Qmid=$bmax-($bin_size/2);
$Kmax=$Emin+($K*$ebin_size);
$Emid=$Kmax-($ebin_size/2);
	for ($simu=0;$simu<$S;$simu++)
	{
	$W=0.5*($KAPPA[$simu])*(($Qmid-$Q[$simu])**2);
	$C[$ze][$simu]=(exp(-($BETA-$BETA_o)*$Emid))*(exp(-($W*$BETA))); #This array starts from 1,0 and not 0,0
		if (defined($LCount[$ze][$simu]))	
		{
			if (!grep(/^$ze$/,@UniqL))	
			{
			push (@UniqL,$ze)
			}					
		}
	}
}
@SortdL=sort{$a<=>$b}@UniqL;
$size=scalar(@SortdL);
print "The no. of L values are $size\n";
while ($Tot<$S)
{
undef @Po_Unbias;
	for ($b=0;$b<$size;$b++)			
	{
	$NUM=0;
	$DENO=0;
	$Po=0;
	$Lnum=$SortdL[$b];
	        for ($s=0;$s<$S;$s++)
	        {
	        $num=0;
	        $deno=0;
	                if (!defined ($LCount[$Lnum][$s]))	
	                {
	                $LCount[$Lnum][$s]=0;
	       	        }
			#This condition calculates the fi's 	
	                if ($iteration==0)
	                {
	                $f[$s]=1;
			$diff[$s]=0;
	                }
	                elsif (($iteration>0)&&($b==0))
	                {
	                $fnext=0;
	                $fsum=0;
	                $f_prod=0;
	                        for ($bnew=0;$bnew<$size;$bnew++)	
	                        {
				$lnum=$SortdL[$bnew];	
	                        $f_prod=$C[$lnum][$s]*$New_Po[$lnum];
	                        $fsum=$fsum+$f_prod;
        	                }
			$fnext=(1/$fsum);
        	                $fdiff=abs($fnext-$f[$s]);
	                        if ($fdiff<=0.0008)
	                        {
	                        $diff[$s]=1;
	                        }
	                        else
	                        {
	                        $diff[$s]=0;
	                        }
			$f[$s]=$fnext;
			}		
	        $num=$LCount[$Lnum][$s];
	        $deno=$N[$s]*$f[$s]*$C[$Lnum][$s];
	        $NUM=$NUM+$num;
	        $DENO=$DENO+$deno;
		}
	$Po=($NUM/$DENO);
	$Po_Unbias[$Lnum]=$Po;		
	}	
@New_Po=@Po_Unbias;	
        $Tot=0;
        for ($sim=0;$sim<$S;$sim++)
        {
        $Tot=$Tot+$diff[$sim];
        }
undef @diff;
$iteration++;
#print "$iteration $Tot\n";
}

open (OUTFILE,">P_Q_long.txt") || die ("CANNOT OPEN OUTPUT\n");
{
	for ($box=1;$box<=$Qbin;$box++)					
	{
	$prob=0;
	$box_max=$Qmin+($bin_size*$box);				#
	$mid_box=$box_max-($bin_size/2);				#
		for ($ebox=1;$ebox<=$Ebin;$ebox++)
		{
		$newl=$box+$Qbin*($ebox-1);
			if (!defined($New_Po[$newl]))
			{
			$New_Po[$newl]=0;
			}
		$prob=$prob+$New_Po[$newl];
		}
	print OUTFILE "$mid_box $prob\n";
	}
}
close (OUTFILE);
undef @LCount;
undef @KAPPA;
undef @Q;
undef @New_Po;
undef @C;
