extends State

func _physics_process(delta):
	owner.vel = owner.curSpeed * owner.get_dir()
	owner.checkRays()
	owner.jumpVectors = Vector3.ZERO
	owner.velocity = owner.vel + owner.jumpVectors
	owner.move()

		
	if not owner.is_on_floor():
		change_state.emit($"../Fall")



func _on_checker_grind_body_entered(body):
	change_state.emit($"../Grind",{_body = body})
