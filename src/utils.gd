extends Node

func place_window_by_its_id() -> void:
	var arguments: PackedStringArray = OS.get_cmdline_args()
	
	if arguments.has("instance3"):
		get_window().position = Vector2(2, 2)
	elif arguments.has("instance2"):
		get_window().position = Vector2(1000, 2)
	elif arguments.has("instance1"):
		get_window().position = Vector2(2, 800)

func draw_help_menu() -> void:
	DebugDraw2D.set_text("[F] Toggle Freecam", null, 1, Color(0, 0, 0, 0), 10000000)

const PBWorld = preload("res://src/PBWorld.gd")
func get_PB_world() -> PBWorld:
	return get_node_or_null("/root/PBWorld/")

func debug_print(text: String, is_ethernal: bool = false) -> void:
	push_warning(text)
	if not is_ethernal:
		DebugDraw2D.set_text(text, null, 0, Color.WHITE, 100000.0)
	else:
		DebugDraw2D.set_text(text, null, 0, Color.WHITE, 1000000.0)
