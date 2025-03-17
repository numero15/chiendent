extends Control

@onready var fullscreenCheckBox = $PanelContainer/MarginContainer/VBoxContainer/Fullscreen/HBoxContainer/CheckBox
@onready var invertXCheckBox = $PanelContainer/MarginContainer/VBoxContainer/CameraX/HBoxContainer/CheckBox
@onready var invertYCheckBox = $PanelContainer/MarginContainer/VBoxContainer/CameraY/HBoxContainer/CheckBox
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var video_setting = ConfigFileHandler.load_video_settings()
	fullscreenCheckBox.button_pressed = video_setting.fullscreen
	
	var control_setting = ConfigFileHandler.load_control_settings()
	invertXCheckBox.button_pressed = control_setting.invertX
	invertYCheckBox.button_pressed = control_setting.invertY


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_volume_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(0,value)


func _on_fullscreen_toggled(toggled_on: bool) -> void:
	ConfigFileHandler.save_video_setting('fullscreen',toggled_on)
	ConfigFileHandler.apply_video_settings()
	
func _on_invertX_toggled(toggled_on: bool) -> void:
	ConfigFileHandler.save_control_setting('invertX',toggled_on)
	
func _on_invertY_toggled(toggled_on: bool) -> void:
	ConfigFileHandler.save_control_setting('invertY',toggled_on)

func _on_volume_drag_ended(value_changed: bool) -> void:
	pass # Replace with function body.
