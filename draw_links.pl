#!usr/bin/perl -w
#

$contfile=$ARGV[0];
chomp ($contfile);

open (INFILE,$contfile) || die ("CANNOT OPEN\n");
while ($line=<INFILE>)
{
chomp ($line);
@LINE=split (" ",$line);
$i=$LINE[1];
$j=$LINE[3];

#These are for pymol
#print "draw_links resi $i and name CA and chain A, resi $j and name CA and chain A, color=red, color2=red, radius=0.3, object_name=$i:$j\_Bound_uniq\n";
#print "show sticks, resi $i+$j\n";
#print "label n. CA and i. $i+$j, resn+resi\n";
#
#These are for vmd
print "set sel1 [atomselect top \"resid $i and name CA\"]\n";
print "set sel2 [atomselect top \"resid $j and name CA\"]\n";
print "lassign [\$sel1 get {x y z}] pos1\n";
print "lassign [\$sel2 get {x y z}] pos2\n";
print "lassign [\$sel1 get index] ind1\n";
print "lassign [\$sel2 get index] ind2\n";
print "draw color red\n";
print "draw line \$pos1 \$pos2 width 5\n";
print "label add Atoms 0/\$ind1\n";
print "label add Atoms 0/\$ind2\n"; 
}
close (INFILE);
