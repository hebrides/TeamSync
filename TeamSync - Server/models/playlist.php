	<?php
class Playlist {
	
	private $db;

	function __construct(db $dbcon)
	{
		$this->db = $dbcon;
	}
	
	public function update_playlist($id, $data)
	{
		if(!$data || !$id) return;
		return $this->db->update('playlists', $data, "id = {$id}");
	}
	public function insert_playlist($data)
	{
		if(!$data) return;
		$last_id = $this->db->insert('playlists', $data);
		return $last_id;
	}
	public function delete_playlist($id)
	{
		if(!$id) return;
		return $this->db->delete('playlists', "id = {$id}");
	}
	public function get_playlist($title, $master_id, $fileds='')
	{
		$result = $this->db->select("playlists", "title = '{$title}' AND auth_id = {$master_id}", '', $fileds);
		if(isset($result) && !empty($result)) return $result[0]; else return FALSE;
	}
	public function get_slave_playlist($master_id, $fileds='')
	{
		$result = $this->db->select("playlists", "auth_id = {$master_id} AND last_update = (SELECT MAX(last_update) FROM playlists WHERE auth_id = {$master_id})", '', $fileds);
		if(isset($result) && !empty($result)) return $result[0]; else return FALSE;
	}
	
	
	public function get_playlist_id($master_id, $fileds='')
	{
		$result = $this->db->select("playlists", "auth_id = {$master_id}", '', $fileds);
		if(isset($result) && !empty($result)) return $result[0]; else return FALSE;
	}
	
	
/* methods for playlist_tracks table */
	
	public function delete_pl_tr($id)
	{
		if(!$id) return;
		return $this->db->delete('playlists_tracks', "playlist_id = {$id}");
	}
	
	public function get_pl_tr_id($playlist_id, $track_id, $fileds='')
	{
		$result = $this->db->select("playlists_tracks", "playlist_id = {$playlist_id} AND track_id = {$track_id}", '', $fileds);
		if(isset($result) && !empty($result)) return $result[0]; else return FALSE;
	}
	public function insert_pl_tr($data)
	{
		if(!$data) return;
		$last_id = $this->db->insert('playlists_tracks', $data);
		return $last_id;
	}
	public function update_pl_tr($id, $data)
	{
		if(!$data || !$id) return;
		return $this->db->update('playlists_tracks', $data, "id = {$id}");
	}
		
}
?>