#!usr/bin/perl
#This script take .gro file as input and makes a list of acidic, basic (charged has both the arrays)residues. Then it takes residue pairs (Total Nonnative pairs) and prints only those pairs which are formed between two charged residues.

open (GRO, "2CI2.12063.pdb.gro") || die ("cannot open");
@array=<GRO>;
chop (@array);

@basic=("LYS","ARG","HIS");
@acidic=("ASP","GLU");

foreach $new(@array)
{
@array2=split(/\s +/,$new);
$resi=$array2[2];
$res=$array2[1];

	if (grep /^$resi$/,@acidic)
	{
	#print ("$res\n");
	push (@acid_list,$res);	
	}
	if (grep /^$resi$/, @basic)
	{
	#print ("$res\n");
	push (@basic_list,$res);
	}
}
@charged=(@acid_list,@basic_list);
#print ("@charged\n");
#for ($x=0;$x<@charged;$x++)
#{
#	for ($y=0;$y<@charged;$y++)
#	{
#		if ($charged[$y]>$charged[$x]+3)
#		{
#		print ("$charged[$x] $charged[$y]\n");
#		}
#	}
#
#}

open (INFILE, "Nonnative_pairs.txt")|| die ("cannot open");
@pairs=<INFILE>;
chop (@pairs);
foreach $line(@pairs)
{
@line2=split(/\s+/,$line);
$i=$line2[0];
$j=$line2[1];
	foreach $value(@charged)
	{
		if ($i==$value)
		{
		foreach $next(@charged)	
		{
		if ($j==$next)
		{
		print ("$i $j\n");
		}	
		}
		}
	}
}
