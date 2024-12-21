extends Node

func place_window_by_its_id() -> void:
	var arguments: PackedStringArray = OS.get_cmdline_args()
	
	if arguments.has("instance1"):
		get_window().position = Vector2(2, 30)
	elif arguments.has("instance2"):
		get_window().position = Vector2(1000, 30)
	elif arguments.has("instance3"):
		get_window().position = Vector2(2, 800)

func draw_help_menu() -> void:
	DebugDraw2D.set_text("[F] Toggle Freecam", null, 1, Color(0, 0, 0, 0), 10000000)

const PBWorld = preload("res://src/PBWorld.gd")
func get_PB_world() -> PBWorld:
	return get_node_or_null("/root/PBWorld/")
	
const PlayerController = preload("res://src/PlayerController.gd")
func get_controller() -> PlayerController:
	return get_PB_world().get_node_or_null("PlayerController")
	
func get_robots() -> Array[Robot]:
	var robots: Array[Robot] = []
	
	for child in get_PB_world().get_node_or_null("Robots").get_children():
		robots.append(child as Robot)
		
	return robots
	
func debug_print(text: String, is_ethernal: bool = false) -> void:
	push_warning(text)
	if not is_ethernal:
		DebugDraw2D.set_text(text, null, 0, Color.WHITE, 100000.0)
	else:
		DebugDraw2D.set_text(text, null, 0, Color.WHITE, 1000000.0)

func is_point_in_rectangle(point: Vector2, corner1: Vector2, corner2: Vector2) -> bool:
	# Determine the bounds of the rectangle
	var min_x = min(corner1.x, corner2.x)
	var max_x = max(corner1.x, corner2.x)
	var min_y = min(corner1.y, corner2.y)
	var max_y = max(corner1.y, corner2.y)

	# Check if the point lies within the bounds
	return point.x >= min_x and point.x <= max_x and point.y >= min_y and point.y <= max_y

class PeerSideMap:
	var _peer_to_side: Dictionary
	
	func _init() -> void:
		_peer_to_side = {}
	
	func set_pair(peer: int, side: int):
		_peer_to_side[peer] = side
	
	func get_side_of_peer(peer: int) -> int:
		return _peer_to_side[peer]
	
	func get_peer_of_side(side: int) -> int:
		return _peer_to_side.keys()[_peer_to_side.values().find(side)] 

const RAY_LENGTH: float = 1000.0
func get_position_under_cursor() -> Vector3:
	var cam: Camera3D = get_viewport().get_camera_3d()
	var cursor_position: Vector2 = get_viewport().get_mouse_position()
	
	var start: Vector3 = cam.project_ray_origin(cursor_position)
	var end: Vector3 = start + cam.project_ray_normal(cursor_position) * RAY_LENGTH
	var navmap_rid: RID = get_tree().get_root().get_world_3d().get_navigation_map()
	
	return NavigationServer3D.map_get_closest_point_to_segment(navmap_rid, start, end, false)

func set_child_meshes_material(parent: Node, material: Material) -> void:
	for submesh in parent.get_children():
		#var mesh: MeshInstance3D = submesh as MeshInstance3D
		if submesh is MeshInstance3D:
			#submesh = submesh.duplicate()
			submesh.mesh.surface_set_material(0, material)
			submesh.material_overlay = material
			set_child_meshes_material(submesh, material)

enum Side {
	Neutral = 0,
	Yellow = 1,
	Red = 2,
	Green = 3,
	Blue = 4,
}
