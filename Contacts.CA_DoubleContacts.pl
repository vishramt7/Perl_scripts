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

# Edit the settings so they fit your needs...

# GMXPATH is the path to your Gromacs executables
#$GMXPATH="/home/user/Downloads/gromacs/bin/";


# CONTFILE is the file that defines the contacts.  Specific formatting must be 
# followed: Copy the "pairs" terms from your C-Alpha Structure-based topology file.
# remove the "1" and reformat each line so it is space delimited.  If you have 
# a blank line in the contact file, the program will probably crash.
# example formatting can be found at http://smog-server.org/contact_ex  
$CONTFILE=$ARGV[2];
chomp($CONTFILE);

$CONTFILE2=$ARGV[3];
chomp($CONTFILE2);

# CUTOFF is how you determine a contact is formed, or broken.  CUTOFF=1.2 means
# a native contact is considered formed if the involved atoms are within 120%
# of their native distance.  
$CUTOFF=1.2;

# If you would only like to calculate the Q of every Nth frame, then change SKIPFRAMES to the desired frequency of output.

$SKIPFRAMES=1;

# End of settings

# this reads in contact list

open(CONaa,"$CONTFILE")  or die "no CA contacts file";
$CONNUMaa=0;
while(<CONaa>){
	$ConI=$_;
	chomp($ConI);
	$CONNUMaa ++;

	@TMP=split(" ",$ConI);
	$Iaa[$CONNUMaa]=$TMP[0];
	$Jaa[$CONNUMaa]=$TMP[1];
	# this gets the native distances from the 6-12 parameters and converts to Ang.
	$Raa[$CONNUMaa]=(6/5*$TMP[3]/$TMP[2])**(1/2.0)*10.0;
}
close(CONaa);

open(CONbb,"$CONTFILE2")  or die "no CA contacts file";
$CONNUMbb=0;
while(<CONbb>){
	$ConJ=$_;
	chomp($ConJ);
	$CONNUMbb ++;

	@TMP_NEW=split(" ",$ConJ);
	$Ibb[$CONNUMbb]=$TMP_NEW[0];
	$Jbb[$CONNUMbb]=$TMP_NEW[1];
	# this gets the native distances from the 6-12 parameters and converts to Ang.
	$Rbb[$CONNUMbb]=(6/5*$TMP_NEW[3]/$TMP_NEW[2])**(1/2.0)*10.0;
}	
close(CONbb);

#print "What is the name of the tpr file?\n";
$TPR=$ARGV[0];
chomp($TPR);
# go through all of the xtc files
#print "What  xtc (or trr) file would you like to analyze?\n";
$XTCfile=$ARGV[1];
chomp($XTCfile);
#print "\n\n\n\n\n";
print "This script will calculate the number of native contacts for frames n*$SKIPFRAMES (n starts at 0) for trajectory file $XTCfile.\n";
print "IMPORTANT: A contact is defined as any native pair listed in $CONTFILE that is withing $CUTOFF times the distance in $CONTFILE\n";
#print "\n\n\n\n\n";

# you can change the flags sent to gromacs if you want to reduce the Q sampling
# i.e. every other frame is analyzed.  The trajectory file is converted to a pdb
# and then this script analyzes the pdb.
`echo 0 | trjconv  -skip $SKIPFRAMES -s $TPR -o tmp.pdb -f  $XTCfile`;

#open(CAQ,">$XTCfile\_$CONTFILE.CA.Q") or die "couldn't open Q file";
#open(CAQI,">$XTCfile\_$CONTFILE.CA.Qi") or die "couldn't open Qi file";

#open(CAQ2,">$XTCfile\_$CONTFILE2.CA.Q") or die "couldn't open Q file";
#open(CAQI2,">$XTCfile\_$CONTFILE2.CA.Qi") or die "couldn't open Qi file";

open(OUTPUT,">$XTCfile\_Total.CA.Q") or die "couldn't open Qi file";

open(PDB,"tmp.pdb") or die "pdb file missing somehow";
###$SAMPLES=0; #I think this is obsolete
	#GRAB THE ATOM COORDS
while(<PDB>){
	$LINE=$_;
	chomp($LINE);

	if(substr($LINE,0,5) eq "MODEL"){
		$ATOMNUM=0;
	}


        if(substr($LINE,0,4) eq "ATOM"){
	        # store positions, index and residue number
		$ATOMNUM=$ATOMNUM+1;
	        $X[$ATOMNUM]=substr($LINE,30,8);
                $Y[$ATOMNUM]=substr($LINE,38,8);
               	$Z[$ATOMNUM]=substr($LINE,46,8);
        }


        if(substr($LINE,0,3) eq "TER"){

	# do contact calculations
		# determine the atom-atom contacts

               	$Qaa=0;

		for($i = 1;$i <= $CONNUMaa; $i +=1){
			$R=sqrt( ($X[$Iaa[$i]]-$X[$Jaa[$i]])**2.0 + 
			       	 ($Y[$Iaa[$i]]-$Y[$Jaa[$i]])**2.0 + 
  			 	 ($Z[$Iaa[$i]]-$Z[$Jaa[$i]])**2.0);

 			if($R < $CUTOFF*$Raa[$i]){
				$Qaa ++;
#				print CAQI "$i\n";
				$OUTaa[$Qaa]=$i;
			}
		}
#	        print CAQ "$Qaa\n";

		$Qbb=0;
		
		for($j = 1;$j <= $CONNUMbb; $j +=1){
			$R2=sqrt( ($X[$Ibb[$j]]-$X[$Jbb[$j]])**2.0 +
				  ($Y[$Ibb[$j]]-$Y[$Jbb[$j]])**2.0 +	
				  ($Z[$Ibb[$j]]-$Z[$Jbb[$j]])**2.0);									

			if($R2 < $CUTOFF*$Rbb[$j]){
				$Qbb ++;
#				print CAQI2 "$j\n";
				$OUTbb[$Qbb]=$j;	
			}
		}
#		print CAQ2 "$Qbb\n";

		$DOUBLE_CONTS=0;
		$TotalQ=$Qaa+$Qbb;					
		for ($x=1;$x<=$Qaa;$x++)
		{
			for ($y=1;$y<=$Qbb;$y++)
			{
				if ($OUTaa[$x]==$OUTbb[$y])
				{
				$DCOUNT[$DOUBLE_CONTS]=$OUTaa[$x];
				$DOUBLE_CONTS++;		
				}
			}		
		}
#		print OUTPUT "$TotalQ $DOUBLE_CONTS @DCOUNT\n";		# The Contact numbers can be obtained from @DCOUNT			
		print OUTPUT "$Qaa $Qbb $TotalQ $DOUBLE_CONTS\n";
		undef @OUTaa;
		undef @OUTbb;
		undef @DCOUNT;

        }
}
#close(CAQ);
#close(CAQI);
#close(CAQ2);
#close(CAQI2);
close(OUTPUT);
`rm tmp.pdb`;
print "WARNING : BOTH THE CONTACT FILES SHOULD HAVE INTRA AND CORRESPONDING INTER CONTACTS IN THE SAME ORDER\n";
