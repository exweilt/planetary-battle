extends Node

const RAY_LENGTH: float = 1000.0
const CAMERA_SPEED: float = 10.0
const ROTATION_SENSITIVITY: float = 0.005

@onready var destination_point_scene = preload("res://components/destination_point.tscn")
@onready var dp: Node3D = destination_point_scene.instantiate()
@onready var robot = %Robot
@onready var cam : Camera3D = %PBCamera

const Robot = preload("res://src/Robot.gd")
@onready var the_robot: Robot = get_parent().get_node("Robots/Robot")

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("exit"):
		get_tree().quit()
		
	if event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_MIDDLE):
		cam.rotation.y -= event.relative.x * ROTATION_SENSITIVITY
		cam.rotation.x -= event.relative.y * ROTATION_SENSITIVITY
	
		
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.is_pressed() \
	and multiplayer.is_server():
		
		var start: Vector3 = cam.project_ray_origin(event.position)
		var end: Vector3 = start + cam.project_ray_normal(event.position) * RAY_LENGTH
		var navmap_rid: RID = get_tree().get_root().get_world_3d().get_navigation_map()
		
		var pos: Vector3 = NavigationServer3D.map_get_closest_point_to_segment(navmap_rid, start, end, false)
		
		dp.global_position = pos
		
		var action = PBWorld.MoveAction.new()
		action.destination = pos
		Utils.get_PB_world().action_history.append(action)
		Utils.get_PB_world().execute_action(action)
		
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
