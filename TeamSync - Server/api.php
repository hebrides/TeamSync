<?php
error_log(implode(" ", $_POST));
require_once(dirname(__FILE__).'/api/RestRequest.php');
require_once(dirname(__FILE__).'/api/RestUtils.php');
require_once(dirname(__FILE__).'/libraries/class.db.php');
require_once(dirname(__FILE__).'/models/auth.php');
require_once(dirname(__FILE__).'/models/track.php');
require_once(dirname(__FILE__).'/models/playlist.php');

$dbcon = new db("mysql:host=127.0.0.1;dbname=teamsync", "teamsync", "teamsync");
$dbcon->setErrorCallbackFunction("echo");
if($dbcon == null)
    error_log("dbconn in api.php is null!");

$auth = new auth($dbcon);

if(isset($_GET['token']) && $_GET['token'] != '')
{
	$auth_id = $auth->get_auth(trim($_GET['token']), 'id, port');
	if(!$auth_id) die(RestUtils::sendResponse(401));
}

$data = RestUtils::processRequest();
$datas = $data->getRequestVars();

switch($data->getMethod()) {
	case 'get':
			die(RestUtils::sendResponse(501));

	case 'post':
		if($data->getHttpAccept() == 'json') {
			$get_data = $data->getData();

			if(isset($get_data['signup']) && !empty($get_data['signup']))
			{
				$auth_id = $auth->get_auth_master_id($get_data['signup']['username'], 'id');
				if($auth_id) die(RestUtils::sendResponse('auth_error'));

				$auth_item = array(
								'login' => $get_data['signup']['username'],
								'password' => md5(trim($get_data['signup']['password'])),
								'email' => $get_data['signup']['email']);

				$auth->insert_auth($auth_item);
				RestUtils::sendResponse(200, json_encode(array('request' => 'successful')), 'application/json');
			}

			if(!isset($_GET['token']))
			{
				if(!isset($get_data['login']['username']) or !isset($get_data['login']['password'])) die(RestUtils::sendResponse(401));
				$auth_id = $auth->get_auth_master_id($get_data['login']['username'], 'id', md5(trim($get_data['login']['password'])));

				if(!$auth_id) 
				{
					die(RestUtils::sendResponse(401));		
				}
				else
				{
					$salt = md5(mktime() . mt_rand(10, 999));
					$auth->update_auth($auth_id['id'], array('token' => $salt, 'role' => $get_data['role']));
					RestUtils::sendResponse(200, json_encode(array('token' => $salt)), 'application/json');
				}
			}			
			
			
		
			if(isset($get_data['role']) && $get_data['role'] == 'master')
			{
				$track = new track($dbcon);
				$playlist = new playlist($dbcon);						
				$playlists = $tracks = '';

				$playlist_id = $playlist->get_playlist($get_data['playlist']['title'], $auth_id['id'], 'id');				
				$pl_item = array(
								'auth_id' => $auth_id['id'],
								'title' => $get_data['playlist']['title'],
								'description' => $get_data['playlist']['desc'],
								'last_update' => mktime());				
				if(!$playlist_id)
				{
					$playlist_id['id'] = $playlist->insert_playlist($pl_item);
				}
				else
				{
					$playlist -> delete_pl_tr($playlist_id['id']);
					$playlist->update_playlist($playlist_id['id'], $pl_item);
				}
				
				
				foreach($get_data['playlist']['tracks'] as $val)
				{
		//			$track_id = $track->get_track_itunes($val['service'], $val['itunesid'], 'id');
					$track_id = $track->get_track_ipod($val['service'], $val['artistName'], $val['genreName'], $val['title'], 'id, orderid');
					$track_item = array(
										'service' => $val['service'],
										'audio_url' => $val['audioUrl'],
										'artist_name' => $val['artistName'],
										'genre_name' => $val['genreName'],
										'length' => $val['length'],
										'image_url' => $val['imageUrl'],
										'orderid' => $val['order'],
										'release_date' => $val['releaseDate'],
										'title'	=> $val['title'],
										'itunesid' => $val['itunesid']);
					if(!$track_id || empty($track_id))
					{
						$track_id['id'] = $track->insert_track($track_item);
					}
					else 
					{
						$track->update_track($track_id['id'], $track_item);						
					}
					
					/* insert/update many-to-many relations between track and playlist tables */ 
					$pl_tr_id = $playlist -> get_pl_tr_id($playlist_id['id'], $track_id['id'], 'id');
					$pl_tr_item = array(
										'playlist_id' => $playlist_id['id'],
										'track_id' => $track_id['id'],
										'orderid' => $val['order']);
					if(!$pl_tr_id or ($track_id['orderid'] != $val['order']))
					{				
						$playlist -> insert_pl_tr($pl_tr_item);
					}
					else
					{
						$playlist -> update_pl_tr($pl_tr_id['id'], $pl_tr_item);
					}
				}

				$server_port = $auth -> get_active_masters('MAX(port) AS port');
				if($server_port[0]['port'] != null && $auth_id['port'] == null)
				{
					$new_port = $server_port[0]['port'] + 1;
				}
				elseif($auth_id['port'] != null)
				{
					$new_port = $auth_id['port'];
				}
				else
				{
					$new_port = 8090;
				}

				$pathh = "/var/www/StartSync.php {$auth_id['id']} '0.0.0.0' {$new_port}";
				error_log("Starting Sync server on port $new_port for ID: {$auth_id['id']}");
				exec("php -f $pathh >/dev/null &");
				sleep(2);

				$results['connection'] = array('ip' => '66.228.33.88', 'port' => $new_port);

				RestUtils::sendResponse(200, json_encode($results), 'application/json');

			}
			if(isset($get_data['role']) && $get_data['role'] == 'slave')
			{
				$active_masters = $auth -> get_active_masters('login, id, server_pid, port');
				$active_masters_res = array();
				foreach($active_masters as $val)
				{
					if(!file_exists("/proc/{$val['server_pid']}"))
					{
						$auth -> update_auth($val['id'], array('active' => 'no', 'server_pid' => null, 'port' => null));
					}				
					else
					{
						$active_masters_res[] = array(
													'login' => $val['login'],
													'id' => $val['id'],
													'server_url' => '66.228.33.88',
													'port' => $val['port']);
					}
				}				
				if(isset($get_data['master_id']))
				{
					$playlist = new playlist($dbcon);
					$track = new track($dbcon);
					$get_playlist = $playlist -> get_slave_playlist($get_data['master_id'], 'id, title, description, last_update');
					
					$get_tracks = $track -> get_slave_tracks($get_playlist['id'], 't.*');
				
					$get_playlist['tracks'] = $get_tracks;
					RestUtils::sendResponse(200, json_encode($get_playlist), 'application/json');
					
				}
				
				RestUtils::sendResponse(200, json_encode($active_masters_res), 'application/json');
			}
						
		}
		break;
}
?>
