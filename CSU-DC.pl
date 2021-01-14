#!usr/bin/perl -w
#This script will take CSU info as input
#It will scan Table II and remove Destabilizing Contacts (DC)

$CSU_info=$ARGV[0];
chomp ($CSU_info);

$a=0;
$b=0;
open (INFILE, "$CSU_info") || die ("CANNOT OPEN INPUT\n");
while ($LINE=<INFILE>)
{
chomp ($LINE);
	if ($LINE eq "Table II")
	{
	$START[$b]=$a;
	}
	if ($LINE eq "Table III")
	{
	$END[$b]=$a;
	$b++;
	}
$a++;
}
close (INFILE);

$c=0;
$d=0;
open (INFILE,"$CSU_info") || die ("CANNOT OPEN INPUT\n");
while ($LINE=<INFILE>)
{
chomp ($LINE);
	if (($c>$START[$d]) && ($c<$END[$d]))
	{
		if ($c==$START[$d]+1)		
		{
		$LINE=~s/\D//g;	
		$I=$LINE;		
		}
		elsif ($LINE ne "")
		{
		@LI=split (" ",$LINE);
			if ($LI[0]=~/[[:digit:]]/)
			{
			$diff=abs($I-$LI[0]);
			@INFO=split(" ",$LINE);
			$f=0;
				for ($i=4;$i<=7;$i++)
				{	
					if ($INFO[$i] eq "+")
					{
					$f++;
					}		
				}	
			
				if (($f==1) && ($INFO[7] eq "+")) 
				{	
				}
				else
				{	
					if (($LI[0]>$I) && ($diff>3))  
					{
					print "$I $LI[0]\n";
					}
					elsif (($LI[0]<$I) && ($diff>3))
					{
					print "$LI[0] $I\n";
					}					
				}
			}	
		}	
	}	
	if ($c==$END[$d])
	{
	$d++;
	}	
	if ($c>=$END[$b-1])
	{
	last;	
	}
$c++;
}
close (INFILE);
