#!usr/bin/perl -w 
#This script will reweigh the lnP_vs_Q.txt.
#Input:file containing 2 columns Q and E.

print "Enter the input Q_energy.txt\n";
$infile=<STDIN>;
#$infile="Q_Energy.txt";
chomp ($infile);

print "Enter the temperature for input file\n";
$T1=<STDIN>;
#$T1=138;
chomp ($T1);

print "Enter the new temperature\n";
$T2=<STDIN>;
#$T2=137.8;
chomp ($T2);

print "Enter the output file name\n";
$outfile=<STDIN>;
#$outfile="lnP_vs_Q";
chomp ($outfile);

$line=0;
open (INPUT,"$infile") || die ("CANNOT OPEN\n");
while ($inline=<INPUT>)
{
chomp ($inline);
@SPLIT=split (" ",$inline);
$q=$SPLIT[0];
$pe=$SPLIT[1];
	if ($line==0)
	{
	$minQ=$maxQ=$q;
	$minE=$maxE=$pe;
	}
	else
	{
		if ($q<=$minQ)
		{	
		$minQ=$q;
		}
		if ($pe<=$minE)
		{
		$minE=$pe;
		}
		if ($q>=$maxQ)
		{
		$maxQ=$q;
		}
		if ($pe>=$maxE)
		{
		$maxE=$pe;
		}	
	}
$line++;
}
close (INPUT);

$Q_bin=155;
$E_bin=200;
$Q_range=$maxQ-$minQ;
$bin_size=($Q_range/$Q_bin);

$E_range=$maxE-$minE;
$ebin_size=($E_range/$E_bin);

open (INFILE, $infile) || die ("CANNOT OPEN INFILE\n");
while ($input=<INFILE>)
{
chomp ($input);
@VALUES=split(/\s+/,$input);
$PE1=$VALUES[1];
$Q=$VALUES[0];
        $bin=(($Q-$minQ)/$bin_size); 
        $a=int($bin);

        $ebin=(($PE1-$minE)/$ebin_size); 
        $b=int($ebin);

	$ARRAY[$a][$b]++;
}
close (INFILE);

$c=0;
$P1=0;
$P2=0;
$kB=0.00831451;
for ($y=0;$y<=$E_bin;$y++) # This loop for E
{
$E_min=$minE+($ebin_size*$y);
$E_max=$minE+($ebin_size*($y+1));
$E_avg[$y]=($E_min+$E_max)/2;
}
open (OUTPUT1,">$outfile\_orig$T1.txt") || die ("CANNOT OPEN\n");
open (OUTPUT2,">$outfile\_$T2.txt") || die ("CANNOT OPEN\n");
for ($A=0;$A<=$Q_bin;$A++)
{
$count=0;
$wcount=0;
$Q_min=$minQ+($bin_size*$A);
$Q_max=$minQ+($bin_size*($A+1));
$Q_avg[$A]=($Q_min+$Q_max)/2;
	for ($B=0;$B<=$E_bin;$B++)
	{
		if (defined ($ARRAY[$A][$B]))	
		{
		$P1=$ARRAY[$A][$B];
		$count=$count+$P1;
		$P2=$P1*exp(($E_avg[$B]/$kB)*((1/$T1)-(1/$T2)));
		$WARRAY[$A][$B]=$P2;
		$wcount=$wcount+$P2;
		$c=$c+$ARRAY[$A][$B];
		}
	}
print OUTPUT1 "$Q_avg[$A] $count\n";
	if ($wcount>0)
	{
	$log[$A]=-log($wcount);
	}
	else
	{
	$log[$A]=0;
	}	
}
print "The minimum and maximum values for Q are $minQ $maxQ\n";
print "The minimum and maximum values for E are $minE $maxE\n";
print "The total values are $c\n";
close (OUTPUT1);
undef @E_avg;
undef @ARRAY;
undef @WARRAY;

@Sortedlog=sort{$a<=>$b}@log;
for ($C=0;$C<=$Q_bin;$C++)
{
	if ($log[$C]!=0)
	{
	$Norm=$log[$C]-$Sortedlog[0];
	print OUTPUT2 "$Q_avg[$C] $Norm\n";
	}
}
close (OUTPUT2);
