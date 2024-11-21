extends Node

func serialize_objects(path: NodePath) -> Dictionary:
	var directory = get_tree().get_root().get_node(path)
	
	var turrets = []
	for turret in directory.get_node("Turrets").get_children():
		turrets.append(turret.serialize())
		
	var robots = []
	for robot in directory.get_node("Robots").get_children():
		robots.append(robot.serialize())
	
	return {
		"turrets": turrets,
		"robots": robots
	}

func unserialize_objects(data: Dictionary, path: NodePath) -> void:
	## Create a Node dir at path if not present
	#if !get_tree().get_root().has_node(path):
		#var new_dir = Node3D.new()
		#new_dir.name = path.get_name(path.get_name_count() - 1)
		#get_tree().get_root().add_child(new_dir)
	
	var directory = get_tree().get_root().get_node(path)
		
	for turret_data in data["turrets"]:
		var node = Turret.unserialize(turret_data, str(path) + "/Turrets")
		
	for robot_data in data["robots"]:
		var node = Robot.unserialize(robot_data, str(path) + "/Robots")
		Utils.get_PB_world().register_node(node)
		
	

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
