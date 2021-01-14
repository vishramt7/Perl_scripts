#Only repulsive

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
		$Rep=(($sigma/$r)**12);
		$Db=0;
		$Potential=$Rep+$Db;
		print ("$r $Potential\n");
		}
		else
		{
		print ("$r 0\n");
		}
	}
