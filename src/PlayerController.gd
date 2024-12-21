class_name PlayerController extends Node

const CAMERA_SPEED: float = 10.0
const ROTATION_SENSITIVITY: float = 0.005

@onready var destination_point_scene = preload("res://components/misc/destination_point.tscn")
@onready var dp: Node3D = destination_point_scene.instantiate()
@onready var cam : Camera3D = %PBCamera

const Robot = preload("res://src/Robot.gd")
#@onready var the_robot: Robot = get_parent().get_node("Robots/Robot")

@onready var SelectionRect: Panel = Utils.get_PB_world().get_node("GUI").get_node("SelectionRect")
var is_selecting: bool = false # LMB is held
var selection_start_pos: Vector2 = Vector2.ZERO
var selection_end_pos: Vector2 = Vector2.ZERO

var selected_robots: Array[Robot] = []

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("exit"):
		get_tree().quit()
		
	if event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_MIDDLE):
		cam.rotation.y -= event.relative.x * ROTATION_SENSITIVITY
		cam.rotation.x -= event.relative.y * ROTATION_SENSITIVITY
		
	
	# Mouse Selection Motion ====================================================
	if event is InputEventMouseMotion:
		selection_end_pos = event.position
		update_selection_rect()
	
	# Start/end Selection =======================================================
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed() and not is_selecting:
			init_selection()
		elif event.is_released() and is_selecting:
			finish_selection()
		
	if event is InputEventKey and not event.echo and event.is_pressed() and event.keycode == KEY_T:
			var pos = Utils.get_position_under_cursor()
		
			var action = {
				"action_type": Netman.ActionType.SPAWN_ROBOT,
				"side_id": Utils.get_PB_world().get_my_side_id(),
				"position": pos
			}
			Utils.get_PB_world().add_action_for_frame(action)
	
	if event is InputEventKey and not event.echo and event.is_pressed() and event.keycode == KEY_C:
			var action = {
				"action_type": Netman.ActionType.STOP,
				"robot_ids": selected_robots.duplicate(true).map(func(r): return r.robot_id),
			}
			Utils.get_PB_world().add_action_for_frame(action)
		
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.is_pressed():
		
		var pos = Utils.get_position_under_cursor()
		
		dp.global_position = pos
		
		#var action = PBWorld.MoveAction.new()
		#action.destination = pos
		for robot in selected_robots:
			var action = {
				"action_type": Netman.ActionType.MOVE,
				"robot_id": robot.robot_id,
				"destination": pos
			}
			Utils.get_PB_world().add_action_for_frame(action)
		
		#Utils.get_PB_world().action_history.append(action)
		#Utils.get_PB_world().execute_action(action)
		
		#if the_robot != null:
			#the_robot.target_destination = pos

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_child(dp)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#DebugDraw3D.draw_line(robot.global_position, dp.global_position, Color.GRAY)
	
	if Input.is_action_pressed("ui_up"):
		var dir: Vector3 = -cam.basis.z
		dir.y = 0
		dir = dir.normalized()
		cam.position += dir * CAMERA_SPEED * delta
	if Input.is_action_pressed("ui_down"):
		var dir: Vector3 = cam.basis.z
		dir.y = 0
		dir = dir.normalized()
		cam.position += dir * CAMERA_SPEED * delta
	if Input.is_action_pressed("ui_left"):
		var dir: Vector3 = -cam.basis.x
		dir.y = 0
		dir = dir.normalized()
		cam.position += dir * CAMERA_SPEED * delta
	if Input.is_action_pressed("ui_right"):
		var dir: Vector3 = cam.basis.x
		dir.y = 0
		dir = dir.normalized()
		cam.position += dir * CAMERA_SPEED * delta
	if Input.is_action_pressed("up"):
		cam.position.y += CAMERA_SPEED * delta
	if Input.is_action_pressed("down"):
		cam.position.y -= CAMERA_SPEED * delta

func init_selection() -> void:
	is_selecting = true
	SelectionRect.visible = true
	selection_start_pos = get_viewport().get_mouse_position()
	selection_end_pos = get_viewport().get_mouse_position()
	update_selection_rect()

func finish_selection() -> void:
	# unselect mutates selected_robots!
	for robot in selected_robots.duplicate():
		robot.unselect()
		
	for robot in Utils.get_robots():
		if robot.side_id == Utils.get_PB_world().peer_side_map.get_side_of_peer(multiplayer.get_unique_id()) \
		and Utils.is_point_in_rectangle(
			cam.unproject_position(robot.global_position), 
			selection_start_pos, 
			selection_end_pos
		):
			robot.select()
			
	is_selecting = false
	selection_start_pos = Vector2.ZERO
	selection_end_pos = Vector2.ZERO
	SelectionRect.visible = false
	update_selection_rect()
	
	
	
func update_selection_rect() -> void:
	SelectionRect.position = Vector2(
			min(selection_start_pos.x, selection_end_pos.x),
			min(selection_start_pos.y, selection_end_pos.y)
		)
	SelectionRect.size = (selection_end_pos - selection_start_pos).abs()
