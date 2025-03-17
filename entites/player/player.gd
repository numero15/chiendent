class_name Player
extends CharacterBody3D

var affected_by_gravity: bool = true
@export var screen_lines: Node
@export var distortion: Node
@export var maxSpeedMove := 20.0
@export var maxSpeedManual := 30.0
@export var minSpeedGrind := 2.0
@export var drift_multiplier_speed : float  = 2.5
@export var boostSpeed := 40.0
@export var gravity_strength :float= .5
@export var jump_strength :float= 20

@onready var checkerGrind = get_node("head/checkerGrind")
@onready var character = get_node("head")
@onready var characterMesh = get_node("head/character_rigged")
@onready var checkerGround = get_node("head/RayCastGround")
@onready var checkerGroundJump = get_node("head/RayCastGroundJump")
@onready var particlesGrind = get_node("head/BoneAttachmentFoot/ParticlesGrind")
@onready var particlesGrind2 = get_node("head/BoneAttachmentFoot2/ParticlesGrind")

@onready var trail = get_node("head/Trail")
@onready var particlesBoost = get_node("head/Trail/Node3D/ParticlesBoost")
@onready var particlesJump = get_node("head/ParticlesJump")
@onready var particlesTrick = get_node("head/ParticlesTrick")
@onready var particlesDust = get_node("head/ParticlesDust")
@onready var animationTree = get_node("AnimationTree")
@onready var camera = get_node("Camera3D")
@onready var timerAnim = get_node("TimerAnim")
@onready var timerTrick = get_node("TimerTrick")
@onready var timerCoolDownGrind : Timer = get_node("TimerCoolDownGrind")
@onready var timerEffectAirTrick : Timer = get_node("TimerEffectAirTrick")
@onready var timerResetCamera : Timer = get_node("TimerResetCamera")
@onready var SFXTrick : AudioStreamPlayer = get_node("AudioTrickFX")
@onready var SFXTrickMiss : AudioStreamPlayer = get_node("AudioTrickFXMiss")
@onready var SFXStartGrind : AudioStreamPlayer = get_node("AudioFXStartGrind")
@onready var SFXStartBoost : AudioStreamPlayer = get_node("AudioFXStartBoost")
@onready var SFXVoiceTrick : AudioStreamPlayer = get_node("AudioFXVoiceTrick")
@onready var SFXFall : AudioStreamPlayer = get_node("AudioFXFall")
@onready var SFXVoiceJump : AudioStreamPlayer = get_node("AudioFXVoiceJump")
@onready var SFXFootstep : AudioStreamPlayer = get_node("AudioFootstep")
@onready var timerFootstep = get_node("TimerFootstep")
@onready var timerJumpRevertGrav = get_node("TimerJumpRevertGrav")

var gravity := Vector3(0,-3,0)
var jumpVec := Vector3( 0, 80, 0)
var avgNormal : Vector3 = Vector3.UP
var MOUSE_SENS := 0.003
var STICK_SENS := 0.03
var KEYBOARD_SENS := 0.1


var maxSpeed
var curSpeed := 0.0
var vel := Vector3.ZERO
var jumpVectors := Vector3.ZERO
var bodyOn : StaticBody3D
var default_camera_rotation : Vector3
var tweenCamera : Tween

#var movement_dir : Vector3
var avgNor := Vector3.ZERO

var maxBoost: float = 30
var curBoost : float = 30
var isBoost = false

var trickCount : int = 0

var control_settings

signal boostChanged(value, max)



func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	animationTree["parameters/Blend2/blend_amount"]=1
	animationTree["parameters/Blend2 2/blend_amount"]=1
	maxSpeed = maxSpeedMove
	
	default_camera_rotation = $head/SpringArm3D.rotation
	tweenCamera = get_tree().create_tween()
	
	control_settings = ConfigFileHandler.load_control_settings()
	
func _physics_process(delta):
	
	screen_lines.material.set("shader_parameter/line_density",clamp(curSpeed - maxSpeed,0,50)/25)
	
	if curSpeed-1 <= maxSpeed :
		distortion.material.set("shader_parameter/aberration_amount", curSpeed/40.0 + 0.3 )
		distortion.material.set("shader_parameter/coeff", curSpeed/150)
		distortion.material.set("shader_parameter/blur_power", 0)		
		
	else :
		#distortion.material.set("shader_parameter/aberration_amount", curSpeed/20.0 )
		#distortion.material.set("shader_parameter/coeff", curSpeed/75)
		#distortion.material.set("shader_parameter/blur_power", curSpeed/800)	
		distortion.material.set("shader_parameter/aberration_amount", curSpeed/5.0 )
		distortion.material.set("shader_parameter/coeff", curSpeed/30)
	
	if curBoost<maxBoost and !Input.is_action_pressed("ui_boost") and !Input.is_action_pressed("ui_drift") :
		curBoost += delta*2
		if curBoost > maxBoost :
			curBoost = maxBoost
		boostChanged.emit(curBoost, maxBoost)
		
	#rotate camera with stick
	if ConfigFileHandler.pad:
		var rotX
		var rotY
		if control_settings.invertY :
			rotY  = Input.get_action_strength("rotate_camera_down") - Input.get_action_strength("rotate_camera_up")
		else :
			rotY  = Input.get_action_strength("rotate_camera_up") - Input.get_action_strength("rotate_camera_down")
		rotate_camera_x(rotY * STICK_SENS)
		
		if control_settings.invertX :
			rotX = Input.get_action_strength("rotate_camera_right") - Input.get_action_strength("rotate_camera_left")
		else :
			rotX = Input.get_action_strength("rotate_camera_left") - Input.get_action_strength("rotate_camera_right")			
			
		rotate_camera_y(rotX * STICK_SENS)
		
		if abs(Input.get_action_strength("rotate_camera_down") - Input.get_action_strength("rotate_camera_up"))>.01 or abs(Input.get_action_strength("rotate_camera_right") - Input.get_action_strength("rotate_camera_left")) >.01 :
			timerResetCamera.stop()
			tweenCamera.stop()
		elif timerResetCamera.is_stopped() :
			timerResetCamera.start()
		
		if Input.is_action_pressed("reset_camera") :
			var tween = get_tree().create_tween()
			tween.tween_property($head/SpringArm3D, "rotation", default_camera_rotation , .2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
			#$head/SpringArm3D.rotation.x = 0
			#$head/SpringArm3D.rotation.y = 0
			
		

func _input(event: InputEvent) -> void:
	#mouse control
	if event is InputEventMouseMotion and !ConfigFileHandler.pad:
		rotate_camera_x(-event.relative.y * MOUSE_SENS)

func rotate_camera_x(_x:float =0):
	$head/SpringArm3D.rotation.x +=_x
	if $head/SpringArm3D.rotation.x > 0.4 :
		$head/SpringArm3D.rotation.x = 0.4
	if $head/SpringArm3D.rotation.x < -1.5 :
		$head/SpringArm3D.rotation.x = -1.5

func rotate_camera_y(_y:float =0):
	$head/SpringArm3D.rotation.y +=_y
	if $head/SpringArm3D.rotation.y > 1.5 :
		$head/SpringArm3D.rotation.y = 1.5
	if $head/SpringArm3D.rotation.y < -1.5 :
		$head/SpringArm3D.rotation.y = -1.5

func checkRays(air : bool = false) -> void:
	var numOfRaysColliding := 0
	var coef_lerp: float = 0.02
	for ray in $head/rayFolder.get_children():
		var r : RayCast3D = ray
		if r.is_colliding():
			numOfRaysColliding += 1
			avgNor += r.get_collision_normal()
	if avgNor and is_on_floor() and $head/RayCastGround.is_colliding()  :
		if isWall() :return
		avgNor /= numOfRaysColliding
		avgNormal = avgNor.normalized()
		jumpVec = avgNormal * jump_strength
		gravity = avgNormal * -gravity_strength
	elif affected_by_gravity: # ajouter ces lignes pour que le perso tombe/saute avec la gravité vers le bas
		if $head/RayCastGroundJump.is_colliding() and !is_on_floor() and !is_on_wall():
			#if $head/RayCastGroundJump.get_collision_normal().normalized().dot(global_transform.basis.y) > .8:
			avgNor = $head/RayCastGroundJump.get_collision_normal().normalized()
			coef_lerp = 0.08
			
			#else :
				#avgNor = Vector3.UP
				#coef_lerp = 0.04
		else :
			avgNor = Vector3.UP
			#coef_lerp = 0.02
			coef_lerp = 0.08
		avgNormal = avgNormal.lerp(avgNor, coef_lerp)
		jumpVec = avgNormal * jump_strength
		gravity = avgNormal * -gravity_strength
	else :
		avgNor = Vector3.ZERO

func move():
	up_direction = avgNormal.normalized()
	move_and_slide()
	
	#push back physical objects
	var push_force = 5
	for i in get_slide_collision_count():
		var c := get_slide_collision(i)		
		if c.get_collider() is RigidBody3D:
			var push_dir = -c.get_normal() + Vector3(0,.7,0)
			push_dir = push_dir.normalized()
			c.get_collider().apply_central_impulse(push_dir * push_force)
			c.get_collider().angular_velocity = push_dir * 10
			
			
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
			
	#if _isWall and curSpeed>0 and is_on_wall():
		#var a = Quaternion(character.global_transform.basis)
		#var b = Quaternion(character.global_transform.basis.looking_at(velocity.normalized(),character.global_transform.basis.y))
		#var c = a.slerp(b,0.05)
		#character.global_transform.basis = Basis(c)
	return _isWall

func get_dir() -> Vector3:
	var dir : Vector3 = Vector3.ZERO
	var fowardDir : Vector3 = ( $head/ForwardMarker.global_transform.origin - $head.global_transform.origin  ).normalized()
	var dirBase :Vector3= avgNormal.cross( fowardDir ).normalized()
	dir = dirBase.rotated( avgNormal.normalized(), -PI/2 )
	#accelerate
	
	if curSpeed>maxSpeed:
		curSpeed = lerp(curSpeed,maxSpeed,.03)
		
	if !ConfigFileHandler.pad : 
		if Input.is_action_pressed("ui_up") && !Input.is_action_pressed("ui_down"):
			curSpeed = lerp(curSpeed,maxSpeed,.01)
		#brake
		elif Input.is_action_pressed("ui_down"):
			curSpeed = lerp(curSpeed,0.0,.08)
		#decelerate
		else :
			curSpeed = lerp(curSpeed,0.0,.03)
	
	if ConfigFileHandler.pad : 
		var _v = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
		
		if Input.get_action_strength("move_backward") >0.8 :
			curSpeed = lerp(curSpeed,0.0,.08)
			
		elif _v.dot(Vector2(0,-1))>-.5 and  _v.length()>.8 :
			curSpeed = lerp(curSpeed,maxSpeed,.01)
		
		else :
			curSpeed = lerp(curSpeed,0.0,.03)
		
	return dir.normalized()
	
func align_with_up(_transform : Transform3D,_new_up:Vector3) -> Transform3D :
	#https://www.youtube.com/watch?v=7axJJYont6Y
	_transform.basis.y = _new_up
	_transform.basis.x = -_transform.basis.z.cross(_new_up)
	_transform.basis = _transform.basis.orthonormalized()
	return _transform
	
	
func check_boost(delta):
	if Input.is_action_just_pressed("ui_boost") and curBoost > 0:
		SFXStartBoost.play()
		
	if Input.is_action_pressed("ui_boost") and curBoost > 0:
		trail.visible = true
		curSpeed = lerp(curSpeed,boostSpeed,.2)
		curBoost -= delta*30
		boostChanged.emit(curBoost, maxBoost)
		isBoost = true
		particlesBoost.emitting = true
		camera.fov = lerpf(camera.fov,110,.2)
		#camera.fov = 95
	else :
		trail.visible = false
		isBoost = false
		particlesBoost.emitting = false
		camera.fov = lerpf(camera.fov,75,.01)
		
	if curBoost<0 : curBoost = 0
	
	
func check_trick() -> bool:
	if Input.is_action_just_pressed("ui_trick") :
		
		if timerTrick.is_stopped() :
			trick()
			return true
		elif timerTrick.time_left < .2 :
			trick()
			return true
		elif  timerTrick.time_left > .2 :
			SFXTrickMiss.play()
			trickCount = 0
			return false
		else :
			return false
		
	else :
		return false

func trick() :
	trickCount += 1
	curBoost += 1
	timerTrick.stop()
	timerTrick.start()
	if curBoost>maxBoost: curBoost = maxBoost
	particlesTrick.emitting = true;
	SFXTrick.play()
	SFXVoiceTrick.play()
	
func _on_timer_trick_timeout() -> void:
	trickCount = 0


func _on_timer_camera_replace_timeout() -> void:
	tweenCamera = get_tree().create_tween()
	tweenCamera.tween_property($head/SpringArm3D, "rotation", default_camera_rotation , 3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
