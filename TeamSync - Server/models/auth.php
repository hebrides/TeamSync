<?php
class Auth {
	
	private $db;

	function __construct(db $dbcon)
	{
		$this->db = $dbcon;
	}
	
	public function update_auth($id, $data, $salt = FALSE)
	{
		if(!$data || !$id) return;
		if($salt)
		{
			return $this->db->update('auth', $data, "id = {$id}");
		}
		else
		{
			return $this->db->update('auth', $data, "id = {$id}");
		}
	}	
	public function insert_auth($data)
	{
		if(!$data) return;
		return $last_id = $this->db->insert('auth', $data);
	}
	public function get_active_masters($fileds = '')
	{
		$result = $this->db->select("auth", "active = 'yes' AND server_pid IS NOT NULL", '', $fileds);
		if(isset($result) && !empty($result)) return $result; else return FALSE;
	}
	public function get_auth_master_id($login, $fileds = '', $passwd = FALSE)
	{
		if($passwd !== FALSE) $passwd = " AND password = '{$passwd}'";
		$result = $this->db->select("auth", "login = '{$login}'{$passwd}", '', $fileds);
		if(isset($result) && !empty($result)) return $result[0]; else return FALSE;
	}
	public function get_auth($token, $fileds = '')
	{
		$result = $this->db->select("auth", "token = '{$token}'", '', $fileds);
		if(isset($result) && !empty($result)) return $result[0]; else return FALSE;
	}
	public function get_auth_name($id, $fileds = '')
	{
		$result = $this->db->select("auth", "id = '{$id}'", '', $fileds);
		if(isset($result) && !empty($result)) return $result[0]; else return FALSE;
	}
}
?>
