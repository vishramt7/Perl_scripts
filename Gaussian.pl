#!usr/bin/perl -w 
#This script will take 2 inputs 1. .gro file 2. pairs section from .top file

################################################################################################################################

#		 THERE IS A SMALL MISTAKE IN THE FORM OF THE GAUSSIAN USED. REFER TO Proteins 2009; 77:881–891. before use.!!!

################################################################################################################################

#=for comment;
#print "Type the input .gro file\n";
#$gro_file=<STDIN>;
$gro_file="/home/user/Nahren/Molecular_Simulations/Project/1UNK/1UNK_CA.15201.pdb.sb/1UNK_cent.gro";
chomp ($gro_file);

#print "Type the file containing the pairs section\n";
#$pairs_file=<STDIN>;
$pairs_file="/home/user/Nahren/Molecular_Simulations/Project/1UNK/1UNK_CA.15201.pdb.sb/pairs_top.txt";
chomp ($pairs_file);

$line_no=0;
$B=0;$C=0;$D=0;$E=0;
@HYDRO=("ALA","VAL","LEU","ILE","MET","PHE","TRP","PRO","GLY");
@POLAR=("SER","THR","CYS","TYR","GLN","ASN");
@ACIDIC=("ASP","GLU");
@BASIC=("LYS","ARG","HIS");
$last_line=`awk 'END {print FNR}' $gro_file`;
chomp ($last_line);
open (GRO,"$gro_file") || die ("CANNOT OPEN\n");
while ($GRO_LINE=<GRO>) 
{
$line_no++;
chomp ($GRO_LINE);
	if (($line_no>2) && ($line_no<$last_line))
	{
	$RES_ID=substr ($GRO_LINE,5,5);
	$RES_ID=~s/^\s+|\s+$//g;
	$RESI_NO=substr($GRO_LINE,0,5);
	$RESI_NO=~s/^\s+|\s+$//g;
		if (grep (/^$RES_ID$/,@HYDRO))
		{
		$HYDRO_NO[$B]=$RESI_NO;
		$B++;
		}
		elsif (grep (/^$RES_ID$/,@POLAR))
		{
		$POLAR_NO[$C]=$RESI_NO;	
		$C++;
		}
		elsif (grep (/^$RES_ID$/,@ACIDIC))
		{
		$ACIDIC_NO[$D]=$RESI_NO;
		$D++;
		}
		elsif (grep (/^$RES_ID$/,@BASIC))
		{
		$BASIC_NO[$E]=$RESI_NO;		
		$E++;
		}
		else
		{
		print "NOT A VALID RESIDUE NAME\n";
		}
	}
}
close (GRO);
@CHARGED_NO=(@ACIDIC_NO,@BASIC_NO);
$F=scalar(@CHARGED_NO);

open (PAIRS,"$pairs_file") || die ("CANNOT OPEN PAIRS FILE\n");
open (TEMP_PAIRS, ">NATIVE_PAIRS.txt") || die ("CANNOT OPEN tempo_pairs.txt\n");
while ($CONTACT=<PAIRS>)
{
chomp ($CONTACT);
	if ($CONTACT ne "")
	{
	@CONT=split (" ",$CONTACT);
	$RES_I=$CONT[0];
	$RES_J=$CONT[1];
		if ($RES_J>$RES_I)
		{
		print TEMP_PAIRS "$RES_I $RES_J\n";
		}
		else
		{
		print TEMP_PAIRS "$RES_J $RES_I\n";
		}
	}
}
close (PAIRS);
close (TEMP_PAIRS);
 
open (NN, ">TOT_PAIRS.txt") || die ("CANNOT OPEN NONNATIVE PAIRS\n");
#This loop makes hydrophobic pairs
for ($i=0;$i<$B;$i++)
{
	for ($j=0;$j<$B;$j++)
	{
	        if ($HYDRO_NO[$j]>$HYDRO_NO[$i]+3)
	        {
	        print NN "$HYDRO_NO[$i] $HYDRO_NO[$j]\n";
	        }	
	}
}
#This for loop makes polar-polar pairs
for ($a=0;$a<$C;$a++)
{
	for ($b=0;$b<$C;$b++)
	{
		if ($POLAR_NO[$b]>$POLAR_NO[$a]+3)
		{
		print NN "$POLAR_NO[$a] $POLAR_NO[$b]\n";
		}
	}
}
#This for loop makes polar charged pairs
for ($x=0;$x<$C;$x++)
{
	for ($y=0;$y<$F;$y++)
	{
	$diffFC=abs($CHARGED_NO[$y]-$POLAR_NO[$x]);
		if ($diffFC>3)	
		{
		print NN "$POLAR_NO[$x] $CHARGED_NO[$y]\n";
		}	
	}
}
#This loop makes oppositely charged pairs
for ($d=0;$d<$D;$d++)
{
	for ($e=0;$e<$E;$e++)
	{
	$diffED=abs($BASIC_NO[$e]-$ACIDIC_NO[$d]);
		if ($diffED>3)	
		{
		print NN "$ACIDIC_NO[$d] $BASIC_NO[$e]\n";
		}
	}
}
close (NN);
print "The total no of hydrophobic residues are $B\n";
print "The total no of polar residues are $C\n";
print "The total no of acidic residues are $D\n";
print "The total no of basic residues are $E and the total is $F\n";

#=for comment;
#############################################################
#								
#############################################################
#
#		THERE IS A SMALL MISTAKE IN THE FORM OF THE GAUSSIAN USED. REFER TO Proteins 2009; 77:881–891. before use.!!! 
#
open (TABLE,">table_b1.xvg") || die ("CANNOT OPEN TABLE\n");
$Ep=1;
$S=0.4;
$Table_length=28;
$Step_size=0.002;
$Vr2=0;
$Vrep=0; 
$Vgauss=0;
$Fr2=0;     
$Epsilon=-1;   # This is the depth of the Gaussian
$Rg=0.6;       # This is the rmin distance 
$Sg=0.1;       # This is the width of the Gaussian 
$Max_value=$Table_length/$Step_size;
for ($A=0;$A<=$Max_value;$A++)
{
$R=$A*$Step_size;
	if ($R<=0.01)
	{
	print TABLE "$R $Vr2 $Fr2\n";
	}
	elsif ($R>0.01)
	{
	$Vrep=$Ep*(($S/$R)**12);
	$Vgauss=$Epsilon*(exp(-(($R-$Rg)**2)/$Sg**2));
	$Frep=(12/$R)*$Vrep;
	$Fgauss=2*(($R-$Rg)/$Sg**2)*$Vgauss;

	$Vr2=$Vrep+$Vgauss+$Vrep*$Vgauss;
	$Fr2=$Frep+$Fgauss+$Vrep*$Fgauss+$Vgauss*$Frep;
	print TABLE "$R $Vr2 $Fr2\n";
	}
}
close (TABLE);
#=cut;
##########################################################
#
##########################################################
