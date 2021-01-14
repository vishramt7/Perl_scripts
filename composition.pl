#!usr/bin/local/perl
#This script can calculate the amino acid composition of a sequence in fasta format.

foreach $file (@ARGV)
{
open (INFILE, "$file")|| die ("cannot open");
print ("$file\n");
@array=<INFILE>;
$hydro=0;
$polar=0;
$acidic=0;
$basic=0;
$charged=0;
for ($i=1;$i<@array;$i++)
{
$array[$i]=~tr/a-z/A-Z/;
@array2=split(//,$array[$i]); 
foreach $aa(@array2)
{
if (($aa eq "A")||($aa eq "V")||($aa eq "I")||($aa eq "L")||($aa eq "M")||($aa eq "F")||($aa eq "W")|| ($aa eq "P")|| ($aa eq "G"))
{
$hydro++;
}
elsif (($aa eq "S")|| ($aa eq "T")||($aa eq "C")||($aa eq "Y")|| ($aa eq "N")|| ($aa eq "Q"))
{
$polar++;
}
elsif (($aa eq "D")|| ($aa eq "E"))
{
$acidic++;
}
elsif (($aa eq "R") || ($aa eq "H")|| ($aa eq "K"))
{
$basic++;
}

}
}
$total=$hydro+$polar+$acidic+$basic;
$charged=$acidic+$basic;
$Polar=($polar/$total)*100;
$Hydro=($hydro/$total)*100;
$Charged=($charged/$total)*100;
print ("hydro=$Hydro%, polar=$Polar%, charged=$Charged%,Total=$total\n");

}
