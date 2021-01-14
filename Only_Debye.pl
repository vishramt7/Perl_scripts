# Only Debye


$K=33.2;
$Bk=1;
$kappa=0.71554;
$sigma=0.4;
$Qi=1;
$Qj=1;
$Epsi=50;
for ($i=0;$i<=10500;$i++)
	{
	$r=$i*0.002;
		if ($r>=0.04)
		{
		$Exp=exp(-($kappa*$r));	
		#$Rep=(($sigma/$r)**12);
		$Db=(($K*$Bk*$Qi*$Qj*$Exp)/($Epsi*$r));
		$Potential=$Db;
		$Nderi=(($Db*(1+$kappa*($r)))/$r);		
		print ("$r $Potential\n");
		}
		else
		{
		print ("$r 0\n");
		}
	}
