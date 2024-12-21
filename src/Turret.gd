class_name Turret extends Node3D

var center_point: Vector3

@onready var label3d: Label3D = get_node("Label3D")
#@onready label3d.text = str(score)

const TurretScene = preload("res://components/turret.tscn")

var score : int = 0:
	set(new_val):
		score = new_val
		if label3d:
			label3d.text = str(new_val)

func serialize() -> Dictionary:
	return {
		"name": self.name,
		"global_position": global_position,
		"global_rotation": global_rotation,
		"score": score
	}

static func unserialize(data: Dictionary, path: NodePath) -> Turret:
	var new_turret = TurretScene.instantiate()
	new_turret.name = data["name"]
	Utils.get_PB_world().get_node(path).add_child(new_turret)
	new_turret.set_global_position(data["global_position"])
	new_turret.set_global_rotation(data["global_rotation"])
	new_turret.score = data["score"]
	new_turret.pb_ready()
	return new_turret
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	label3d.text = str(score)
	center_point = get_node("MeshInstance3D").global_position 


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	DebugDraw3D.draw_sphere(center_point)
