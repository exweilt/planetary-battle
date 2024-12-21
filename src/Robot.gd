class_name Robot extends Node3D

const Turret = preload("res://src/Turret.gd")

const visual_bullet_scene = preload("res://components/misc/visual_bullet.tscn")
const VisualBullet = preload("res://src/VisualBullet.gd")
const RobotScene = preload("res://components/robot.tscn")

@export var robot_id: int = 0
@export var side_id: int = 1

@onready var nav_agent: NavigationAgent3D = get_node("./NavigationAgent3D")
@onready var target_destination: Vector3 = get_global_position():
	set(new_dest):
		nav_agent.target_position = new_dest
		target_destination = new_dest
		
#@onready var turret: Node3D = Utils.get_PB_world().get_node("Turrets/Turret")
@onready var hull: Node3D = get_node("robot/joint")
@onready var selection_circle: MeshInstance3D = get_node("SelectionCircle")

const SPEED: float = 4.0
const MAX_CHASSIS_ROTATION_SPEED = 2.0
const MAX_HULL_ROTATION_SPEED = 1.0
const ATTACKING_DISTANCE = 15.0
const MAX_SPEED: float = 6.0
const ACCELERATION: float = 3.0
const BULLET_FLY_DISTANCE: float = 50.0
const RELOADING_TIME: float = 2.0

var speed: float = 0.0

const MAX_HEALTH: float = 100.0
var health: int = 100.0 :
	set(new_health):
		health = new_health
		progress_bar.value = health
		
@onready var navigation_map: RID = Utils.get_PB_world().get_node("NavigationRegion3D").get_navigation_map()

@onready var turrets: Array[Node] = Utils.get_PB_world().get_node("Turrets").get_children()
enum RobotState {
	NONE,
	NOT_AIMING,
	AIMING,
}
var robot_state: RobotState = RobotState.NONE
var aiming_target: Turret = null

@onready var bullet_spawnpoint: Node3D = get_node("%BulletSpawnpoint")

@onready var reload_timer: Timer = get_node("Reload")

const YELLOW_MATERIAL: Material = preload("res://materials/TeamColorMatYellow.tres")
const RED_MATERIAL: Material = preload("res://materials/TeamColorMatRed.tres")
const GREEN_MATERIAL: Material = preload("res://materials/TeamColorMatGreen.tres")
const BLUE_MATERIAL: Material = preload("res://materials/TeamColorMatBlue.tres")

#
#func _physics_process(delta: float) -> void:
	#PB_physics_process(delta)
	
func serialize() -> Dictionary:
	return {
		"name": self.name,
		"global_position": global_position,
		"global_rotation": global_rotation,
	}

static func unserialize(data: Dictionary, path: NodePath) -> Robot:
	var new_robot = RobotScene.instantiate()
	new_robot.name = data["name"]
	Utils.get_PB_world().get_node(path).add_child(new_robot)
	new_robot.set_global_position(data["global_position"])
	new_robot.set_global_rotation(data["global_rotation"])
	return new_robot

	

func logic_update() -> void:
	if robot_state != RobotState.AIMING:
		for t: Turret in turrets:
			if global_position.distance_to(t.global_position) <= ATTACKING_DISTANCE:
				robot_state = RobotState.AIMING
				aiming_target = t
				DebugDraw3D.draw_arrow(global_position, t.center_point, Color.PALE_GOLDENROD, 0.1, false, 2.0)
				break
	else:
		if global_position.distance_to(aiming_target.global_position) > ATTACKING_DISTANCE:
			robot_state = RobotState.NOT_AIMING
			aiming_target = null
			#hull.rotation = Vector3.ZERO
				
func angle_between_from_side(v1: Vector3, v2: Vector3, side: Vector3 = Vector3.UP) -> float:
	var a = (v1 - v1.project(side)).normalized()
	var b = (v2 - v2.project(side)).normalized()
	
	return sign(a.cross(b).dot(side)) * acos(a.dot(b))

#func rotate_across_axis_towards(target: Vector3, axis: Vector3) -> void:
func rotate_hull_towards(target: Vector3, delta: float) -> void:
	#DebugDraw3D.draw_line(hull)
	#var new_basis = Basis()
	#new_basis.y = global_basis.y
	#new_basis.x = new_basis.y.cross(hull.global_position.direction_to(target))
	#new_basis.z = new_basis.x.cross(new_basis.y)
	#hull.global_basis = new_basis
	var angle = angle_between_from_side(hull.global_basis.z, hull.global_position.direction_to(target), global_basis.y)
	var amplitude_final = min(abs(angle), MAX_HULL_ROTATION_SPEED * delta)
	#var angle_to_turn = amplitude_final * sign(angle_rad)
	hull.rotation.y += amplitude_final * sign(angle)
	#rotate_toward()
	
## Allowed_divergence is in radians
## Angle is as if looked from local basis.y
func is_aiming_at(target: Vector3, allowed_divergence: float = 0.1) -> bool:
	var angle: float = angle_between_from_side(
		hull.global_basis.z, 
		hull.global_position.direction_to(target), global_basis.y)
	#print(rad_to_deg(angle))
	return abs(angle) <= allowed_divergence

## Returns intersection pos
func fire_logical(target_pos: Vector3) -> Vector3:
	var ray_query = PhysicsRayQueryParameters3D.create(
		bullet_spawnpoint.global_position,
		target_pos,
		4
	)
	ray_query.collide_with_areas = true
	var raycast_result = get_world_3d().direct_space_state.intersect_ray(ray_query)

	if raycast_result.has("position"):
		#DebugDraw2D.set_text("Oh yeah", null, 0, Color.BLACK, 1.0)
		DebugDraw3D.draw_sphere(raycast_result.get("position"), 1, Color.BLUE, 2.0)
		raycast_result.get("collider").get_parent().score += 1
		#print(raycast_result.get("collider").get_parent().score)
		return raycast_result.get("position")
	else:
		return bullet_spawnpoint.global_position + \
			bullet_spawnpoint.global_position.direction_to(target_pos) * BULLET_FLY_DISTANCE

func fire_visual(target: Vector3) -> void:
	var bullet: VisualBullet = visual_bullet_scene.instantiate()
	Utils.get_PB_world().add_child(bullet)

	bullet.launch(bullet_spawnpoint.global_position, target)
	
func fire(target: Vector3):
	fire_visual(fire_logical(target))

func pb_process(delta: float) -> void:
	# Aiming
	#if global_position.distance_to(turret.global_position) < ATTACKING_DISTANCE:

		#DebugDraw3D.draw_arrow(global_position, global_position + basis.z * 10)
		#DebugDraw3D.draw_sphere(aiming_target.center_point)
	#hull.rotation = Vector3.ZERO
	
	if not nav_agent.is_navigation_finished():
		var next_pos: Vector3 = nav_agent.get_next_path_position()
		DebugDraw3D.draw_sphere(next_pos, 0.5)
		
		var needed_direction: Vector3 = global_position.direction_to(next_pos)
		var robot_direction = global_basis.z
		
		DebugDraw3D.draw_arrow(global_position, global_position + global_basis.y * 5.0, Color.BLUE, 0.2, false, PBWorld.FRAME_DURATION)
		DebugDraw3D.draw_arrow(global_position, global_position + robot_direction * 5.0, Color.RED, 0.2, false, PBWorld.FRAME_DURATION)
		DebugDraw3D.draw_arrow(global_position, global_position + needed_direction * 5.0, Color.GREEN, 0.2, false, PBWorld.FRAME_DURATION)
		
		var angle_rad: float = angle_between_from_side(robot_direction, needed_direction, global_basis.y)
		#var angle_rad: float = robot_direction.signed_angle_to(needed_direction, Vector3.UP)
		#DebugDraw2D.set_text("angle_rad", angle_rad)
		 #print("angle_rad = ", angle_rad)
		
		var amplitude_final = min(abs(angle_rad), MAX_CHASSIS_ROTATION_SPEED * delta)
		var angle_to_turn = amplitude_final * sign(angle_rad)
		rotation.y += angle_to_turn
		
		
		if abs(angle_rad) > deg_to_rad(10.0):
			# Turning
			#speed = speed - ACCELERATION * delta # funny turning from standing still
			speed = max(speed - ACCELERATION * delta, 0.0)
		else:
			# Going
			speed = min(speed + ACCELERATION * delta, MAX_SPEED)
				
		#if not is_point_over_navmesh(future_position):
			#speed = 0.0
		#else:
			#global_position = future_position
			
		var elevation_from_path: Vector3 = Vector3(0, needed_direction.y, 0)
		#global_position += (robot_direction + elevation_from_path) * speed * delta
		var future_position = global_position + (robot_direction + elevation_from_path) * speed * delta
		global_position = future_position
		
			
	else:
		speed = 0.0	

	
	if robot_state == RobotState.AIMING:
		#hull.look_at(aiming_target.center_point)
		rotate_hull_towards(aiming_target.center_point, delta)
		if is_aiming_at(aiming_target.center_point):
			DebugDraw2D.set_text("Looking at the target", "yes")
			if reload_timer.is_stopped():
				fire(aiming_target.center_point)
				reload_timer.start(RELOADING_TIME)
		else:
			DebugDraw2D.set_text("Looking at the target", "no")
	else:
		rotate_hull_towards(hull.global_position + basis.z, delta)
		
	DebugDraw3D.draw_line(hull.global_position, hull.global_position + hull.global_basis.z * 20.0, Color(0, 0, 0, 0), PBWorld.FRAME_DURATION)

@onready var progress_bar: ProgressBar3D = get_node("ProgressBar3D")
func _ready() -> void:
	Utils.get_PB_world().register_node(self)
	
	progress_bar.progress_color = Utils.get_PB_world().side_to_color_binding[side_id]
	match side_id:
		1:
			Utils.set_child_meshes_material(get_node("robot"), YELLOW_MATERIAL)	
		2:
			Utils.set_child_meshes_material(get_node("robot"), RED_MATERIAL)
		3:
			Utils.set_child_meshes_material(get_node("robot"), GREEN_MATERIAL)
		4:
			Utils.set_child_meshes_material(get_node("robot"), BLUE_MATERIAL)
	
const DISTANCE_THRESHOLD = 0.1
func is_point_over_navmesh(point: Vector3) -> bool:
	#navigation_region.get_navigation_map()
	var closest: Vector3 = NavigationServer3D.map_get_closest_point_to_segment(navigation_map,
		Vector3(point.x, 1000.0, point.z),
		Vector3(point.x, -1000.0, point.z),
	)
	 
	return (closest - Vector3.UP * closest.y).distance_to(point - Vector3.UP * point.y) < DISTANCE_THRESHOLD

func select() -> void:
	selection_circle.visible = true
	
	var pc: PlayerController = Utils.get_controller()
	
	if not pc.selected_robots.has(self):
		pc.selected_robots.append(self)

func unselect() -> void:
	selection_circle.visible = false
	
	var pc: PlayerController = Utils.get_controller()
	
	if pc.selected_robots.has(self):
		pc.selected_robots.erase(self)
		
