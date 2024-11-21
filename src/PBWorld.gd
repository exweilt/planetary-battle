class_name PBWorld extends Node

#@onready var time: float = 0.0
@onready var ticks: int = 0

var registered_nodes: Array[Node3D] = []

func register_node(node: Node3D) -> void:
	if node != null and node.has_method("pb_process"):
		registered_nodes.append(node)
		
class MoveAction:
	var action_type = Netman.ActionType.MOVE
	var robot_id: int = 0
	var destination: Vector3 = Vector3.ZERO
	var time: int = 0
	
	func _init() -> void:
		time = Utils.get_PB_world().ticks
		
var action_history: Array[MoveAction] = []

func execute_action(action: MoveAction) -> void:
	var robot : Robot = get_node_or_null("DynamicState/Robots/Robot")
	if robot:
		robot.target_destination = action.destination

# Main Start
func _ready() -> void:
	Utils.place_window_by_its_id()
	Engine.set_physics_ticks_per_second(60)
	#Engine.set_max_physics_steps_per_frame(30)
	
	var state0 = StateManager.serialize_objects(^"/root/PBWorld/State0")
	get_node(^"/root/PBWorld/State0").queue_free()
	StateManager.unserialize_objects(state0, ^"/root/PBWorld/DynamicState")
	#for n in registered_nodes:
		#print(n.name)
	
	var arguments: PackedStringArray = OS.get_cmdline_args()
	if arguments.has("client"):
		Netman.setup_client()
		push_warning("This is client")
		#DebugDraw2D.set_text("This is client", null, 1, Color(0, 0, 0, 0), 10000000)
	else:
		Netman.setup_server()
		push_warning("This is Server")
		#DebugDraw2D.set_text("This is SERVER", null, 1, Color(0, 0, 0, 0), 10000000)
		
	Utils.draw_help_menu()
	
	
	#pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#DebugDraw2D.set_text("Time", Engine.get_)
	DebugDraw2D.set_text("FPS", Engine.get_frames_per_second())
	
func _physics_process(delta: float) -> void:
	#Engine.physics_frames = 10
	DebugDraw2D.set_text("Ticks", ticks)
	if Input.is_physical_key_pressed(KEY_B):
		print("breaking")
	
	for node in registered_nodes:
		node.pb_process(delta)
	
	ticks += 1
	#Engine.frame
