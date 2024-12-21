class_name PBWorld extends Node

#@onready var time: float = 0.0
@onready var ticks: int = 0

var registered_nodes: Array[Node3D] = []

func register_node(node: Node3D) -> void:
	if node != null and node.has_method("pb_process"):
		registered_nodes.append(node)
		

const TICKRATE = 60
const FRAME_DURATION: float = 1.0 / TICKRATE
const INPUT_BUFFER: int = 5

var last_local_sampled_frame: int = -1
var last_remote_frame: int = 0

#class MoveAction:
	#var action_type = Netman.ActionType.MOVE
	#var robot_id: int = 0
	#var destination: Vector3 = Vector3.ZERO
	#var time: int = 0
	#
	#func _init() -> void:
		#time = Utils.get_PB_world().ticks
		
#var action_history: Array[MoveAction] = []

#func execute_action(action: MoveAction) -> void:
	##var robot : Robot = get_node_or_null("Robots/Robot")
	#for robot in Utils.get_controller().selected_robots:
		#if robot:
			#robot.target_destination = action.destination

var highest_allocated_robot_id: int = 3
const ROBOT_SCENE: PackedScene = preload("res://components/robot.tscn")
func execute_action(action: Dictionary) -> void:
	match action["action_type"]:
		Netman.ActionType.MOVE:	
			get_robot_by_id(action["robot_id"]).target_destination = action["destination"] as Vector3
		Netman.ActionType.SPAWN_ROBOT:
			var id = highest_allocated_robot_id + 1
			var robot = ROBOT_SCENE.instantiate()
			
			robot.robot_id = id
			robot.side_id = action["side_id"]
			get_node("Robots").add_child(robot)
			robot.name = "Robot" + str(id)
			robot.global_position = action["position"]
			
			highest_allocated_robot_id += 1 
		Netman.ActionType.STOP:
			for robot_id in action["robot_ids"]:
				var robot: Robot = get_node("Robots/Robot" + str(robot_id))
				robot.target_destination = robot.global_position				
	
	#for robot in Utils.get_controller().selected_robots:
		#if robot:
			#robot.target_destination = action["destination"] as Vector3

#class FrameInput:
	#var for_tick: int = 0
	#var actions: Array[Dictionary]
	#
	#func _init(tick: int, actions: Array[Dictionary]) -> void:
		#self.for_tick = tick
		#self.actions = actions

# Frame num : FrameInput
var local_inputs: Dictionary = {}
var remote_inputs: Dictionary = {}

var phys_fps_timer: Timer = null

var physics_ticks_counter: int = 0
func display_ticks_per_second() -> void:
	DebugDraw2D.set_text("Ticks Per Second", physics_ticks_counter, 4, Color(0,0,0,0), 2.0)
	physics_ticks_counter = 0

# Main Start
func _ready() -> void:
	Utils.place_window_by_its_id()
	Engine.set_physics_ticks_per_second(TICKRATE)
	
	phys_fps_timer = Timer.new()
	add_child(phys_fps_timer)
	phys_fps_timer.timeout.connect(display_ticks_per_second)
	phys_fps_timer.process_callback = Timer.TIMER_PROCESS_IDLE
	phys_fps_timer.start()
	
	#Engine.set_max_physics_steps_per_frame(30)
	
	#var state0 = StateManager.serialize_objects(^"/root/PBWorld/State0")
	#get_node(^"/root/PBWorld/State0").queue_free()
	#StateManager.unserialize_objects(state0, ^"/root/PBWorld/DynamicState")
	#for n in registered_nodes:
		#print(n.name)
		
	#RenderingServer.viewport_set_active(get_tree().get_root().get_viewport_rid(), false)
	#RenderingServer.render_loop_enabled = false
	
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
	DebugDraw2D.set_text("VisualFPS", Engine.get_frames_per_second())
	
func _physics_process(delta: float) -> void:
	if multiplayer.get_peers().size() < 1:
		return
	
	if not local_inputs.has(ticks):
		DebugDraw2D.set_text("Local Input", "NOT sampled", 3, Color(0,0,0,0), 1.0)
	else:
		DebugDraw2D.set_text("Local Input", "SAMPLED", 3, Color(0,0,0,0), 1.0)
	
	if not remote_inputs.has(ticks):
		DebugDraw2D.set_text("Remote Input", "NOT sampled", 2, Color(0,0,0,0), 1.0)
	else:
		DebugDraw2D.set_text("Remote Input", "SAMPLED", 2, Color(0,0,0,0), 1.0)
	
	#Engine.physics_frames = 10
	DebugDraw2D.set_text("Frame", ticks, 0, Color(0,0,0,0), 1000000.0)
	
	DebugDraw2D.set_text("Last Sampled Frame", last_local_sampled_frame, 0, Color(0,0,0,0), 100000.0)
	#DebugDraw2D.set_text("Last Remote Frame", last_remote_frame, 0, Color(0,0,0,0), 100000.0)
	
	if Input.is_physical_key_pressed(KEY_B):
		print("breaking")
		
	if last_local_sampled_frame < ticks + INPUT_BUFFER - 1:
		sample_input(last_local_sampled_frame + 1)
		
	#if Input.is_key_pressed(KEY_0) and local_input == {}:
	
	# continue only if inputs are present
	#if local_inputs.has(ticks) and remote_inputs.has(ticks):
		#assert(local_inputs[ticks]["for_frame"] == ticks and remote_inputs[ticks]["for_frame"] == ticks)
		#
		#process_frame(delta)

func process_frame(delta: float) -> void:
	print(str(multiplayer.get_unique_id(), " processing frame ", ticks))
	
	# eat inputs
	process_frame_input(local_inputs[ticks])
	process_frame_input(remote_inputs[ticks])

	for node in registered_nodes:
		if node != null and node.has_method("pb_process"):
			node.pb_process(delta)
		else:
			registered_nodes.erase(node)
	
	ticks += 1
	physics_ticks_counter += 1
	
	process_next_frame_if_enough_inputs()
	
var collected_actions_for_frame: Array[Dictionary] = []
func sample_input(for_frame: int) -> void:
	#var formed_input = FrameInput.new(ticks, collected_actions_for_frame.duplicate(true))
	var formed_input = {
		"for_frame": for_frame,
		"actions": collected_actions_for_frame.duplicate(true),
		"author_peer":  multiplayer.get_unique_id()
	}
	collected_actions_for_frame = []
	
	local_inputs[for_frame] = formed_input
	print(str(multiplayer.get_unique_id(), " formed its input for frame ", for_frame))
	
	receive_input.rpc(formed_input, for_frame)
	last_local_sampled_frame = for_frame
	process_next_frame_if_enough_inputs()
	#receive_input.rpc()

func process_next_frame_if_enough_inputs() -> void:
	if local_inputs.has(ticks) and remote_inputs.has(ticks):
		process_frame(FRAME_DURATION)

func process_frame_input(input: Dictionary) -> void:
	for action in input["actions"]:
		execute_action(action)
	
#func receive_input():
@rpc("any_peer", "call_remote", "reliable")
func receive_input(input: Dictionary, for_frame: int):
	assert(multiplayer.get_remote_sender_id() != multiplayer.get_unique_id())
	print(str(multiplayer.get_unique_id(), " received input for frame ", input["for_frame"]))
	remote_inputs[for_frame] = input
	
	process_next_frame_if_enough_inputs()
	#print("a")

func add_action_for_frame(action: Dictionary) -> void:
	collected_actions_for_frame.append(action)
	
func get_robot_by_id(id: int) -> Robot:
	return get_node(str("Robots/Robot", id)) as Robot
	

var peer_side_map: Utils.PeerSideMap = Utils.PeerSideMap.new()

#func side_id_to_peer_id():
	#pass
#
#func peer_id_to_side_id():
	#pass

#var peer_to_side_mapping()

func get_my_side_id() -> int:
	return peer_side_map.get_side_of_peer(multiplayer.get_unique_id())

@onready var titanium_label = %TitaniumLabel
func set_side_resources(side_id: int, amount: int):
	_side_resources[side_id] = amount
	DebugDraw2D.set_text("Side " + str(side_id) + " titanium", amount, 6, Color(0,0,0,0), 10000.0)
	if side_id == get_my_side_id():
		titanium_label.text = str("Titanium: ", amount)
	
func get_side_resources(side_id: int) -> int:
	return _side_resources[side_id]
	
var _side_resources: Dictionary = {
	1: 100,
	2: 500,
	3: 0,
	4: 0 
}

const side_to_color_binding: Dictionary = {
	0: Color(0.5, 0.5, 0.5),
	1: Color(0.88, 0.763, 0.0),
	2: Color(0.82, 0.0, 0.0),
	3: Color(0.0, 0.36, 0.763),
	4: Color(0.0, 0.16, 0.74)
}
