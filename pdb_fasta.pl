#!/usr/bin/perl
############################################################################
#extract sequence from PDB file and save it in fasta format.
# sequences of different chains are saved as different fasta sequences. 
# Title of the sequences is >pdb_file:chain, fore example >1JTG:A
# The program recognize  DNA or RNA sequence and gives an error
# The program recognize  short sequences ( up to 60 aa) and gives an error
# An output is save in a file with the same name as input file + "fasta" suffix
#for questions: dana.reichmann@weizmann.ac.il
############################################################################
if ($#ARGV < 0) {
        print STDERR "usage: $0 <pdbfile> \n";
        exit -1;
}

$pdbfile=$ARGV[0];
$len_cutoff=60;

@residues=`grep ^ATOM $pdbfile | cut -c 18-27 |uniq`; # format: ASP B  86
@chains=`grep ^ATOM $pdbfile | cut -c 22 |uniq`;

chomp(@residues);
chomp(@chains);

#title for the sequence
$ch_first=substr($residues[0],4,1); # first chain in the file

$pdbf = `basename $pdbfile`; chomp($pdbf); $pdbf =substr($pdbf,3,4);
$ch_suf=substr($pdbfile,17,2);
$name='>'.$pdbf.$ch_suf.':'.$ch_first;
#name for an output file

$output=$pdbf.$ch_suf.'.fasta';

open(OUTPUT,">>$output"); 

printf OUTPUT "$name\n";
$nres=0;
$i=0;
for $r (@residues) {
    $three = substr($r,0,3); #res. name
    $ch = substr($r,4,1); # chain
    $n = substr($r,5,4); # res. number

    if (@seq3 && @seq1 && $ch ne $last_ch) {
#move files with 1st short sequences to directory "short/"	
	if ($nres<=$len_cutoff){
     printf OUTPUT "short sequence $nres aa \n";
      @argsSHORT = ("mv", "$output", "short/.");
    system (@argsSHORT)==0;
     
     exit;    
  }
  
  
  
	while (@seq1){ print OUTPUT splice(@seq1,0,60); }
	undef @seq3;
	$nres=0;
    }   elsif (@seq3 && $n != $last_n + 1) {
	push(@seq3,'---');
    }
   if ($ch_first ne $ch) {
	$name = '>'.$pdbf.$ch_suf.':'.$ch;		
       printf OUTPUT "\n$name\n";
      #$nres=0; 
       
    }

    push(@seq3,$three);
    $one = &one_from_three($three);
    
    #filter for DNA and RNA
    if (!$one){
   printf OUTPUT "DNA/RNA sequence\n";
    @argsDNA = ("mv", "$output", "DNA/.");
     system (@argsDNA)==0;
   exit;   
}
    push(@seq1,$one);
    $last_ch = $ch;
    $last_n  = $n;
    $nres++;
    #$nres_ch = $nres;
    $ch_first=$ch; 
    
 
}
     

  #move files with 2nd short sequences to directory "short/"
if ($nres<=$len_cutoff){
     printf OUTPUT "short sequence $nres aa\n";
      @argsSHORT = ("mv", "$output", "short/.");
    system (@argsSHORT)==0;
     
    exit;    
  }    
while (@seq1){ print OUTPUT splice(@seq1,0,60); }
printf OUTPUT "\n";


exit 0;

close (OUTPUT);



sub one_from_three {
    local $three = shift;
    $one="A" if ($three eq "ALA");
    $one="C" if ($three eq "CYS");
    $one="D" if ($three eq "ASP");
    $one="E" if ($three eq "GLU");
    $one="F" if ($three eq "PHE");
    $one="G" if ($three eq "GLY");
    $one="H" if ($three eq "HIS");
    $one="I" if ($three eq "ILE");
    $one="K" if ($three eq "LYS");
    $one="L" if ($three eq "LEU");
    $one="M" if ($three eq "MET");
    $one="N" if ($three eq "ASN");
    $one="P" if ($three eq "PRO");
    $one="Q" if ($three eq "GLN");
    $one="R" if ($three eq "ARG");
    $one="S" if ($three eq "SER");
    $one="T" if ($three eq "THR");
    $one="V" if ($three eq "VAL");
    $one="W" if ($three eq "TRP");
    $one="Y" if ($three eq "TYR");
    return $one;
}
