#!usr/bin/perl -w 
#This script will take .Q and .Qi files as input 
#Output: Unfolding/folding event Qs and contacts formed during those events

#print "Type the name of .Q file\n";
#$Q_file=<STDIN>;
$Q_file="Output.xtc.CA.Q";
chomp ($Q_file);

$Unfolded_Q=16;
$Folded_Q=120;
$Qcount=0;
$line_no=0;
$a=0;
$c=0;
$e=0;

$awk_line=0;
$diff=0;
#open (OUTPUT,">OUT.txt")|| die ("CANNOT OPEN THE OUTPUT\n");
@AWK=`awk '{if (\$1<=$Unfolded_Q || \$1>=$Folded_Q) print \$1,NR}' $Q_file`;
chomp (@AWK);
foreach $element (@AWK)
{
$awk_line++;
@LINE=split (" ",$element);
#print TEMP "$LINE[0]\n";
	if ($LINE[0]<=$Unfolded_Q)
	{
	$Uline=$awk_line;
	$UDATA=$LINE[1];
	}
	if ($LINE[0]>=$Folded_Q)
	{
	$Fline=$awk_line;
	$FDATA=$LINE[1];
	}
        if (defined($Fline) && defined($Uline))
        {
        $diff=$Fline-$Uline;
        }
        if ($diff==1)
        {
        $UOUT[$a]=$UDATA;
	$FOUT[$a]=$FDATA;
	$a++;		        
        }	
}

$d=0;
$f=0;
#=for comment;
open (QFILE,"$Q_file") || die ("CANNOT OPEN .Q FILE\n");
while ($Qline=<QFILE>)
{
chomp ($Qline);
$Qcount=$Qcount+$Qline;
$line_no++;
	if ((defined ($UOUT[$c])) && (defined ($FOUT[$c])) && ($line_no>=$UOUT[$c]) && ($line_no<=$FOUT[$c]))
	{
	$QOUT[$d]=$Qline;
	$FRAMES[$d]=$line_no;
	$d++;
	}	
	if ((defined ($FOUT[$c])) && ($line_no>$FOUT[$c]))
	{
		for($b=1;$b<$d;$b++) 			# $b starts from 1 , since the first value is $Unfolded_Q	
		{
			if ($QOUT[$b]<=$Unfolded_Q)
			{
			undef @QOUT;
			undef @FRAMES;
			last;		
			}
		}		
		if (@FRAMES)
		{
		$f++;
		open (FRAMES_NDX,">frames_$f.ndx") || die ("CANNOT OPEN frames.ndx\n");
		print FRAMES_NDX "[ frames ]\n";
			for($e=0;$e<$d;$e++)		
			{
			print FRAMES_NDX " $FRAMES[$e]\n";
			}
#		print OUTPUT "$FRAMES[0] $FRAMES[$d-1]\n";			
		close (FRAMES_NDX);		
		}
	$d=0;
	$c++;
	}
}
undef @QOUT;
undef @FRAMES;
undef @UOUT;
undef @FOUT;
close (QFILE);
#-------------------------------------------------------------------------------------------------#
#---This part of the script will execute the trjconv to obtain the .xtc files---------------------#
for ($g=1;$g<=$f;$g++) # $g starts from 1 because of the frame nos. start from 1
{
`echo 1 | trjconv -f Output.xtc -s Output.tpr -fr frames_$g.ndx -o frames_$g.xtc`;
}
