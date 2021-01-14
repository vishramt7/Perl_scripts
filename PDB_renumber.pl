#!usr/bin/local/perl
# this script extracts chain B from a pdb file.

foreach $file(@ARGV)
{
open (INFILE, "$file.pdb") || die ("cannot open");
open (OUTFILE, ">$file\_B.pdb") || die ("cannot open");


@array=<INFILE>;
$i=1;
foreach $pdb (@array)
{
@li=split(/\s+/,$pdb);
if ($li[0] eq "ATOM")
{
printf OUTFILE ("%-6s%5d %4s %3s %1s%4d    %8.3f%8.3f%8.3f%6.2f%6.2f           %-2s\n",$li[0],$i,$li[2], $li[3],$li[4], $li[5],$li[6],$li[7],$li[8],$li[9],$li[10],$li[11]);
}
$i++;




}
}

