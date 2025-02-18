extends StateFSM

func enter_state(_msg := {}) -> void:
	set_physics_process(true)
	set_process_input(true)
	owner.characterMesh.rotation.z = 0
	print('air')
	
	if _msg.has("jump"):
		owner.checkerGrind.set_deferred("monitoring", false)
		#apply a small boost on jump
		owner.curSpeed +=5
		owner.vel = owner.curSpeed * owner.get_dir()
		owner.avgNormal =  _msg["jump"].normalized()
		owner.jumpVec =  owner.avgNormal * owner.jump_strength
		owner.gravity =  owner.avgNormal * -owner.gravity_strength
		#I replaced += by = ti fix jump from grind bug but it may fuck something else, I don't know what I do
		owner.jumpVectors = owner.jumpVec
		print(owner.jumpVec.length())
		
		owner.affected_by_gravity = false
		
		if owner.animationTree:
			owner.animationTree["parameters/StateMachineLocomotion/playback"].travel("BAKED_jump")
		
	else :
		owner.checkerGrind.set_deferred("monitoring", true)
		owner.affected_by_gravity = true
		if owner.animationTree:
			#owner.animationTree["parameters/StateMachineLocomotion/playback"].travel("BAKED_fall")
			owner.timerAnim.wait_time = 0.2
			owner.timerAnim.start()
	
func _physics_process(delta):
	owner.check_boost(delta)
	owner.checkRays(true)	
	if owner.jumpVectors.length() < (owner.jumpVectors + owner.gravity).length():
	#if owner.jumpVectors.dot(owner.jumpVectors + owner.gravity) <0 :
		owner.affected_by_gravity = true
		owner.checkerGrind.set_deferred("monitoring", true)
		#owner.animationTree["parameters/StateMachineLocomotion/playback"].travel("BAKED_fall")
		if owner.timerAnim.is_stopped() :
			owner.timerAnim.wait_time = 0.5
			owner.timerAnim.start()
		
	if !owner.isBoost:
		owner.jumpVectors += owner.gravity
		owner.velocity = owner.curSpeed * owner.get_dir()*1 + owner.jumpVectors
	
	#prevent jump from going to hight when boost
	else:
		owner.velocity = owner.curSpeed * owner.get_dir()*1  + owner.jumpVectors/4
	
	owner.move()
	
	if owner.is_on_floor():
		if owner.checkerGroundJump.get_collision_normal().dot(owner.global_transform.basis.y) > .5:
			owner.particlesJump.emitting = true;
			owner.checkerGrind.set_deferred("monitoring", false)		
			change_state.emit($"../Move")
			
	if Settings.pad:
		#owner.character.rotation.y +=(Input.get_action_strength("move_left") - Input.get_action_strength("move_right")) * owner.STICK_SENS
		#this is copy pasted from the move state, maybe it should be moved to player
		var _v = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
		if _v.dot(Vector2(0,-1))>-.5 and  _v.length()>0 :
			var _r = (Input.get_action_strength("move_left") - Input.get_action_strength("move_right")) * owner.STICK_SENS*1.2 * 1.5
			owner.character.rotation.y += _r
			
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion  and !Settings.pad:
		owner.character.rotation.y += -event.relative.x * owner.MOUSE_SENS



func _on_timer_anim_timeout():
	owner.timerAnim.stop()
	owner.animationTree["parameters/StateMachineLocomotion/playback"].travel("BAKED_fall")


func _on_checker_grind_body_entered(body: Node3D) -> void:
	if owner.timerCoolDownGrind.is_stopped() :
		change_state.emit($"../Grind",{_body = body})
