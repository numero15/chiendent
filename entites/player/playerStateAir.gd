extends StateFSM

func enter_state(_msg := {}) -> void:
	owner.particlesDust.emitting = false;
	set_physics_process(true)
	set_process_input(true)
	owner.characterMesh.rotation.z = 0
	print('air')
	
	if _msg.has("jump"):
		owner.SFXVoiceJump.play()
		#change this to detect grind only on fall
		#owner.checkerGrind.set_deferred("monitoring", false)
		owner.checkerGrind.set_deferred("monitoring", true)
		#apply a small boost on jump
		owner.curSpeed +=5
		owner.vel = owner.curSpeed * owner.get_dir()
		owner.avgNormal =  _msg["jump"].normalized()
		owner.jumpVec =  owner.avgNormal * owner.jump_strength
		owner.gravity =  owner.avgNormal * -owner.gravity_strength
		#I replaced += by = ti fix jump from grind bug but it may fuck something else, I don't know what I do
		owner.jumpVectors = owner.jumpVec

		
		owner.affected_by_gravity = false
		
		if owner.animationTree:
			owner.animationTree["parameters/StateMachineLocomotion/playback"].travel("BAKED_jump")
	
	else :
		if  _msg.has("align"):
			#owner.vel = owner.curSpeed * owner.get_dir()
			owner.avgNormal =  _msg["align"].normalized()
			#owner.jumpVec =  owner.avgNormal * owner.jump_strength
			#owner.gravity =  owner.avgNormal * -owner.gravity_strength
			
		owner.checkerGrind.set_deferred("monitoring", true)
		owner.affected_by_gravity = true
		if owner.animationTree:
			#owner.animationTree["parameters/StateMachineLocomotion/playback"].travel("BAKED_fall")
			owner.timerAnim.wait_time = 0.2
			owner.timerAnim.start()
	
func _physics_process(delta):
	owner.check_boost(delta)
	owner.checkRays(true)
	
	if owner.jumpVectors.length() < (owner.jumpVectors + owner.gravity).length() and owner.timerJumpRevertGrav.is_stopped():
	#if owner.jumpVectors.dot(owner.jumpVectors + owner.gravity) <0 :
		#owner.affected_by_gravity = true
		owner.checkerGrind.set_deferred("monitoring", true)
		if owner.timerEffectAirTrick.is_stopped() :
			owner.timerJumpRevertGrav.start()		
		#owner.animationTree["parameters/StateMachineLocomotion/playback"].travel("BAKED_fall")
		if owner.timerAnim.is_stopped() :
			owner.timerAnim.wait_time = 0.5
			owner.timerAnim.start()
		
	if owner.isBoost or !owner.timerEffectAirTrick.is_stopped():
		owner.velocity = owner.curSpeed * owner.get_dir()*1  + owner.jumpVectors/4
		
	else:
		owner.jumpVectors += owner.gravity
		owner.velocity = owner.curSpeed * owner.get_dir()*1 + owner.jumpVectors
	
	#prevent jump from going to hight when boost
	

	
	if owner.check_trick() :
		owner.animationTree["parameters/StateMachineLocomotion/playback"].start("BAKED_air_trick")
		owner.curSpeed = owner.boostSpeed
		owner.timerEffectAirTrick.start()
		owner.timerJumpRevertGrav.stop()
		owner.timerAnim.stop()
		
	
	owner.move()
	
	if owner.is_on_floor():
		#prevent leaving air while cooldown grind is running, might not be bullet proof
		if owner.checkerGroundJump.get_collision_normal().dot(owner.global_transform.basis.y) > .5 and owner.timerCoolDownGrind.is_stopped():
			owner.particlesJump.emitting = true;
			owner.checkerGrind.set_deferred("monitoring", false)
			owner.timerEffectAirTrick.stop()
			change_state.emit($"../Move")
			owner.SFXFall.play()
			
	if ConfigFileHandler.pad:
		#owner.character.rotation.y +=(Input.get_action_strength("move_left") - Input.get_action_strength("move_right")) * owner.STICK_SENS
		#this is copy pasted from the move state, maybe it should be moved to player
		var _v = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
		var _v_key = Input.get_vector("move_left_key", "move_right_key", "move_forward_key", "move_backward_key")
		if _v.dot(Vector2(0,-1))>-.5 and  _v.length()>0 :
			var _r = (Input.get_action_strength("move_left") - Input.get_action_strength("move_right")) * owner.STICK_SENS*1.2 * 1.5
		
		if _v_key.dot(Vector2(0,-1))>-.5 and  _v_key.length()>0 :
			var _r = (Input.get_action_strength("move_left_key") - Input.get_action_strength("move_right_key")) * owner.STICK_SENS*1.2 * 1.5
			owner.character.rotation.y += _r
			
func _input(event: InputEvent) -> void:
	#if event is InputEventMouseMotion  and !ConfigFileHandler.pad:
	#keyboard control
	if event is InputEventMouseMotion:
		owner.character.rotation.y += -event.relative.x * owner.MOUSE_SENS



func _on_timer_anim_timeout():
	owner.timerAnim.stop()
	owner.animationTree["parameters/StateMachineLocomotion/playback"].travel("BAKED_fall")


func _on_checker_grind_body_entered(body: Node3D) -> void:
	if owner.timerCoolDownGrind.is_stopped() :
		owner.timerEffectAirTrick.stop()
		change_state.emit($"../Grind",{_body = body})


func _on_timer_jump_revert_grav_timeout() -> void:
	owner.affected_by_gravity = true


func _on_timer_effect_air_trick_timeout() -> void:
	owner.timerJumpRevertGrav.start()
	owner.timerAnim.start()
