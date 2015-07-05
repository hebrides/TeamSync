<?php
class Track {
	
	private $db;

	function __construct(db $dbcon)
	{
		$this->db = $dbcon;
	}

	public function update_track($id, $data)
	{
		if(!$data || !$id) return;
		return $this->db->update('tracks', $data, "id = {$id}");
	}
	public function insert_track($data)
	{
		if(!$data) return;
		$last_id = $this->db->insert('tracks', $data);
		return $last_id;
	}

	public function delete_track($id)
	{
		if(!$id) return;
		return $this->db->delete('tracks', "id = {$id}");
	}
	
	public function get_track_itunes($service, $serviceid, $fileds = '')
	{
		$result = $this->db->select("tracks", "service = '{$service}' AND itunesid = '{$serviceid}'", '', $fileds);
		if(isset($result) && !empty($result)) return $result[0]; else return FALSE;
	}
	
	public function get_track_ipod($service, $artist, $genre, $title, $fileds = '')
	{
		$result = $this->db->select("tracks", "service = '{$service}' AND artist_name = '{$artist}' AND genre_name = '{$genre}' AND title = '{$title}'", '', $fileds);
		if(isset($result) && !empty($result)) return $result[0]; else return FALSE;
	}
/*
	public function get_tracks($ids)
	{
		$result = $this->db->select("tracks", "id IN ({$ids})");
		if(isset($result) && !empty($result)) return $result; else return FALSE;
	}
*/
	
	
	/* methods for playlist_tracks table */
	public function get_slave_tracks($playlist_id, $filds = '')
	{
		$result = $this->db->select("playlists_tracks AS pl_tr LEFT JOIN tracks AS t ON t.id = pl_tr.track_id", "pl_tr.playlist_id = {$playlist_id}", '', $filds, "pl_tr.orderid ASC");
		
		if(isset($result) && !empty($result)) return $result; 
		else return FALSE;
	}
}
?>