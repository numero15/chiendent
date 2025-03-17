extends Control
var paused = false
var saturation
@onready var resume = $MarginContainer/VBoxContainer/Resume

@export var world : WorldEnvironment

func _ready() -> void:
	saturation = world.environment.adjustment_saturation

func _process(delta):
	if Input.is_action_just_pressed("pause_input"):
		pauseMenu()

func pauseMenu():
	if paused :
		hide()
		get_tree().paused = false
		var tween = get_tree().create_tween()
		tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		tween.tween_property(world.environment, "adjustment_saturation",saturation, .2)
		
	else :
		show()
		get_tree().paused = true
		resume.grab_focus()
		var tween = get_tree().create_tween()
		tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		tween.tween_property(world.environment, "adjustment_saturation",0, .2)
		
	paused = !paused



func _on_resume_button_down() -> void:
	pauseMenu()
