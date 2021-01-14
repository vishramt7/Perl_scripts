#!usr/bin/local/perl
#This script takes a pdb file as input, then it obtains the number of chains. 
#For each chain it calculates the center of mass using subroutine called Center.
#Then it calculates the whether the residue is inward/outward pointing using two subroutines. 
#1.Orient: It calculates the direction using the distance between COM, Calpha and Cbeta
#2.Ca_Cb_vector: It calculates the angle between COM, Calpha and Cbeta and then decides the direction in which the residue points.It needs another subroutine called 3.rad_to_degree to convert the angle from radians to degrees.
# The output is in the form of string of I/O/-. This denotes Inward/Outward/-.

print ("Enter the pdb file name\n");
$inf=<STDIN>;
chomp ($inf);

open (INPUT,"$inf")|| die ("cannot open");
@input=<INPUT>;
chomp (@input);
foreach $ln(@input)
{
	if (substr($ln,0,6) eq "ATOM  ")
	{
	$chain_id=substr($ln,21,1);
	$chain_id=~s/^\s+|\s+$//g;
		if (!grep(/$chain_id/,@chain_lst) && $chain_id=~/[[:alpha:]]/)
		{
		push (@chain_lst,$chain_id);
		}		
	}
}
$No_chain=@chain_lst;
print "The total number of chains are $No_chain @chain_lst\n";	

foreach $chain(@chain_lst)
{
undef @pdb_single;
	foreach $ln(@input)
	{
	$chain_id=substr($ln,21,1);
	$chain_id=~s/^\s+|\s+$//g;
		if (($chain_id eq $chain)&&(substr($ln,0,6) eq "ATOM  "))
		{
		push (@pdb_single,$ln,"\n");
		}
	}
open (OUTPUT,">tempo_$chain.pdb")|| die ("cannot open");
print OUTPUT @pdb_single;
print "This is chain $chain\n";
$input="tempo_$chain.pdb";
$com=&Center($input);
print "$com\n";

@Cal_be_dist=&Orient($input,$com);
print @Cal_be_dist,"\n";

@vector=&Ca_Cb_vector($input,$com);
print @vector,"\n";

close (OUTPUT);
`rm tempo_$chain.pdb`;	
	for($q=0;$q<@Cal_be_dist;$q++)
	{
		if ($Cal_be_dist[$q] eq $vector[$q])
		{
		print $Cal_be_dist[$q];
		}
		else
		{
		print "-";	
		}
	}
print "\n";	
}

#$centre_of_mass=&Center($inf);
#print ("$centre_of_mass\n");
sub Center
{
$infile=$_[0];
@file=`grep -w "CA" $infile`;
chomp(@file);
$cal_mass=1.0; #mass of each C-alpha is taken to be 1.0
$xo=$yo=$zo=0; #The origin is taken to be 0,0,0
$sumx=$sumy=$sumz=0;
$size=@file;
	for ($m=0;$m<@file;$m++)
	{
	$x=substr($file[$m],30,8);
	$y=substr($file[$m],38,8);
	$z=substr($file[$m],46,8);

	$xdist=sqrt(($x-$xo)**2);
	$ydist=sqrt(($y-$yo)**2);
	$zdist=sqrt(($z-$zo)**2);	
		if ($x>=0)
		{
		$xprod=$xdist*$cal_mass;
		}
		else
		{
		$xprod=-$xdist*$cal_mass;
		}
		if ($y>=0)
		{
		$yprod=$ydist*$cal_mass;
		}
		else
		{
		$yprod=-$ydist*$cal_mass;
		}
		if ($z>=0)
		{
		$zprod=$zdist*$cal_mass;
		}
		else
		{
		$zprod=-$zdist*$cal_mass;
		}
	$sumx=$sumx+$xprod;
	$sumy=$sumy+$yprod;
	$sumz=$sumz+$zprod;
	}
$tot_mass=$size*$cal_mass;
$XR=$sumx/$tot_mass;
$YR=$sumy/$tot_mass;
$ZR=$sumz/$tot_mass;
$center=$XR." ".$YR." ".$ZR;
}

#@CA_CB_dist=&Orient($inf,$centre_of_mass);
#print @CA_CB_dist,"\n";
sub Orient
{
undef @orient;
	$infile=$_[0];
	$centroid=$_[1];
	$centroid=~s/^\s+|\s+$//g;
	@COM=split(/\s+/,$centroid);
	$COMX=$COM[0];
	$COMY=$COM[1];
	$COMZ=$COM[2];
	open (PDB,"$infile")|| die ("cannot open");
	@pdb=<PDB>;
	chomp(@pdb);
		foreach $line(@pdb)
		{
			if (substr($line,0,6) eq "ATOM  ")
			{	
			push (@pdb1,$line);
			$resi_no=substr($line,22,5);
			$resi_no=~s/^\s+|\s+$//g;
				if (!grep(/$resi_no/,@residue))
				{
				push (@residue,$resi_no);
				}
			}
		}
		foreach $no(@residue)
		{
		$cadist=$cbdist=0;
			for($a=0;$a<@pdb1;$a++)
			{
			$resi=substr($pdb1[$a],22,5);
			$resi=~s/^\s+|\s+$//g;	
				if($resi eq $no)
				{
					if (grep(/\bCA\b/,$pdb1[$a]))
					{					
					$xa=substr($pdb1[$a],30,8);
					$ya=substr($pdb1[$a],38,8);
					$za=substr($pdb1[$a],46,8);
					$cadist=sqrt(($xa-$COMX)**2+($ya-$COMY)**2+($za-$COMZ)**2);
#					print "$pdb1[$a] $cadist\n";						
					}	
					elsif (grep(/\bCB\b/,$pdb1[$a]))
					{
					$xb=substr($pdb1[$a],30,8);
					$yb=substr($pdb1[$a],38,8);
					$zb=substr($pdb1[$a],46,8);
					$cbdist=sqrt(($xb-$COMX)**2+($yb-$COMY)**2+($zb-$COMZ)**2);
#					print "$pdb1[$a] $cbdist\n";
					}
				}
			}
			if (($cbdist==0)||($cadist==0))
			{
			push (@orient,"-");
			}
			elsif ($cbdist<=$cadist)
			{
			push (@orient,"I");
			}
			elsif ($cbdist>$cadist)
			{
			push (@orient,"O");
			}
		}
@orient;		
}

sub rad_to_degree
{
my $rad=$_[0];
my $deg=($rad*45)/atan2(1,1);
}

#@vect=&Ca_Cb_vector($inf,$centre_of_mass);
#print @vect,"\n";
sub Ca_Cb_vector
{
use Math::Trig;
undef @orient2;
	my $input=$_[0];
	my $center=$_[1];
	$center=~s/^\s+|\s+$//g;
	my @cent=split(/\s+/,$center);
	my $xo=$cent[0];
	my $yo=$cent[1];
	my $zo=$cent[2];
	my $x,$y,$xa,$ya,$za,$xb,$yb,$zb;
	my $dot_prod,$cos_theta,$theta_rad,$theta_degree; 
	my $atom,$atom2,$resi_no2,$line2,@pdb2,$no2,$resi2;	
	open (PDB,"$input")|| die ("cannot open");
	@PDB=<PDB>;
	chomp(@PDB);
		foreach $line2(@PDB)
		{
			if (substr($line2,0,6) eq "ATOM  ")
			{	
			push (@pdb2,$line2);
			$resi_no2=substr($line2,22,5);
			$resi_no2=~s/^\s+|\s+$//g;
				if (!grep(/$resi_no2/,@residue2))
				{
				push (@residue2,$resi_no2);
				}
			}
		}
		foreach $no2(@residue2)
		{
		my $magAO=$magAB=0;
			for($x=0;$x<@pdb2;$x++)
			{
			$resi2=substr($pdb2[$x],22,5);
			$resi2=~s/^\s+|\s+$//g;	
				if($resi2 eq $no2)
				{
					if (grep(/\bCA\b/,$pdb2[$x]))
					{
					$xa=substr($pdb2[$x],30,8);
					$ya=substr($pdb2[$x],38,8);
					$za=substr($pdb2[$x],46,8);
					$magAO=sqrt(($xo-$xa)**2 +($yo-$ya)**2 +($zo-$za)**2);						
					}	
					elsif (grep(/\bCB\b/,$pdb2[$x]))
					{
					$xb=substr($pdb2[$x],30,8);
					$yb=substr($pdb2[$x],38,8);
					$zb=substr($pdb2[$x],46,8);
					$magAB=sqrt(($xb-$xa)**2 +($yb-$ya)**2 +($zb-$za)**2);
					}
				}
			}
			if (($magAO==0)||($magAB==0))
			{
			push (@orient2,"-");	
			}
			else
			{
			$dot_prod=(($xo-$xa)*($xb-$xa)+($yo-$ya)*($yb-$ya)+($zo-$za)*($zb-$za));
			$cos_theta=($dot_prod/($magAO*$magAB));
			$theta_rad=acos($cos_theta);
			$theta_degree=&rad_to_degree($theta_rad);
				if ($theta_degree<=90)			
				{				
				push (@orient2,"I");	
				}
				else 
				{				
				push (@orient2,"O");	
				}
			}
		}
@orient2;
}

#@pdb1=`grep -w 'CA\\|CB' $input`;
#$rad=&degree_to_rad($degree);
#This subroutine converts degrees to radians.
#sub degree_to_rad
#{
#my $deg=$_[0];
#my $radian=(atan2(1,1)*$deg)/45;
#}
