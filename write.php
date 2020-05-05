<?php
$tan=$_GET['tan'];
$key=$_GET['key'];
$netkey=$_GET['netkey'];

$host = "localhost";
$benutzer = '***USER***';
$passwort = '***PASSWORD***';
$bindung = mysqli_connect($host, $benutzer, $passwort) or die("Verbindungsaufbau zur Daten-Zentrale nicht m&ouml;glich!");
$db = '***DATABASE***';

function mdq($bindung, $query)
{
    mysqli_select_db($bindung, '***DATABASE***');
    return mysqli_query($bindung, $query);
}

$sql = "delete from binaryENC where tan='$tan';";
$ask = mdq($bindung, $sql);

$sql = "insert into binaryENC set tan='$tan', nk='$netkey', pk='$key';";
$ask = mdq($bindung, $sql);

echo '1';

?>
