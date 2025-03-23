extends Control
var paused = false
var saturation
var contrast
@onready var resume_button = $MarginContainer/VBoxContainer/HBoxContainer/Resume
@onready var quit_button = $MarginContainer/VBoxContainer/HBoxContainer2/Quit
@onready var settings_button = $MarginContainer/VBoxContainer/HBoxContainer3/Settings
@onready var settings = $SettingsScreen

@export var world : WorldEnvironment

func _ready() -> void:
	saturation = world.environment.adjustment_saturation
	contrast = world.environment.adjustment_contrast

func _process(_delta):
	if Input.is_action_just_pressed("pause_input"):
		pauseMenu()

func pauseMenu():
	if paused :
		hide()
		get_tree().paused = false
		var tween = get_tree().create_tween()
		tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		tween.tween_property(world.environment, "adjustment_saturation",saturation, .1)
		tween.tween_property(world.environment, "adjustment_contrast",contrast, .1)
		
	else :
		show()
		get_tree().paused = true
		resume_button.grab_focus()
		var tween = get_tree().create_tween()
		tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		tween.tween_property(world.environment, "adjustment_saturation",0, .2)
		tween.tween_property(world.environment, "adjustment_contrast",1.5, .2)
		
	paused = !paused



func _on_resume_button_down() -> void:
	pauseMenu()


func _on_settings_focus_entered() -> void:
	if !settings.visible :
		settings.visible = true


func _on_quit_focus_entered() -> void:
	settings.visible = false


func _on_resume_focus_entered() -> void:
	settings.visible = false
