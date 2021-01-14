#!usr/bin/perl -w
#
#=for comment;
#print "Type the .gro file to be used\n";
#$gro=<STDIN>;
$gro="/home/user/Vishram/MD/Go_/All_atom/Go_1PHT_AA/Quench_107K_2/PHTAA_newSBM_1/frames1.gro";
chomp ($gro);

$end_frame=40000;	# in ps
$Cutoff=0.45; # in nm

#print "File containing native pairs section\n";
#$pairs=<STDIN>;
$pairs="/home/user/Vishram/MD/Go_/All_atom/Go_1PHT_AA/4_5_Cutoff_files/pairs_4_5.txt";
chomp ($pairs);

$last_line=`awk 'END {print FNR}' $gro`;
chomp ($last_line);
open (GROIN,"$gro") || die ("CANNOT OPEN\n");
$gro_lino=0;
$f=0;
while ($info=<GROIN>)
{
chomp ($info);
$gro_lino++;
        if (($gro_lino>2) && ($gro_lino<$last_line))
        {
        $RESI_NO=substr($info,0,5);
        $RESI_NO=~s/^\s+|\s+$//g;
        $ATOM_NO=substr($info,15,5);
        $ATOM_NO=~s/^\s+|\s+$//g;
        $MAP[$ATOM_NO]=$RESI_NO;
        $f++;
        }
}
close (GROIN);

open (CONT,"$pairs") || die ("CANNOT OPEN PAIRS\n");
while ($PAIR=<CONT>)
{
chomp ($PAIR);
        if ($PAIR ne "")
        {
        @PAIRS=split(" ",$PAIR);
	$x=$PAIRS[0];
	$y=$PAIRS[1];
	$CONT_MAP[$x][$y]=1;
	$CONT_MAP[$y][$x]=1;
	}
}
close (CONT);

`mkdir TEMP_CALC`;
`echo 0 | trjconv -f Output.xtc -s Output.tpr -e $end_frame -sep -o TEMP_CALC/TEMP.gro`;
`rm TEMP_CALC/TEMP.xtc`;
$gro=`ls TEMP_CALC/*.gro | wc -l`;
chomp ($gro);	# The count will go from 0 to $gro-1;
print "Total gro files are $gro \n";
open (OUTFILE,">CONTACTS.txt") || die ("CANNOT OPEN OUTPUT\n");
for ($i=0;$i<$gro;$i++)
{
`echo 0 | genrestr -f TEMP_CALC/TEMP$i.gro -constr -o TEMP_CALC/posre$i.itp`;
`rm TEMP_CALC/TEMP$i.gro`;
$native=0;
$non_native=0;	
open (POSRE,"TEMP_CALC/posre$i.itp") || die ("CANNOT OPEN\n");
	while ($ITP=<POSRE>)
	{
	chomp ($ITP);
	        if (($ITP eq "") || ($ITP=~/^\;/) || ($ITP=~/^\[/))
	        {
	        }
	        else
	        {
	        @SPLIT=split(" ",$ITP);
		$dist=$SPLIT[3];
			if ($dist<=$Cutoff)
			{
			$a=$SPLIT[0];
			$b=$SPLIT[1];
			$A=$MAP[$a];
			$B=$MAP[$b];
			$diff=$A-$B;
			$abs=abs($diff);
				if ($abs>3)
				{
					if (defined($CONT_MAP[$a][$b]))
					{
					$native++;	
					}
					else
					{
					$non_native++;		
					}	
				}       
			}
	        }
	}
close (POSRE);
`rm -r TEMP_CALC/posre$i.itp`;
print OUTFILE "$i $native $non_native\n";
}
close (OUTFILE);
`rm -r TEMP_CALC`;
print "Done!\n";
