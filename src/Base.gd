class_name Base extends Node3D

@export var base_id: int = 0
@export var side_id: int = 0

const BUILDING_YELLOW_MATERIAL: Material = preload("res://materials/BuildingTeamYellowMat.tres")
const BUILDING_RED_MATERIAL: Material = preload("res://materials/BuildingTeamRedMat.tres")
const BUILDING_GREEN_MATERIAL: Material = preload("res://materials/BuildingTeamGreenMat.tres")
const BUILDING_BLUE_MATERIAL: Material = preload("res://materials/BuildingTeamBlueMat.tres")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Utils.get_PB_world().register_node(self)
	#Utils.set_child_meshes_material(get_node("base"), BUILDING_YELLOW_MATERIAL)
	update_texture_color()

func update_texture_color() -> void:
	match side_id:
		1: Utils.set_child_meshes_material(get_node("base"), BUILDING_YELLOW_MATERIAL)
		2: Utils.set_child_meshes_material(get_node("base"), BUILDING_RED_MATERIAL)
		3: Utils.set_child_meshes_material(get_node("base"), BUILDING_GREEN_MATERIAL)
		4: Utils.set_child_meshes_material(get_node("base"), BUILDING_BLUE_MATERIAL)
		
const PAYMENT_PERIOD: float = 1.0
const PAYMENT_AMOUNT: int = 1
var timeleft_to_payment: float = PAYMENT_PERIOD

# Called every frame. 'delta' is the elapsed time since the previous frame.
func pb_process(delta: float) -> void:
	timeleft_to_payment -= delta
	
	# Make payment
	if timeleft_to_payment <= 0:
		Utils.get_PB_world().set_side_resources(
			side_id, 
			Utils.get_PB_world().get_side_resources(side_id) + PAYMENT_AMOUNT
		)
		timeleft_to_payment = PAYMENT_PERIOD - timeleft_to_payment # account for timeleft going negative		
