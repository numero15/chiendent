extends Node3D

func _unhandled_input(event):
	if event.is_action_released("ui_cancel"):
		if !$Pause.is_visible_in_tree() :
			$Pause.init()
