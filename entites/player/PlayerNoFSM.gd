extends CharacterBody3D

@export var affected_by_gravity: bool = true
@export var screen_lines: Node
@export var distortion: Node
@export var maxSpeed := 40.0

var gravity := Vector3(0,-3,0)
var jumpVec := Vector3( 0, 80, 0)
var avgNormal : Vector3 = Vector3.UP
var MOUSE_SENS := 0.005

var curSpeed := 0.0
var vel := Vector3.ZERO
var jumpVectors := Vector3.ZERO
var bodyOn : StaticBody3D

func _ready() -> void:
	#Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	$checkerGrind.connect("body_entered",bodyEntered)

#remove from player
func bodyEntered(_body:CSGPolygon3D) -> void:
	#detection du rail
	var path: Path3D = _body.get_parent_node_3d()
	var curve: Curve3D = path.curve

	# transform the target position to local space
	var path_transform: Transform3D = path.global_transform
	var local_pos: Vector3 = global_position * path_transform

	# get the nearest offset on the curve
	var offset: float = curve.get_closest_offset(local_pos)
	$"../Path3DRail/PathFollow3D".progress=offset

	# get the local position at this offset
	#var curve_pos: Vector3 = curve.sample_baked(offset, true)

	# transform it back to world space
	#curve_pos = path_transform * curve_pos

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		#$head/SpringArm3D/Camera.rotation.x += -event.relative.y * MOUSE_SENS 
		$head.rotation.y += -event.relative.x * MOUSE_SENS

func checkRays() -> void:
	var avgNor := Vector3.ZERO
	var numOfRaysColliding := 0
	for ray in $head/rayFolder.get_children():
		var r : RayCast3D = ray
		if r.is_colliding():
			numOfRaysColliding += 1
			avgNor += r.get_collision_normal()
	if avgNor and is_on_floor():
		avgNor /= numOfRaysColliding
		avgNormal = avgNor.normalized()
		jumpVec = avgNormal * 50
		gravity = avgNormal * -3
	elif affected_by_gravity: # ajouter ces lignes pour que le perso tombe/saute avec la gravité vers le bas
		avgNormal = avgNormal.lerp(Vector3.UP, .02)
		jumpVec = avgNormal * 50
		gravity = avgNormal * -3

#remove from palyer
func jump() -> void:
	jumpVectors += jumpVec
	#avgNormal = Vector3.UP
	jumpVec = avgNormal * 50
	gravity = avgNormal * -3
	

#remove from player
func _physics_process(delta: float) -> void:
	if is_on_floor():
		vel = curSpeed * get_dir()
	checkRays()
	
	if not is_on_floor():
		jumpVectors += gravity
	elif is_on_floor():
		jumpVectors = Vector3.ZERO
	if Input.is_action_just_pressed("ui_select"):
		jump() 
	
	velocity = vel+ jumpVectors
	
	move()
	
func move():
	up_direction = avgNormal.normalized()
	move_and_slide()
	#empèche de monter un angle à 90°	
	#if !_isWall and $head/RayCastGround.is_colliding():
	if !isWall() :
		var _transform= align_with_up(global_transform,up_direction)
		global_transform = global_transform.interpolate_with(_transform, .4)
		
	distortion.material.set("shader_parameter/coeff", velocity.length()/150)
	distortion.material.set("shader_parameter/aberration_amount", velocity.length()/300.0 )
	

func isWall()-> bool:
	var _isWall : bool = false
	for ray in $head/rayFolderWall.get_children():
		if ray.is_colliding():
			_isWall = true
	return _isWall

func get_dir() -> Vector3:
	var dir : Vector3 = Vector3.ZERO
	var fowardDir : Vector3 = ( $head/SpringArm3D/Camera/Marker3D.global_transform.origin - $head.global_transform.origin  ).normalized()
	var dirBase :Vector3= avgNormal.cross( fowardDir ).normalized()
	dir = dirBase.rotated( avgNormal.normalized(), -PI/2 )
	if Input.is_action_pressed("ui_up"):		
		curSpeed = lerp(curSpeed,maxSpeed,.01)
	else :
		curSpeed = lerp(curSpeed,0.0,.1)
	return dir.normalized()
	
func align_with_up(_transform : Transform3D,_new_up:Vector3) -> Transform3D :
	#https://www.youtube.com/watch?v=7axJJYont6Y
	_transform.basis.y = _new_up
	_transform.basis.x = -_transform.basis.z.cross(_new_up)
	_transform.basis = _transform.basis.orthonormalized()
	return _transform
	
