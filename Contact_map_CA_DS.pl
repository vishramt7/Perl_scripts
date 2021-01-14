#!usr/bin/perl -w 
#This script will give residue contacts formed at given Q.
#The .Q and .Qi file can be from All atom/BB_CB simulations.
#The output is the frequency of a contact formed.

#=for comment;
#print "Enter the .Q file name\n";
#$Qfile=<STDIN>;
$Qfile="L5.Q";
chomp ($Qfile);
print "The Q must be TotalQ-DoubleQ\n";

#print "Enter the .Qi file name\n";
#$Qifile=<STDIN>;
$Qifile="L5_intra.Qi";
chomp ($Qifile);
$Qifile2="L5_inter.Qi";
chomp ($Qifile2);

#print "Enter the file containing the pairs section\n";
#$pairs=<STDIN>;
$pairs="../pairs_intra.dat";	# This must be intra pairs
chomp ($pairs);
$pairs2="../pairs_inter.dat";	# This must be inter pairs
chomp ($pairs2);

#print ("Type the total no of residues in the protein\n");
#$Residue=<STDIN>;
$Residue=76;	# This has to be the residues in the monomer
chomp ($Residue);

open (CONT,"$pairs") || die ("CANNOT OPEN CONT FILE\n");
$a=0;
while ($PAIR=<CONT>)
{
chomp ($PAIR);
	if ($PAIR ne "")
	{
	@PAIRS=split(" ",$PAIR);
	$a++;
	$contacts[$a]="$PAIRS[0] $PAIRS[1]";
#	print "$contacts[$a]\n";
	}
}
$cont_no=$a;		# The total no. of contacts is 2n either intra or inter
close (CONT);

open (CONT2,"$pairs2") || die ("CANNOT OPEN CONT2 FILE\n");
$a2=0;
while ($PAIR2=<CONT2>)
{
chomp ($PAIR2);
	if ($PAIR2 ne "")
	{
	@PAIRS2=split(" ",$PAIR2);
	$a2++;	
	$contacts2[$a2]="$PAIRS2[0] $PAIRS2[1]";
	}	
}
close (CONT2);

$frac=$ARGV[0]*0.1;
$start=$frac-0.05;
$end=$frac+0.05;
print ("$start $end $cont_no\n");
$START=sprintf ("%.0f",$cont_no*$start);
$END=sprintf ("%.0f",$cont_no*$end);
print ("$START $END\n");

open (QFILE,"$Qfile")|| die ("CANNOT OPEN .Q FILE\n");
$line_start=0;
$line_end=0;
$Tot_cont=0;
$Qsum=0;
$b=0;
$line_start2=0;
$line_end2=0;
$Tot_cont2=0;
$Qsum2=0;
while ($CONTNO=<QFILE>)
{
chomp ($CONTNO);
@SPLIT=split (" ",$CONTNO);
$intraQ=$SPLIT[0];
$interQ=$SPLIT[1];
$TotalQ=$SPLIT[2];
	if (($TotalQ>=$START) && ($TotalQ<=$END))
	{
	$line_start=$Qsum+1;
	$line_end=$Qsum+$intraQ;
	$LINE_START[$b]=$line_start;
	$LINE_END[$b]=$line_end;
	
	$line_start2=$Qsum2+1;
	$line_end2=$Qsum2+$interQ;
	$LINE_START2[$b]=$line_start2;
	$LINE_END2[$b]=$line_end2;

	$b++;
	$Tot_cont=$Tot_cont+$intraQ;
	$Tot_cont2=$Tot_cont2+$interQ;
	}
$Qsum=$Qsum+$intraQ;
$Qsum2=$Qsum2+$interQ;
}
close (QFILE);
print "Q done\n";

open (QIFILE,"$Qifile") || die ("CANNOT OPEN .Qi FILE\n");
$Qisum=0;
$i=0;
while ($CONT1=<QIFILE>)
{
chomp ($CONT1);
$Qisum++;
	if ($Qisum>$LINE_END[$b-1])
	{
	last;
	}
	elsif (($Qisum>=$LINE_START[$i]) && ($Qisum<=$LINE_END[$i]))
	{
	$CONTACTS[$CONT1]++;
		if ($Qisum==$LINE_END[$i])
		{
		$i++;
		}
	}
}
close (QIFILE);

open (QIFILE2,"$Qifile2") || die ("CANNOT OPEN .Qi2 FILE\n");
$Qisum2=0;
$i2=0;
while ($CONT2=<QIFILE2>)
{
chomp ($CONT2);
$Qisum2++;
	if ($Qisum2>$LINE_END2[$b-1])
	{
	last;
	}
	elsif (($Qisum2>=$LINE_START2[$i2]) && ($Qisum2<=$LINE_END2[$i2]))
	{
	$CONTACTS2[$CONT2]++;
		if ($Qisum2==$LINE_END2[$i2])
		{	
		$i2++;
		}
	}
}
print "Qi done\n";

open (FREQ,">FREQ.txt") || die ("CANNOT OPEN FREQUENCY\n");
for ($ct=1;$ct<=$a;$ct++) 
{
	if (defined ($CONTACTS[$ct]))
	{
	$freq=$CONTACTS[$ct]/$b;
	}
	else
	{
	$freq=0;
	}
print FREQ "$contacts[$ct] $freq \n";
}
close (FREQ);

open (FREQ2,">FREQ2.txt") || die ("CANNOT OPEN FREQUENCY2\n");
for ($ct2=1;$ct2<=$a2;$ct2++)
{
	if (defined ($CONTACTS2[$ct2]))
	{
	$freq2=$CONTACTS2[$ct2]/$b;	
	}
	else
	{
	$freq2=0;
	}
print FREQ2 "$contacts2[$ct2] $freq2 \n";
}
close (FREQ2);
#print "The number of contacts are $cont_no\n";
#print "The total of all conts in .Q file is $Qsum\n";
#print "The total lines in .Qi file are $Qisum\n";
#print "Totol no of contacts are $Tot_cont\n";
#`cat FREQ.txt | sort -nk1,1 -nk2,2 > t2.txt`;
`cat FREQ.txt FREQ2.txt > t2.txt`;	# sorting is not needed as done previously

open (TTW0,"t2.txt") || die ("CANNOT OPEN t2.txt\n");
$y=0;
while ($ttwo=<TTW0>)
{
@LINE_SPLIT=split(/\s+/,$ttwo);
$TEMPI=$LINE_SPLIT[0];
$TEMPJ=$LINE_SPLIT[1];
$TEMPF[$TEMPI][$TEMPJ]=$LINE_SPLIT[2];
#	if (defined ($MEAN[$TEMPI][$TEMPJ]))		
#	{
#	$MEAN[$TEMPI][$TEMPJ]=$MEAN[$TEMPI][$TEMPJ]+$TEMPF;	
#	$OCCUR[$TEMPI][$TEMPJ]++;
#	print "WARNING: SAME CONTACT REPEATED\n";
#	}
#	else
#	{
#	$MEAN[$TEMPI][$TEMPJ]=$TEMPF;
#	$OCCUR[$TEMPI][$TEMPJ]=1;
#	}
$y++;
}
close (TTW0);

open (INTRA_PAIRS,"$pairs") || die ("CANNOT OPEN PAIRS\n");
while ($intra_pairs=<INTRA_PAIRS>)
{
chomp ($intra_pairs);
@INTRA_PAI=split(" ",$intra_pairs);
$I=$INTRA_PAI[0];
$J=$INTRA_PAI[1];
	if (($I<=$Residue) && ($J<=$Residue))
	{
	$Mean_intra[$I][$J]=($TEMPF[$I][$J]+$TEMPF[$I+$Residue][$J+$Residue])/2;	# This gives the average of the intra contacts
	$Mean_inter[$I][$J]=($TEMPF[$I][$J+$Residue]+$TEMPF[$I+$Residue][$J])/2;	# This gives the average of the inter contacts
	}	
}
close (INTRA_PAIRS);

open (OUTPUT,">L5_Comb$ARGV[0].txt") || die ("cannot open");
for ($p=1;$p<=$Residue;$p++)
{
        for ($q=1;$q<=$Residue;$q++)
        {
        $prob=0;
		if ( defined($Mean_intra[$p][$q]) || defined($Mean_inter[$p][$q]))
		{
			if ($Mean_intra[$p][$q]>=$Mean_inter[$p][$q])			# For a contact which forms both intra & inter,
			{								# only the greater value is printed
			$prob=$Mean_intra[$p][$q];
			}
			else
			{
			$prob=$Mean_inter[$p][$q];	
			}
		}
		elsif ( defined($Mean_intra[$q][$p]) || defined($Mean_inter[$q][$p]))
		{
			if ($Mean_intra[$q][$p]>=$Mean_inter[$q][$p])
			{
			$prob=$Mean_intra[$q][$p];
			}
			else
			{
			$prob=$Mean_inter[$q][$p];
			}
		}
        print OUTPUT "$p $q $prob\n";
        }
}
close (OUTPUT);
undef @Mean_intra;
undef @Mean_inter;
#undef @OCCUR;
undef @CONTACTS;
undef @CONTACTS2;
undef @contacts;
undef @contacts2;
`rm FREQ.txt`;
`rm FREQ2.txt`;
`rm t2.txt`;
