extends StateFSM

var path: Path3D
var curve: Curve3D
var points : Array
var index : int
var offset: float
var pathFollow : PathFollow3D
var direction : int = 1
var loop : bool = false;
var progress_ratio : float = 0.0;

func enter_state(_msg := {}) -> void:
	if !_msg.has("_body"):
		change_state.emit($"../Move")
		
	owner.particlesGrind.emitting = true;
	owner.particlesGrind.show();
	owner.checkerGrind.set_deferred("monitoring", false)
	set_physics_process(true)
	path = _msg["_body"].get_parent_node_3d()
	curve = path.curve
	
	for child in path.get_children():
		if child is CSGPolygon3D:
			if child.path_joined :
				loop = true

	# transform the target position to local space
	var path_transform: Transform3D = path.global_transform
	var local_pos: Vector3 = owner.global_position * path_transform

	# get the nearest offset on the curve
	offset = curve.get_closest_offset(local_pos)
	points = curve.get_baked_points()
	
	pathFollow = PathFollow3D.new()
	path.add_child(pathFollow)
	pathFollow.progress = offset
	progress_ratio = pathFollow.progress_ratio
	
	var curve_forward : Vector3 = -curve.sample_baked_with_rotation(offset).basis.z
	curve_forward = curve_forward.normalized()
	var vel_nor : Vector3 = owner.velocity.normalized()
	if curve_forward.dot(vel_nor) > 0 :
		direction = 1
	else :
		direction = -1
	
	#reset sprite rotation to make it automatically follow curve
	owner.character.rotation.y = 90

	
func _physics_process(delta):
	
	var  prev_progress_ratio : float
	var  prev_offset : float
	prev_progress_ratio = progress_ratio
	prev_offset = offset
	offset += owner.curSpeed*delta*direction
	pathFollow.progress = offset
	progress_ratio = pathFollow.progress_ratio
	#prevent looping if path is open
	if !loop:
		if direction == 1 && progress_ratio < prev_progress_ratio :
			change_state.emit($"../Air")
			return
		if direction == -1 && progress_ratio > prev_progress_ratio :
			change_state.emit($"../Air")
			return
	

	owner.global_transform = pathFollow.global_transform.rotated_local(Vector3.UP, -PI/2*direction)
	#owner.curSpeed-= 5*delta
	#if owner.curSpeed < 5 :
		#owner.curSpeed = 5
	
	if Input.is_action_just_pressed("ui_select"):
		change_state.emit($"../Air", {jump = curve.sample_baked_up_vector(offset, true)})
		owner.checkerGrind.set_deferred("monitoring", false)
	
func exit_state() -> void:
	set_physics_process(false)
	set_process_input(false)
	pathFollow.queue_free()
	owner.particlesGrind.emitting = false;
	owner.particlesGrind.hide();
	
