extends Node3D

const BULLET_SPEED = 150.0
@onready var time_since_created = 0.0
var lifetime: float

var flying_from: Vector3
var flying_to: Vector3



# Called when the node enters the scene tree for the first time.
#func _ready() -> void:
	#lifetime = flying_from.distance_to(flying_to)/BULLET_SPEED


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	time_since_created += delta
	if time_since_created > lifetime:
		queue_free()
	global_position = lerp(flying_from, flying_to, time_since_created/lifetime)

func launch(from: Vector3, to: Vector3) -> void:
	global_position = from
	look_at(to, Vector3.UP, true)
	flying_from = from
	flying_to = to
	lifetime = flying_from.distance_to(flying_to)/BULLET_SPEED
