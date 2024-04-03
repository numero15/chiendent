extends Control

func _unhandled_input(event):
	if event.is_action_released("ui_cancel"):
		get_viewport().set_input_as_handled()
		print("hide")
		get_tree().paused = false
		hide()
		
		
func init():
	get_tree().paused = true
	show()
