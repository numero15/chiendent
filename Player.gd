extends CharacterBody3D

@export var affected_by_gravity: bool = true
@export var screen_lines: Node
@export var distortion: Node

var gravity := Vector3(0,-3,0)
var jumpVec := Vector3( 0, 80, 0)
var avgNormal : Vector3 = Vector3.UP
var MOUSE_SENS := 0.005
var maxSpeed := 40.0
var minSpeed := 5.0
var curSpeed := 0.0
var vel := Vector3.ZERO
var jumpNum := 0
var maxJumpAmt := 10
var extraVel := Vector3.ZERO
var theUpDir := Vector3.UP
var jumpVectors := Vector3.ZERO
var bodyOn : StaticBody3D
var mouseSensMulti := 1

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	$checker.connect("body_entered",bodyEntered)
	
func bodyEntered(body:PhysicsBody3D) -> void:
	if body and body != bodyOn and body is StaticBody3D:
		bodyOn = body
		jumpVectors = Vector3.ZERO

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

#func _process(delta: float) -> void:
	#
	#if Input.is_action_just_pressed("shift"):
		#speed = 10.0
	#if Input.is_action_just_released("shift"):
		#speed = 50.0

func jump() -> void:
	jumpVectors += jumpVec
	#avgNormal = Vector3.UP
	jumpVec = avgNormal * 50
	gravity = avgNormal * -3
	

func _physics_process(delta: float) -> void:
	if is_on_floor():
		vel = curSpeed * get_dir()
	checkRays()
	if not is_on_floor():
		jumpVectors += gravity
#		avgNormal = Vector3.UP
	elif is_on_floor():
		jumpVectors = Vector3.ZERO
	if Input.is_action_just_pressed("ui_select"):
		jump() 
	#vel += jumpVectors
	
	velocity = vel+ jumpVectors
	up_direction = avgNormal.normalized()
	move_and_slide()
	#empèche de monter un angle à 90°
	var _isWall : bool = false
	for ray in $head/rayFolderWall.get_children():
		if ray.is_colliding():
			_isWall = true
	#if !_isWall and $head/RayCastGround.is_colliding():
	if !_isWall :
		var _transform= align_with_up(global_transform,up_direction)
		global_transform = global_transform.interpolate_with(_transform, .4)
		
	distortion.get_material().set("shader_param/coeff", velocity.length()/150)
	distortion.get_material().set("shader_param/aberration_amount", velocity.length()/300.0 )

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
	
func above_ground()->void :
	pass
