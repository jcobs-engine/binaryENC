<?php
$tan=$_GET['tan'];
$key=$_GET['key'];

$host = "localhost";
$benutzer = '***USER***';
$passwort = '***PASSWD***';
$bindung = mysqli_connect($host, $benutzer, $passwort) or die("Verbindungsaufbau zur Daten-Zentrale nicht m&ouml;glich!");
$db = '***DATABASE***';

function mdq($bindung, $query)
{
    mysqli_select_db($bindung, '***DATABASE***');
    return mysqli_query($bindung, $query);
}

$sql = "select nk from binaryENC where tan='$tan' and pk='$key';";
$ask = mdq($bindung, $sql);
while ($row = mysqli_fetch_row($ask)) {
    echo $row[0];
}

$sql = "delete from binaryENC where tan='$tan';";
$ask = mdq($bindung, $sql);

?>
