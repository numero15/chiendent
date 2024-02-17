extends State

func enter_state(_msg := {}) -> void:
	set_physics_process(true)
	if _msg.has("jump"):
		owner.vel = owner.curSpeed * owner.get_dir()
		print(owner.curSpeed)
		owner.avgNormal =  _msg["jump"]
		owner.jumpVec =  owner.avgNormal * 50
		owner.gravity =  owner.avgNormal * -3
		owner.jumpVectors += owner.jumpVec
		#avgNormal = Vector3.UP
		owner.affected_by_gravity = false
	else :
		owner.affected_by_gravity = true

	
func _physics_process(delta):
	owner.checkRays()
	
	if owner.jumpVectors.dot(owner.jumpVectors + owner.gravity) <0 :
		owner.affected_by_gravity = true
		owner.checkerGrind.set_deferred("monitoring", true)
		
	owner.jumpVectors += owner.gravity
	owner.velocity = owner.vel/2 + owner.jumpVectors
	owner.move()
	
	if owner.is_on_floor():
		change_state.emit($"../Move")

