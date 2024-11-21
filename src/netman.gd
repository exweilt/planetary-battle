extends Node

enum GameStatus {
	NONE,
	SERVER,
	CLIENT,
}

enum ActionType {
	NONE,
	MOVE,
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
	Utils.debug_print("Server has been set up")

func on_peer_connected(id: int) -> void:
	Utils.debug_print("This peer ID = " + str(multiplayer.get_unique_id()), true)
	Utils.debug_print("Peer Connected = " + str(id))


## Called when the node enters the scene tree for the first time.
#func _ready() -> void:
	#pass # Replace with function body.
#
#
## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass
