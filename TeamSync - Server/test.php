<?php 

$pid = 22580;


if( file_exists( "/proc/$pid" ))
{
echo 'exist!!!!';
}
else {
	echo 'ne exist';
}

?>