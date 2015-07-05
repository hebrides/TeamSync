<?php
require_once __DIR__ . '/SyncServer.php';


/*
 * The SyncServer class provides a small synchronization server that is build
* on top of a PHP WebSockets server and thus uses the WebSockets protocol.
*/

$auth_id = trim($argv[1]);
$server_url = trim($argv[2]);
$server_port = trim($argv[3]);

$pSyncServer = new App\Net\Subprotocols\SyncServer($server_url, $server_port, $auth_id);
$pSyncServer -> start();

?>