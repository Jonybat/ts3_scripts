<?php
// load framework files
require_once("/opt/ts3php/libraries/TeamSpeak3/TeamSpeak3.php");

// load config file
require_once(".config.php");

try
{
  $server = $argv[1];
  $instance = $argv[2];

  $user = "user_" . $server . "-" . $instance;
  $pass = "pass_" . $server . "-" . $instance;
  $host = "host_" . $server;
  $query = "query_" . $server;
  $voice = "voice_" . $server . "-" . $instance;

  // IPv4 connection URI
  $uri = "serverquery://" . $cfg[ $user ] . ":" . $cfg[ $pass ] . "@" . $cfg[ $host ] . ":" . $cfg[ $query ] . "/?server_port=" . $cfg[ $voice ] . "";

  // connect to above specified server, authenticate and spawn an object for the virtual server on port 9987
  $ts3_VirtualServer = TeamSpeak3::factory($uri);

  // do the thing
  $arr_ClientList = $ts3_VirtualServer->clientList(array("client_type" => "0"));
  foreach($arr_ClientList as $ts3_Client)
  {
    echo $ts3_Client . "\n";
  }
}
catch(TeamSpeak3_Exception $e)
{
  // print the error message returned by the server
  echo "Error " . $e->getCode() . ": " . $e->getMessage();
}
?>
