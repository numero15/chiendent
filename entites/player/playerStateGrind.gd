extends State

var path: Path3D
var curve: Curve3D
var points : Array
var index : int
var offset: float
var pathFollow : PathFollow3D
var direction : int = 1

func enter_state(_msg := {}) -> void:
	if !_msg.has("_body"):
		change_state.emit($"../Move")
		
		
	owner.checkerGrind.set_deferred("monitoring", false)
	set_physics_process(true)
	path = _msg["_body"].get_parent_node_3d()
	curve = path.curve

	# transform the target position to local space
	var path_transform: Transform3D = path.global_transform
	var local_pos: Vector3 = owner.global_position * path_transform

	# get the nearest offset on the curve
	offset = curve.get_closest_offset(local_pos)
	points = curve.get_baked_points()
	
	pathFollow = PathFollow3D.new()
	path.add_child(pathFollow)
	pathFollow.progress = offset
	
	var curve_forward : Vector3 = -curve.sample_baked_with_rotation(offset).basis.z
	print(curve_forward)
	curve_forward = curve_forward.normalized()
	var vel_nor : Vector3 = owner.velocity.normalized()
	if curve_forward.angle_to(vel_nor) < PI/4 :
		direction = 1
	else :
		direction = -1

	
func _physics_process(delta):
	offset += 20*delta*direction
	pathFollow.progress = offset
	owner.global_transform = pathFollow.global_transform.rotated_local(Vector3.UP, -PI/2*direction)
	
	
func exit_state() -> void:
	pathFollow.queue_free()
	