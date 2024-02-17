extends State

func _physics_process(delta):
	owner.vel = owner.curSpeed * owner.get_dir()
	owner.checkRays()
	owner.jumpVectors = Vector3.ZERO
	owner.velocity = owner.vel + owner.jumpVectors
	owner.move()

		
	if not owner.is_on_floor():
		change_state.emit($"../Fall")

	if Input.is_action_just_pressed("ui_select"):
		change_state.emit($"../Air", {jump = owner.avgNormal})

func _on_checker_grind_body_entered(body):
	change_state.emit($"../Grind",{_body = body})
