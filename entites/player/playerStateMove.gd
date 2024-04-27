extends StateFSM

func enter_state(_msg := {}) -> void:
	set_physics_process(true)
	set_process_input(true)
	owner.affected_by_gravity = false
	
	print('move')
	if owner.animationTree:
		owner.animationTree["parameters/StateMachineLocomotion/playback"].travel("BAKED_push")
		owner.timerAnim.stop()

		
func _physics_process(delta):
	
	owner.movement_dir.x = Input.get_action_strength("ui_left") - Input.get_action_strength("ui_right")
	owner.movement_dir.z = Input.get_action_strength("ui_up") - Input.get_action_strength("ui_down")
	#owner.character.rotation.y += owner.movement_dir.x * owner.KEYBOARD_SENS
	
	owner.vel = owner.curSpeed * owner.get_dir()
	owner.check_boost(delta)
	owner.checkRays()
	owner.jumpVectors = Vector3.ZERO
	owner.velocity = owner.vel + owner.jumpVectors
	owner.move()
	
	if Input.is_action_pressed("ui_down") && owner.curSpeed >3:
		owner.particlesGrind.emitting = true;
		owner.particlesGrind.show();
	else :
		owner.particlesGrind.emitting = false;
		owner.particlesGrind.hide();
	
	if !Input.is_action_pressed("ui_up"):
		owner.animationTree["parameters/StateMachineLocomotion/playback"].travel("BAKED_idle")
	else :
		owner.animationTree["parameters/StateMachineLocomotion/playback"].travel("BAKED_push")
		
	if not owner.is_on_floor():
		change_state.emit($"../Air")
	

	if Input.is_action_just_pressed("ui_select"):
		#owner.particlesJump.emitting = true;
		change_state.emit($"../Air", {jump = owner.avgNormal})	

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		
		
		#UGGGGLY
		var i : float = clamp(-event.relative.x/20,-.5,.5) + .5
		var j : float = owner.animationTree["parameters/Blend2/blend_amount"]
		owner.animationTree["parameters/Blend2/blend_amount"]= lerpf(j,i,.05)
		owner.character.rotation.y += -event.relative.x * owner.MOUSE_SENS
		
		
		owner.characterMesh.rotation.z  = lerp(owner.characterMesh.rotation.z, event.relative.x/1000*owner.curSpeed,.1)
	else :
		owner.characterMesh.rotation.z  = lerp(owner.characterMesh.rotation.z,0.0,.1)

func _on_checker_grind_body_entered(body):
	change_state.emit($"../Grind",{_body = body})
