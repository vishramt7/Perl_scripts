#!usr/bin/perl -w 

$INFILE="t_E_PluQ.txt";

open (INFI,"$INFILE") || die ("CANNOT OPEN\n");
$a=0;
$b=scalar(@ARGV);
while ($line=<INFI>)
{
chomp ($line);
@SPLIT=split(" ",$line);
$t=$SPLIT[0];
$E=$SPLIT[1];
$Q=sprintf ("%.0f",$SPLIT[2]);
	if (grep(/^$Q$/,@ARGV))
	{
		if (!grep(/^$Q$/,@UNIQ))
		{
		$UNIQ[$a]=$Q;
		print "$t $Q\n";
		`echo 1 | trjconv -f Output.xtc -s Output.tpr -b $t -e $t -o plu_$Q.gro`;
		$a++;
		}		
	}
	elsif($a>$b)
	{
	print "This command was issued\n";
	last;
	}
}
print "Total input=$b total obtained=$a\n";
close (INFI);
