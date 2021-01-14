#!/usr/bin/perl -w

$CONTFILE=$ARGV[0];
chomp ($CONTFILE);

open(CONaa,"$CONTFILE")  or die "no CA contacts file";
$CONNUMaa=0;
while(<CONaa>){
	$ConI=$_;
	chomp($ConI);
	$CONNUMaa ++;

	@TMP=split(" ",$ConI);

	print "($TMP[0],$TMP[1]), ";
}
close(CONaa);

