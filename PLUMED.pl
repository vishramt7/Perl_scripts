#!/usr/bin/perl -w
################################################################################
# Contacts.CA.pl is a simple script written to analyze C-alpha structure-based #
# simulations run in Gromacs.   You must supply a contact file, with 10-12     #
# parameters, the .tpr file used for the simulation, and a trajectory file.    #
# You must also have Gromacs 4.0 installed on your machine                     #
# This is a very straightforward script that you can modify in any way you see #
# fit.  This software comes with absolutely no guarantee, but let us know if   #
# believe you found a bug.                                                     #
# Written by Paul Whitford, 11/02/09                                           #
################################################################################

#=for comment;
$CONTFILE="/home/user/Vishram/Protein_design/Cystatin_like/PDBs_Unifa_conv_cl/grp2/Struct2/Simulations/Scaff_H2Omin/pairs_top.txt";
$CUTOFF=1.5;		#This is the cutoff for the Dmax, 1.2 for CA else 1.5
$KAPPA=0.005;		#This is  the strength for the bias potential
$STRIDE=1000;		#This is frequency to write the COLVAR file
$OUPUT="COLVAR";	#This is the output file name from the Plumed script
$R_0=0;			
$A=0;			
$CONT=0;		#This is to count the No. of contacts
$dQ=0.05;		#This decides the intervel of Umbrellas for Q
$Qmax=0.95;	
$Qmin=0.05;		
$QMAX=sprintf ("%.0f",$Qmax/$dQ);
$QMIN=sprintf ("%.0f",$Qmin/$dQ);

open(CONaa,"$CONTFILE")  or die "no CA contacts file";
while(<CONaa>){
	$ConI=$_;
	chomp($ConI);
	$A ++;
	@TMP=split(" ",$ConI);
	# this gets the native distances from the 6-12 parameters and converts to "nm". "FOR CA SIMULATIONS"
	#$D_0=(6/5*$TMP[3]/$TMP[2])**(1/2.0);

	# this gets the native distances from the 6-12 parameters and converts to "nm". "FOR AA/BB_CB SIMULATIONS"	
	$D_0=(2*$TMP[3]/$TMP[2])**(1/6.0);

	$D_Max=$CUTOFF*$D_0;
	# The R_0 is the inflection point	
	$R_0=(($D_0+$D_Max)/2)-$D_0;
	$ATOMS_SWITCH[$CONT]="ATOMS$A=$TMP[0],$TMP[1] SWITCH$A={RATIONAL R_0=$R_0 D_0=$D_0 D_MAX=$D_Max STRETCH}\n";
	$CONT ++;
}
close(CONaa);
$B=$A/1.25;

print "Type the path of the folder containing basic set of files\n";
$INPUT=<STDIN>;
chomp ($INPUT);

print "Type the Output folder name\n";
$OUT_FOLDER=<STDIN>;
chomp ($OUT_FOLDER);

print "Total No. of contacts in pairs are $A\n";
print "For PLUMED Q, total contacts are $B\n";
print "The CUTOFF is $CUTOFF\n";


for ($a=$QMIN;$a<=$QMAX;$a++)
{
$Q=$a*$dQ;
$AT=sprintf ("%.0f",$B*$Q);
print "$AT ";
`mkdir $OUT_FOLDER\_$AT`;
`cp $INPUT/* $OUT_FOLDER\_$AT`;
`cp /home/user/Vishram/Protein_design/Cystatin_like/PDBs_Unifa_conv_cl/grp2/Struct2/Simulations/Scaff_H2Omin/Cysgp2_l1_99/plu_$AT.gro $OUT_FOLDER\_$AT`;	
open (OUTFILE,">$OUT_FOLDER\_$AT/PLUMED.dat") || die ("CANNOT OPEN THE OUPUT\n");
print OUTFILE "CONTACTMAP ...\n";
print OUTFILE @ATOMS_SWITCH;
print OUTFILE "LABEL=sum\nSUM\n... CONTACTMAP\nres-sum: RESTRAINT ARG=sum KAPPA=$KAPPA AT=$AT\nPRINT STRIDE=$STRIDE ARG=sum,res-sum.bias FILE=$OUPUT\n";
close(OUTFILE);
}
undef @ATOMS_SWITCH;
#=cut;

=for comment;
open (SWITCH,">switch.txt") || die ("cannot open Switch function\n");
$do=0.896124;
$dmax=1.2*$do;
$step=0.01;
$length=10;
$Max_length=$length/$step;
for ($i=0;$i<=$Max_length;$i++)
{
$r=$i*$step;
$ro=(($do+$dmax)/2)-$do;
$Num=1-(($r-$do)/$ro)**6;
$Deno=1-(($r-$do)/$ro)**12;
$Sr=$Num/$Deno;
print SWITCH "$r $Sr\n";
}
close (SWITCH);
=cut;
