extends StateFSM

var drift_multiplier_turn : float  = 1.8#2.5

func enter_state(_msg := {}) -> void:
	set_physics_process(true)
	set_process_input(true)
	owner.affected_by_gravity = false
	owner.minSpeed = owner.minSpeedMove
	
	print('move')
	if owner.animationTree:
		if Input.is_action_pressed("ui_drift") and owner.curBoost>0:
			owner.animationTree["parameters/StateMachineLocomotion/playback"].start("BAKED_drift")
		else :
			owner.animationTree["parameters/StateMachineLocomotion/playback"].travel("BAKED_push")
		owner.timerAnim.stop()
		
	if Input.is_action_pressed("move_backward") or Input.is_action_pressed("move_backward_key"):
		owner.animationTree["parameters/StateMachineLocomotion/playback"].start("BAKED_brake")
		
func _physics_process(delta):

	owner.vel = owner.curSpeed * owner.get_dir()
	owner.check_boost(delta)
	owner.checkRays()
	owner.jumpVectors = Vector3.ZERO
	owner.velocity = owner.vel + owner.jumpVectors
	owner.move()
	
	#check for pushers (cars, etc.)
	for i in owner.get_slide_collision_count():
		var collision = owner.get_slide_collision(i)
		if collision.get_collider().is_in_group("pushers"):
			owner.timerFootstep.stop()
			change_state.emit($"../KnockBack",{new_dir = collision.get_normal()})
	

	if owner.velocity.length()>1 and owner.timerFootstep.is_stopped() :
		owner.timerFootstep.start()
	if owner.velocity.length()<=1:
		owner.timerFootstep.stop()

	
	if Input.is_action_pressed("ui_down") && owner.curSpeed >1:
		owner.particlesGrind.emitting = true;
		owner.particlesGrind.show();
		owner.particlesGrind2.emitting = true;
		owner.particlesGrind2.show();
	else :
		owner.particlesGrind.emitting = false;
		owner.particlesGrind.hide();
		owner.particlesGrind2.emitting = false;
		owner.particlesGrind2.hide();
	
	var _v = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var _v_key = Input.get_vector("move_left_key", "move_right_key", "move_forward_key", "move_backward_key")
	#pad input
	if (_v.normalized().dot(Vector2(0,-1))>-.5 and  _v.length()>0.8):
		owner.animationTree["parameters/StateMachineLocomotion/playback"].travel("BAKED_push")
	#key input
	elif (_v_key.normalized().dot(Vector2(0,-1))>-.5 and  _v_key.length()>0.8):
		owner.animationTree["parameters/StateMachineLocomotion/playback"].travel("BAKED_push")
	else :
		owner.animationTree["parameters/StateMachineLocomotion/playback"].travel("BAKED_idle")
		
	if Input.is_action_just_pressed("move_backward") or Input.is_action_just_pressed("move_backward_key"):
		owner.animationTree["parameters/StateMachineLocomotion/playback"].start("BAKED_brake")
	
	
	if ConfigFileHandler.pad or !ConfigFileHandler.pad:
		var multiplier = .85
		owner.maxSpeed = owner.maxSpeedMove
		owner.acceleration = owner.accelerationMove
		if Input.is_action_pressed("ui_drift") and owner.curBoost>0 and owner.curSpeed>4.0:
			if owner.curSpeed > owner.maxSpeedManual :
				owner.maxSpeed = owner.curSpeed
			else :
				owner.maxSpeed = owner.maxSpeedManual
			#cap speed to the max grind --> the fasteest move mode
			if owner.maxSpeed > owner.maxSpeedGrind :
				owner.maxSpeed = owner.maxSpeedGrind
				
			owner.animationTree["parameters/StateMachineLocomotion/playback"].travel("BAKED_drift")
			if not owner.SFXDrift.is_playing():
				owner.SFXDrift.play()
			owner.particlesDust.emitting = true;
			owner.boostChanged.emit(owner.curBoost, owner.maxBoost)
			multiplier = drift_multiplier_turn
			owner.curBoost -= delta*5
			if owner.curBoost<0 : owner.curBoost = 0
			
			if owner.check_trick():
				owner.animationTree["parameters/StateMachineLocomotion/playback"].start("BAKED_drift_trick")
				#TODO change the way the custom max speed is set
				owner.curSpeed = lerp(owner.curSpeed,owner.maxSpeed,.5)
		else :
			owner.particlesDust.emitting = false;
			owner.SFXDrift.stop()
			
		if _v.dot(Vector2(0,-1))>-.5 and  _v.length()>0 :
			var _r = (Input.get_action_strength("move_left") - Input.get_action_strength("move_right")) * owner.STICK_SENS*1.2 * multiplier
			owner.character.rotation.y += _r
			
		if _v_key.dot(Vector2(0,-1))>-.5 and  _v_key.length()>0 :
			var _r = (Input.get_action_strength("move_left_key") - Input.get_action_strength("move_right_key")) * owner.STICK_SENS*1.2 * multiplier
			owner.character.rotation.y += _r
			
			
			var i : float = clamp(_r*30,-.5,.5) + .5
			var j : float = owner.animationTree["parameters/Blend2/blend_amount"]
			owner.animationTree["parameters/Blend2/blend_amount"]= lerpf(j,i,.05)
			
			
	if not owner.is_on_floor():
		owner.timerFootstep.stop()
		change_state.emit($"../Air")
	

	if Input.is_action_just_pressed("ui_jump"):
		owner.timerFootstep.stop()
		owner.SFXDrift.stop()
		change_state.emit($"../Air", {jump = owner.avgNormal})
		
		
		
func _input(event: InputEvent) -> void:
	#keyboard control
	if event is InputEventMouseMotion:
		pass
		#UGGGGLY
		#var i : float = clamp(-event.relative.x/20,-.5,.5) + .5
		#var j : float = owner.animationTree["parameters/Blend2/blend_amount"]
		#owner.animationTree["parameters/Blend2/blend_amount"]= lerpf(j,i,.05)		
		#owner.character.rotation.y += -event.relative.x * owner.MOUSE_SENS
		
		
		#owner.characterMesh.rotation.z  = lerp(owner.characterMesh.rotation.z, event.relative.x/1000*owner.curSpeed,.1)
	#else :
		#owner.characterMesh.rotation.z  = lerp(owner.characterMesh.rotation.z,0.0,.1)

func _on_checker_grind_body_entered(_body):
	pass

func _on_timer_footstep_timeout() -> void:
	owner.SFXFootstep.play()
	
func exit_state() -> void:
	if  is_instance_valid(owner.particlesGrind):
		owner.particlesGrind.emitting = false;
		owner.particlesGrind2.emitting = false;
		owner.particlesGrind.hide();
		owner.particlesGrind2.hide();
		
		set_physics_process(false)
		set_process_input(false)
	
	
