#!usr/bin/perl -w
#This script will obtain contacts for multiple chains.

#print "Enter the .pdb file\n";
#$pdb=<STDIN>;
$pdb=$ARGV[0];
chomp ($pdb);

#print "Enter the output file name\n";
#$output=<STDIN>;
#chomp ($output);

$Cutoff=4.5;    # The default value is 4.5 A.
$DIFF=3;        # j>i+3.
$CH_NO=0;	# No. of chains.
$line=0;

open (PDB,"$pdb") || die ("CANNOT OPEN .pdb file\n");
#open (OUTPUT,">$output") || die ("CANNOT OPEN OUTPUT FILE\n");
while ($input=<PDB>)
{
chomp ($input);
$ATOM=substr($input,0,6);
$ATOM=~s/^\s+|\s+$//g;
        if ($ATOM eq "ATOM")
        {
        $atom_no=substr($input,6,5);
        $resi_no=substr($input,22,4);
        $x=substr($input,30,8);
        $y=substr($input,38,8);
        $z=substr($input,46,8);
	$Ch=substr($input,21,1);
		if ($Ch=~/[[:alpha:]]/)
		{	
			if (!defined($CH[$CH_NO]))
			{
			$CH[$CH_NO]=$Ch;
			}
			elsif ($Ch ne $CH[$CH_NO])
			{
			$CH_NO++;
			$line=0;
			$CH[$CH_NO]=$Ch;
			}				
		}
		else
		{
		print "WARNING: CHAIN ID IS NOT AN ALPHABET\n";
		last;
		}
        $ATOM_NO[$CH_NO][$line]=$atom_no;
        $RESI_NO[$CH_NO][$line]=$resi_no;
        $X[$CH_NO][$line]=$x;
        $Y[$CH_NO][$line]=$y;
        $Z[$CH_NO][$line]=$z;

        $MAP[$CH_NO][$atom_no]=$resi_no;
	$INPUT[$CH_NO][$line]=$input;
			
		if (!defined ($MAP2[$CH_NO][$resi_no]))			
		{
		$MAP2[$CH_NO][$resi_no]=$line;
		}

	$line++;
        }
}
close (PDB);

for ($a=0;$a<=$CH_NO;$a++)
{	
# These are intra protein contacts	
$size=scalar @{$INPUT[$a]};

	for ($b=0;$b<$size;$b++)
	{
	$m=$RESI_NO[$a][$b]+$DIFF+1;	# This ensures that j > i+3 
	$n=$MAP2[$a][$m];
		if (!defined($n))
		{
		last;
		}
		for ($c=$n;$c<$size;$c++)
	       	{
	        $R=sqrt((($X[$a][$c]-$X[$a][$b])**2)+(($Y[$a][$c]-$Y[$a][$b])**2)+(($Z[$a][$c]-$Z[$a][$b])**2));
	        	if ($R<=$Cutoff)
	                {
				if (!defined($PAIR[$RESI_NO[$a][$b]][$RESI_NO[$a][$c]]))
				{
				print $a+1,"$RESI_NO[$a][$b] ",$a+1,"$RESI_NO[$a][$c]\n";
				$PAIR[$RESI_NO[$a][$b]][$RESI_NO[$a][$c]]=1;	# This sets the count for each pair
				}
				else
				{
				$PAIR[$RESI_NO[$a][$b]][$RESI_NO[$a][$c]]++;
				}			
		 	}	              	
	        }
	}
undef @PAIR;					

#These are inter protein contacts
	for ($d=0;$d<=$CH_NO;$d++)
	{
		if ($d>$a)
		{
		$size2=scalar @{$INPUT[$d]};
			for ($e=0;$e<$size;$e++)
			{
				for ($f=0;$f<$size2;$f++)
				{	
				$R=sqrt((($X[$d][$f]-$X[$a][$e])**2)+(($Y[$d][$f]-$Y[$a][$e])**2)+(($Z[$d][$f]-$Z[$a][$e])**2));
				if ($R<=$Cutoff)	
				{	
					if (!defined($PAIR[$RESI_NO[$a][$e]][$RESI_NO[$d][$f]]))
					{		 
					print $a+1,"$RESI_NO[$a][$e] ",$d+1,"$RESI_NO[$d][$f]\n";
					$PAIR[$RESI_NO[$a][$e]][$RESI_NO[$d][$f]]=1;	
					}
					else
					{
					$PAIR[$RESI_NO[$a][$e]][$RESI_NO[$d][$f]]++;	
					}
				}
				}
			}
		}
		elsif ($d==$a)
		{
		$size2=$size;
		}
#	print "The size of Ch $CH[$a] is $size and $CH[$d] is $size2\n";
	undef @PAIR;	
	}
}
