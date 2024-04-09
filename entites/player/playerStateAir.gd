extends StateFSM

func enter_state(_msg := {}) -> void:
	set_physics_process(true)
	set_process_input(true)
	print('air')
	
	if _msg.has("jump"):
		owner.checkerGrind.set_deferred("monitoring", false)
		#apply a small boost on jump
		owner.curSpeed +=5
		owner.vel = owner.curSpeed * owner.get_dir()
		owner.avgNormal =  _msg["jump"].normalized()
		owner.jumpVec =  owner.avgNormal * owner.jump_strength
		owner.gravity =  owner.avgNormal * -owner.gravity_strength
		owner.jumpVectors += owner.jumpVec
		
		owner.affected_by_gravity = false
	else :
		owner.checkerGrind.set_deferred("monitoring", true)
		owner.affected_by_gravity = true
	
func _physics_process(delta):
	owner.checkRays(true)
	if owner.jumpVectors.length() < (owner.jumpVectors + owner.gravity).length():
	#if owner.jumpVectors.dot(owner.jumpVectors + owner.gravity) <0 :
		owner.affected_by_gravity = true
		owner.checkerGrind.set_deferred("monitoring", true)
		
	owner.jumpVectors += owner.gravity
	#add player control when jump/fall
	#kowner.velocity = owner.vel*.75 + owner.jumpVectors
	owner.velocity = owner.curSpeed * owner.get_dir()*1 + owner.jumpVectors
	
	owner.move()
	
	if owner.is_on_floor():
		print('land')
		if owner.checkerGroundJump.get_collision_normal().dot(owner.global_transform.basis.y) > .5:
			##owner.particlesJump.global_transform = owner.global_transform
			#print('land')
			owner.particlesJump.emitting = true;
			change_state.emit($"../Move")
		
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		owner.character.rotation.y += -event.relative.x * owner.MOUSE_SENS

