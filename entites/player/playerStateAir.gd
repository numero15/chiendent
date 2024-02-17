extends State

func enter_state(_msg := {}) -> void:
	set_physics_process(true)
	
func _physics_process(delta):
	owner.checkRays()
	owner.jumpVectors += owner.gravity
	owner.velocity = owner.vel + owner.jumpVectors
	owner.move()
	
	if Input.is_action_just_pressed("ui_select"):
		change_state.emit($"../Air", 'jump')
		
	if owner.is_on_floor():
		change_state.emit($"../Move")
