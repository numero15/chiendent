extends CharacterBody3D

var affected_by_gravity: bool = true
@export var screen_lines: Node
@export var distortion: Node
@export var maxSpeed := 25.0
@export var gravity_strength :float= .5
@export var jump_strength :float= 20

@onready var checkerGrind = get_node("checkerGrind")
@onready var character = get_node("head")
@onready var checkerGround = get_node("head/RayCastGround")
@onready var particlesGrind = get_node("head/ParticlesGrind")

var gravity := Vector3(0,-3,0)
var jumpVec := Vector3( 0, 80, 0)
var avgNormal : Vector3 = Vector3.UP
var MOUSE_SENS := 0.003
var KEYBOARD_SENS := 0.1

var curSpeed := 0.0
var vel := Vector3.ZERO
var jumpVectors := Vector3.ZERO
var bodyOn : StaticBody3D

var movement_dir : Vector3

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
func _physics_process(delta):
	distortion.material.set("shader_parameter/coeff", curSpeed/150)
	#distortion.material.set("shader_parameter/aberration_amount", curSpeed/80.0 )

#rotate camera vertically
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		$head/SpringArm3D.rotation.x += -event.relative.y * MOUSE_SENS
		if $head/SpringArm3D.rotation.x > 0.4 :
			$head/SpringArm3D.rotation.x = 0.4
		if $head/SpringArm3D.rotation.x < -1.5 :
			$head/SpringArm3D.rotation.x = -1.5

func checkRays() -> void:

	var avgNor := Vector3.ZERO
	var numOfRaysColliding := 0
	for ray in $head/rayFolder.get_children():
		var r : RayCast3D = ray
		if r.is_colliding():
			numOfRaysColliding += 1
			avgNor += r.get_collision_normal()
	print (affected_by_gravity)
	if avgNor and is_on_floor() and $head/RayCastGround.is_colliding() :
		if isWall() :return
		
		avgNor /= numOfRaysColliding
		avgNormal = avgNor.normalized()
		jumpVec = avgNormal * jump_strength
		gravity = avgNormal * -gravity_strength
	elif affected_by_gravity: # ajouter ces lignes pour que le perso tombe/saute avec la gravité vers le bas
		
		if $head/RayCastGroundJump.is_colliding():
			avgNor = Vector3.ZERO
			avgNor = $head/RayCastGroundJump.get_collision_normal()
		else :
			avgNor = Vector3.UP
		#avgNormal = avgNormal.lerp(avgNor, .025)
		avgNormal = avgNormal.lerp(avgNor, .04)
		jumpVec = avgNormal * jump_strength
		gravity = avgNormal * -gravity_strength

func move():
	up_direction = avgNormal.normalized()
	move_and_slide()
	#empèche de monter un angle à 90°	
	#if !_isWall and $head/RayCastGround.is_colliding():
	if !isWall() or affected_by_gravity :
		var _transform= align_with_up(global_transform,up_direction)
		global_transform = global_transform.interpolate_with(_transform, .4)
	

func isWall()-> bool:
	var _isWall : bool = false
	for ray in $head/rayFolderWall.get_children():
		if ray.is_colliding():
			_isWall = true
	return _isWall

func get_dir() -> Vector3:
	var dir : Vector3 = Vector3.ZERO
	var fowardDir : Vector3 = ( $head/ForwardMarker.global_transform.origin - $head.global_transform.origin  ).normalized()
	var dirBase :Vector3= avgNormal.cross( fowardDir ).normalized()
	dir = dirBase.rotated( avgNormal.normalized(), -PI/2 )
	#accelerate
	if Input.is_action_pressed("ui_up") && !Input.is_action_pressed("ui_down"):
		curSpeed = lerp(curSpeed,maxSpeed,.01)		
	#brake
	elif Input.is_action_pressed("ui_down"):
		curSpeed = lerp(curSpeed,0.0,.08)
	#decelerate
	else :
		curSpeed = lerp(curSpeed,0.0,.03)
		
	return dir.normalized()
	
func align_with_up(_transform : Transform3D,_new_up:Vector3) -> Transform3D :
	#https://www.youtube.com/watch?v=7axJJYont6Y
	_transform.basis.y = _new_up
	_transform.basis.x = -_transform.basis.z.cross(_new_up)
	_transform.basis = _transform.basis.orthonormalized()
	return _transform
	
