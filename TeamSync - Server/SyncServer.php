<?php
namespace App\Net\Subprotocols;
require_once __DIR__ . '/config.php';
require_once __DIR__ . '/App/Net/ServerObserver.php';
require_once __DIR__ . '/App/Net/ConnectionObserver.php';
require_once __DIR__ . '/App/Net/WebSocketConnection.php';
require_once __DIR__ . '/App/Net/WebSocketServer.php';
require_once __DIR__ . '/App/Web/HttpCookie.php';
require_once __DIR__ . '/libraries/class.db.php';
require_once __DIR__ . '/models/auth.php';
require_once __DIR__ . '/models/playlist.php';

class SyncServer implements \App\Net\ServerObserver, \App\Net\ConnectionObserver
{

	/**
	 * The information regarding connected clients will be stored in this array
	 *
	 * @var array Information about the connected clients
	 */
	protected $m_aClients              = array();

	/**
	 * @var WebSocketServer The WebSocketServer instance
	 */
	protected $m_pServer;

	/**
	 * @var int We don't want to send pings during every loop
	 */
	protected $m_nPingCounter          = 0;
	
	/**
	 * 
	 * For creating web socket logs
	 * @var string
	 */
	protected $correct_return          = "\n"; 

	protected $fplog;
	
	
	private $auth_id = false;
	
	private $auth;
	
	private $playlist;
	
	private $username = array();
	
	private $connection_port;
	
	/**
	 * @var dbcon the database instance
	 */
	private $dbcon;
	
	/**
	 * The SyncServer constructor
	 *
	 * @param string $sHost The host or IP that should be used by the server
	 * @param int $nPort The port that should be used by the server
	 */
	public function __construct($sHost, $nPort, $auth_id = false)
	{

		/* Create a db instance */
		global $host, $pass, $database, $user;
		$this -> dbcon = new \db("mysql:host=$host;port=3306;dbname=$database", "$pass", "$user");
		#$this -> dbcon = new \db("mysql:host=localhost;port=3306;dbname=teamsync", "teamsync", "teamsync");

		if($auth_id)
		{
			$this -> auth_id = $auth_id;
			$this -> auth = new \Auth($this -> dbcon);
			$this -> playlist = new \Playlist($this -> dbcon);
			$this -> connection_port = $nPort;
		}

		/* Create a WebSocketServer instance */
		$this -> m_pServer = new \App\Net\WebSocketServer($sHost, $nPort, false);

		/* Subscribe to events on the server */
		$this -> m_pServer -> subscribe($this);
		
		/* define server OS */
		if (strtoupper(substr(PHP_OS,0,3)) === "WIN")
		{
			$this -> correct_return = "\r\n";
		}
		else 
		{
			$this -> correct_return = "\n";
		}
		
	}
	
	/**
	* The start method will open the WebSocketServer and loop
	* to accept incoming connections and to read data from the already
	* connected clients.
	*/
	public function start()
	{
		/* open/create file for log the sever states */ 
		if(file_exists($this->get_file_path('data') . 'server.log') === true) 
		{
			$this->fplog = fopen($this->get_file_path('data') . 'server.log', 'a+');
		}
		else
		{
			$this->fplog = fopen($this->get_file_path('data') . 'server.log', 'w');		
		}		
		chmod($this->get_file_path('data') . 'server.log', 0777);
		
		/* Open the server and start listening */
		if (!$this -> m_pServer -> open()) 
		{
			die();
		}
		
		if ($this -> auth_id) 
		{			
			$pid = getmypid();						
			$this-> username = $this -> auth -> get_auth_name($this -> auth_id, 'login');
			$this -> auth -> update_auth($this -> auth_id, array('active' => 'yes', 'server_pid' => $pid, 'port' => $this -> connection_port));			
		}
		
		/* Keep looping */
		while (true) {
			 
			/* Give the CPU some breath */
			usleep(40000);
	
			/* Accept new connections */
			$this -> m_pServer -> accept();
	
			/* Cycle all connected clients, this will read from the sockets and process
			 * the data. If something happens, an event will be raised */
			foreach ($this -> m_aClients as $aClient)
			{
				$aClient['object'] -> cycle();
			}
	
			$this -> m_nPingCounter++;
	
			if ($this -> m_nPingCounter > 500)
			{
				/* Detect lost connections */
				$this -> doPings();
	
				/* Reset counter */
				$this -> m_nPingCounter = 0;
			}	
		}	
	}
	
	
	/**
	* This method will be called by the connected clients when they recieved a message
	* because we subscribed to them.
	*
	* @param WebSocketConnection $pConnection The connection on which the event accured
	* @param int $nType The message type
	* @param string $sData The message data
	*/
	public function onMessage(\App\Net\WebSocketConnection $pConnection, $nType, $sData)
	{
	
		/* Keep track of the last activity */
		$this -> m_aClients[$this -> getUid($pConnection)]['last_message'] = time();
		
		/* Split the command and the message */
		$aParts = explode(' ', $sData, 2);
		/* Handle the command further */
		switch ($aParts[0])
		{
			case 'MESSAGE':
				$this -> processMessage($pConnection, $aParts[1]);
				break;
			case 'NICKCHANGE':
				$this -> processNick($pConnection, $aParts[1]);
				break;
			case 'CLOSE':
		//		$this -> onClose($pConnection, 'becouse');
				unset($this -> m_aClients[$this -> getUid($pConnection)]);
				$this -> dispatchUserList();
				break;

		}
	}
	
	/**
	* This method will be called by the connected clients when they are closed
	* because we subscribed to them.
	*
	* @param WebSocketConnection $pConnection The connection on which the event accured

	*/
	public function onClose(\App\Net\WebSocketConnection $pConnection, $nReason, $sReason)
	{
	
		/* This method takes a hash of the host and port so we have a unique identifier
		 * for each connection */
		$sUid = static :: getUid($pConnection);
	
		/* If this client was active (the opening handshake was completed), inform other
		 * users. */
		if ($this -> m_aClients[$sUid]['active'] == true)
		{
			$this -> dispatch('DISCONNECT ' . $this -> m_aClients[$sUid]['nick']);
		}

		
		if($this -> m_aClients[$sUid]['nick'] == $this->username['login'])
		{
		    fclose($this->fplog);
		    $this -> auth -> update_auth($this -> auth_id, array('active' => 'no', 'server_pid' => null, 'port' => null));
		    $playlist_id = $this -> playlist -> get_playlist_id($this -> auth_id, 'id');
		    $this -> playlist -> delete_pl_tr($playlist_id['id']);
		    die('server was die.');
		}
		fputs($this->fplog, date("Y-m-d, H:i").' -- Connection closed ( ' . $pConnection -> getHost() . '). Reason: ' . $nReason . $this->correct_return);
		/* Remove the connection from the clients list */
		unset($this -> m_aClients[$sUid]);
	
		/* Send out a new, updated userlist */
		$this -> dispatchUserList();
	
		/* Output to console */
		//echo 'Connection closed (' . $pConnection -> getHost() . '). Reason: ' . $nReason . PHP_EOL;
	}
	
	/**
	* This method will be called by the connected clients when they recieve a ping control frame
	* because we subscribed to them.
	*
	* @param WebSocketConnection $pConnection The connection on which the event accured
	*/
	public function onPing(\App\Net\WebSocketConnection $pConnection)
	{
		/* Keep track of the last activity */
		$this -> m_aClients[$this -> getUid($pConnection)]['last_message'] = time();
	
		echo 'The server received a ping from ' . $pConnection -> getHost() . PHP_EOL;
	}
	
	/**
	* This method will be called by the connected clients when they recieve a ping control frame
	* because we subscribed to them.
	*
	* @param WebSocketConnection $pConnection The connection on which the event accured
	*/
	public function onPong(\App\Net\WebSocketConnection $pConnection)
	{
		/* Keep track of the last activity */
		$this -> m_aClients[$this -> getUid($pConnection)]['last_message'] = time();
	
		echo 'The server received a pong from ' . $pConnection -> getHost() . PHP_EOL;
	}
	
	/**
	* This method will be called by the connected clients when they recieved the opening
	* handshake because we subscribed to them. Cookies that need to be set on the client
	* should be set in the WebSocketObject here.
	*
	* @param WebSocketConnection $pConnection The connection on which the event accured
	*/
	public function onHandshakeRecieved(\App\Net\WebSocketConnection $pConnection)
	{
		echo 'Read the handshake from ' . $pConnection -> getHost() . PHP_EOL;
	}
	
	/**
	* This method will be called by the connected clients when the opening handshake has
	* been completed. The WebSocketConnection is now open.
	*
	* @param WebSocketConnection $pConnection The connection on which the event accured
	*/
	public function onOpen(\App\Net\WebSocketConnection $pConnection)
	{
		/* This method takes a hash of the host and port so we have a unique identifier
		 * for each connection */
		$sUid = self :: getUid($pConnection);
	
		/* Set the connection status to active. We now can start sending data */
		$this -> m_aClients[$sUid]['active'] = true;
	
		/* Assign a random nickname */
		$this -> m_aClients[$sUid]['nick'] = 'waite_for_update_nickname_' . mt_rand(10, 99);
		 
		/* Inform other users of this new soul */
		$this -> dispatch('CONNECT ' . $this -> m_aClients[$sUid]['nick'], array($pConnection));
	
		/* Send an updated userlist as well */
		$this -> dispatchUserList();
		 
		/* Output to the console */
		echo 'Added ' . $pConnection -> getHost() . ' to clients list' . PHP_EOL;
	}
	
	public function onNewConnection(\App\Net\WebSocketServer $pServer, \App\Net\WebSocketConnection $pConnection)
	{
	
		/* This method takes a hash of the host and port so we have a unique identifier
		 * for each connection */
		$sUid = static :: getUid($pConnection);
		 
		/* Store the WebSocketConnection object */
		$this -> m_aClients[$sUid]['object'] = $pConnection;
		 
		/* keep track of the last action on the socket */
		$this -> m_aClients[$sUid]['last_message'] = time();
		 
		/* The TCP connection is open but the WebSocket handshake is not complete yet! */
		$this -> m_aClients[$sUid]['active'] = false;
		 
		/* Subscribe to events on the new WebSocketConnection */
		$pConnection -> subscribe($this);
		 
		/* Output to the console */
		echo 'New connection from ' . $pConnection -> getHost() . PHP_EOL;
		
		fputs($this->fplog, date("Y-m-d, H:i").' -- New connection from ' . $pConnection -> getHost() . $this->correct_return);
	}
	
	/**
	* This method will be called by the server object when the server is open and starts
	* listening for incoming connections.
	*
	* @param WebSocketServer $pServer The server object that was opened
	*/
	public function onServerOpen(\App\Net\WebSocketServer $pServer)
	{
		echo 'The server is now listening' . PHP_EOL;
		fputs($this->fplog, date("Y-m-d, H:i").' --  The server is now listening' . $this->correct_return);
	}
	
	/**
	* This method will be called by the server object when the server closed
	*
	* @param WebSocketServer $pServer The server object that was closed
	*/
	public function onServerClose(\App\Net\WebSocketServer $pServer)
	{
		echo 'The server is now closed' . PHP_EOL;
		fputs($this->fplog, date("Y-m-d, H:i").' --  The server is now closed' . $this->correct_return);
		fclose($this->fplog);
	}
	
	/**
	* This method will distribute a message that was send to the server to all
	* connected clients.
	*
	* @param WebSocketConnection $pConnection The object that has send the message
	* @param string $sMessage The message that was send
	*/
	public function processMessage(\App\Net\WebSocketConnection $pConnection, $sMessage)
	{
	
		/* Ignore empty messages */
		if ($sMessage != '')
		{
			/* Format the new message so the clients understand it */
			$sResponse = sprintf('MESSAGE %s %s', $this -> m_aClients[static :: getUid($pConnection)]['nick'], $sMessage);
	
			/* Dispatch to all connected (active) clients */
			$this -> dispatch($sResponse);
		}	
        
    }
    
    /**
     * This method is called when a connection we are observing send a message that
     * had a CHANGENICK command in it.
     *
     * @param WebSocketConnection $pConnection The object that requested the nickchange
     * @param string $sMessage The message that was send
     */
    public function processNick(\App\Net\WebSocketConnection $pConnection, $sNick)
    {
        
        /* Ignore empty nicks */
        if ($sNick == '')
        {
            return;
        }
        
        /* Only use the first part, ignore the rest */
        $sNick = explode(' ', $sNick);
        $sNick = $sNick[0];
        
        /* We need to make sure the username isn't already in use by someone */
        $bInUse = false;
        
        /* Loop through all clients and compare the nickname */
        foreach ($this -> m_aClients as $aClient)
        {
            if ($aClient['nick'] == $sNick)
            {
                $bInUse = true;
                break;
            }
        }
        
        /* If at this point the $bInUse var is still false, all is well */
        if (!$bInUse)
        {
            
            /* Update the nickname in our information array */
            $this -> m_aClients[static :: getUid($pConnection)]['nick'] = $sNick;
        
            /* Send the new userlist */
            $this -> dispatchUserList();
        }
        else
        {
            /* This nickname is already in use, inform the user */
            $pConnection -> send(\App\Net\WebSocketFrame :: TYPE_TEXT, 'NICKINUSE');
        }
        
	}
	
	/**
	* This method builds a comma separated list of names and sends it to all
	* connected clients.
	*/
	public function dispatchUserList()
	{
		/* All nicknames will be in here */
		$aUsers = array();
	
		/* Fill the array with nicknames */
		foreach ($this -> m_aClients as $aClient)
		{
			if ($aClient['active'] == true)
			{
				$aUsers[] = $aClient['nick'];
			}
		}
	
		/* Turn the array in a comma-separated list of values */
		$sUserList = sprintf('USERLIST %s', implode(',', $aUsers));
	
		/* Send the new list to all connected clients */
		$this -> dispatch($sUserList);
	}
	
	/**
	* This method will send the message to all connected clients.
	*
	* @param string $sMessage The message that will be send
	* @param array $aExept WebSocketConnection objects in this array will be excluded
	*/
	public function dispatch($sMessage, array $aExcept = null)
	{
		/* Loop through all connected clients */
		foreach ($this -> m_aClients as $aClient)
		{
			/* If the current client is active and not on the exception list, send the message */
			if (!($aExcept !== null && in_array($aClient['object'], $aExcept)) && $aClient['active'] == true)
			{
				echo $sMessage;
				fputs($this->fplog, date("Y-m-d, H:i").' -- ' . $sMessage . $this->correct_return);
				$aClient['object'] -> send(\App\Net\WebSocketFrame :: TYPE_TEXT, $sMessage);
			}
		}
	}
	
	/**
	* This method will send a ping to all connections that haven't send anything
	* in the last minute. When we don't recieve any data from a connection after
	* two minutes, we close the connection. The client most likely has timed-out.
	*/
	protected function doPings()
	{
		/* Loop through all connected clients */
		foreach ($this -> m_aClients as $aClient)
		{
			/* If no message was recieved from this client in the last two minutes, close it */
			if ((time() - $aClient['last_message']) > 120)
			{
				$aClient['object'] -> disconnect();
			}
			elseif ((time() - $aClient['last_message']) >= 60)
			{
				/* If no message was recieved from this client in the last minute, ping it */
				$aClient['object'] -> ping();
			}
		}
	}
	
	/**
	* We cannot use WebSocketConnection objects as indexes for arrays. This
	* static function will use the remote client's host and IP to generate
	* a unique hash.
	*
	* @return string The unique hash
	*/
	protected static function getUid($pConnection)
	{
		return md5($pConnection -> getHost() . $pConnection -> getPort());
	}
	
	protected function get_file_path($data_path) 
	{
		$year_path = $data_path . "/" . date("Y") . "/";
		$month_path = $year_path . date("m") . "/";
		$day_path = $month_path . date("d") . "_";
		$this->get_dir_path($data_path);
		$this->get_dir_path($year_path);
		$this->get_dir_path($month_path);
		return $day_path;
	}
	
	protected function get_dir_path($item_path) 
	{
		$item=@scandir($item_path);
		if(!$item) {
			@mkdir($item_path, 0777);
			$item=@scandir($item_path);
		}
		else @chmod($item_path, 0777);
	}
	
	
	
}
