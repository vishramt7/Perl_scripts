#!usr/bin/perl -w
#This script will 
#1. Choose a particular chain.
#2  Renumber the .pdb
#3. Choose the rotamer named "A" in the .pdb file (i.e alternate location indicator).

$a=0;
$b=0;
$new_resid=0;

$pdb_file=$ARGV[0];
chomp ($pdb_file);

$chain=$ARGV[1];
chomp ($chain);

$outfile=$ARGV[2];
chomp ($outfile);

open (OUTFILE, ">$outfile") || die ("CANNOT OPEN\n");
open (INFILE,"$pdb_file") || die ("CANNOT OPEN\n");
while ($line=<INFILE>)
{
chomp ($line);
        if ((substr($line,0,6) eq "ATOM  ") && (substr($line,21,1) eq $chain))
        {
	$occupancy=substr($line,54,6);
	$occupancy=~s/^\s+|\s+$//g;
	$ALI=substr($line,16,1);
		if ($ALI=~/[[:alpha:]]/)
		{      
		print "$line\n";
		}

		if (($ALI=~/[[:alpha:]]/) && ($occupancy==1))
		{
		print "WARNING:: SOMETHING WRONG WITH THE OCCUPANCY\n";
		}

		if (($ALI!~/[[:alpha:]]/) || (($ALI=~/[[:alpha:]]/) && ($ALI eq "A")))	# This line chooses only the A rotamer
		{
			$RES=substr($line,17,3);
			if (($RES eq "MET") && ($b==0))  
			{
			$b=1;
			}
			if ($b>0)
			{
		        $ATOM_NO=sprintf("%5d",$b);	
			$ANAME=substr($line,12,4);
		        $ANAME=~s/^\s+|\s+$//g;
		                if ($ANAME eq "N")
		                {
		                $a++;
		                $new_resid=sprintf("%4d",$a);
		                }
		        substr($line,6,5,"$ATOM_NO");
			substr($line,22,4,"$new_resid");			
		        print OUTFILE "$line\n";
			$b++;
			}	        
		}        
	}
}
print OUTFILE "END\n";
close (INFILE);
