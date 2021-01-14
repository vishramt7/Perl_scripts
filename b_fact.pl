#!usr/bin/perl -w

$a=0;
$b=0;
$new_resid=0;
$pdb_file=$ARGV[0];
chomp ($pdb_file);

$infile=$ARGV[1];
chomp ($infile);

open (BFILE,"$infile") || die ("CANNOT OPEN BFILE\n");
while ($bline=<BFILE>)
{
chomp ($bline);
@SPLIT=split (" ",$bline);
$residue=$SPLIT[0];
$b_fact=$SPLIT[1];
$BFACT[$residue]=$b_fact;
}
close (BFILE);

open (INFILE,"$pdb_file") || die ("CANNOT OPEN\n");
while ($line=<INFILE>)
{
chomp ($line);
	if (substr($line,0,6) eq "ATOM  ")
	{
	$b++;
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
	substr($line,21,1,"A");	

	if (defined ($BFACT[$new_resid]))
	{
	$t=$BFACT[$new_resid];
	}
	else 
	{	
	$t=0;
	}
	$temp_fact=sprintf("%6.3f",$t);
	substr($line,60,6,$temp_fact);
	print "$line\n";
	}
}	
close (INFILE);
$check=`grep -w "CA" $ARGV[0] | wc -l`;
chomp ($check);
if ($check==$a)
{
print "END\n";
}
else 
{
print "WARNING:The RES IDs ARE NOT CORRECT\n";
}
