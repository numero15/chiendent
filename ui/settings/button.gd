extends Panel

@export var regularTheme: Resource
@export var focusTheme: Resource

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#add_theme_stylebox_override("panel",regularStyleBox)
	theme = regularTheme

func _on_setter_focus_entered() -> void:
	#add_theme_stylebox_override("panel",focusStyleBox)
	theme = focusTheme

func _on_setter_focus_exited() -> void:
	#add_theme_stylebox_override("panel",regularStyleBox)
	theme = regularTheme
