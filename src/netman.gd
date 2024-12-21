extends Node

enum GameStatus {
	NONE,
	SERVER,
	CLIENT,
}

enum ActionType {
	NONE,
	MOVE,
	SPAWN_ROBOT,
	STOP
}


var status: GameStatus = GameStatus.NONE

func setup_client() -> void:
	var peer = ENetMultiplayerPeer.new()
	peer.create_client("localhost", 7777)
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(on_peer_connected)
	Utils.debug_print("Client has been set up")
	
func setup_server() -> void:
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(7777)
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(on_peer_connected)
	Utils.get_PB_world().peer_side_map.set_pair(1, 1) # The host is yellow
	Utils.debug_print("Server has been set up")

func on_peer_connected(id: int) -> void:
	if multiplayer.is_server():
		var peers_number: int = Utils.get_PB_world().peer_side_map._peer_to_side.size()
		assert(peers_number <= 3) # Max 4 players!
		Utils.get_PB_world().peer_side_map.set_pair(id, peers_number + 1) # Next color is the peer
		update_peer_id_side_id_bindings.rpc(Utils.get_PB_world().peer_side_map._peer_to_side)
	
	Utils.debug_print("This peer ID = " + str(multiplayer.get_unique_id()), true)
	Utils.debug_print("Peer Connected = " + str(id))

@rpc("authority", "call_remote", "reliable")
func update_peer_id_side_id_bindings(peer_to_side_map: Dictionary):
	Utils.get_PB_world().peer_side_map._peer_to_side = peer_to_side_map

#@rpc("any_peer", "call_remote", "unreliable")
#func send_input(input):
	#pass

## Called when the node enters the scene tree for the first time.
#func _ready() -> void:
	#if 
#
#
## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass
