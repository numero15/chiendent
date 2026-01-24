extends StateFSM

func enter_state(_msg := {}) -> void:
	
	print("knockback")
	set_physics_process(true)
	set_process_input(true)
	owner.affected_by_gravity = false
	owner.curSpeed = owner.speedKnockBack
	owner.timerKnockBackDuration.start()
	owner.vel = owner.curSpeed *  _msg["new_dir"]
	owner.velocity = owner.vel
	owner.model.get_active_material(0).set("shader_parameter/albedo", Color(1.0, 0.0, 0.0, 1.0))
	owner.jumpVectors = owner.avgNormal
	owner.animationTree["parameters/StateMachineLocomotion/playback"].start("BAKED_fall")
	owner.SFXHurt.play()
	
	
func _physics_process(_delta: float) -> void:
	owner.avgNormal = lerp(owner.avgNormal,Vector3.UP,0.1)
	owner.jumpVectors += owner.gravity
	owner.curSpeed =lerp(owner.curSpeed,0.0,0.1)
	owner.velocity = owner.curSpeed * owner.velocity.normalized() + owner.jumpVectors	
	owner.move()
	var _c : Color = owner.model.get_active_material(0).get("shader_parameter/albedo")
	_c =  _c.lerp(Color.WHITE,0.1)
	owner.model.get_active_material(0).set("shader_parameter/albedo", _c)

func _on_timer_knock_back_duration_timeout() -> void:
	owner.model.get_active_material(0).set("shader_parameter/albedo", Color(1.0, 1.0, 1.0, 1.0))
	owner.curSpeed = 0
	if owner.is_on_floor():
		change_state.emit($"../Move")
	else :
		change_state.emit($"../Air")
	
