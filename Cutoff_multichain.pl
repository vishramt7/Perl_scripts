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
#        $atom_no=substr($input,6,5);
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
#        $ATOM_NO[$CH_NO][$line]=$atom_no;
        $RESI_NO[$CH_NO][$line]=$resi_no;
        $X[$CH_NO][$line]=$x;
        $Y[$CH_NO][$line]=$y;
        $Z[$CH_NO][$line]=$z;

#        $MAP[$CH_NO][$atom_no]=$resi_no;
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

	for ($d=0;$d<=$CH_NO;$d++)
	{
		if ($d>$a)		
		{
		$size2=scalar @{$INPUT[$d]};
		}
		elsif ($d==$a)
		{
		$size2=$size;
		}
		else 
		{
		next;
		}		
			for ($b=0;$b<$size;$b++)
			{
			$m=$RESI_NO[$a][$b]+$DIFF+1;	# This ensures that j > i+3
				if ($d>$a)
				{	 
				$n=0;
				}
				elsif ($d==$a) 
				{
				$n=$MAP2[$a][$m];	
					if (!defined($n))
					{
					last;	
					}
				}
					for ($c=$n;$c<$size2;$c++)
				       	{	
				        $R=sqrt((($X[$d][$c]-$X[$a][$b])**2)+(($Y[$d][$c]-$Y[$a][$b])**2)+(($Z[$d][$c]-$Z[$a][$b])**2));
				        	if ($R<=$Cutoff)
				                {
							if (!defined($PAIR[$RESI_NO[$a][$b]][$RESI_NO[$d][$c]]))
							{
							print $a+1,"$RESI_NO[$a][$b] ",$d+1,"$RESI_NO[$d][$c]\n";
							$PAIR[$RESI_NO[$a][$b]][$RESI_NO[$d][$c]]=1;	# This sets the count for each pair
							}
							else
							{
							$PAIR[$RESI_NO[$a][$b]][$RESI_NO[$d][$c]]++;
							}			
					 	}	              	
				        }
			}
	undef @PAIR;					
	}
}
