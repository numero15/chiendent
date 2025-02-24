extends CharacterBody3D

@export var speed_normal = 1.0
@export var speed_scared = 10.0
@onready var timer_scared : Timer = get_node("TimerScared")
@onready var timer_direction : Timer = get_node("TimerDirection")

var speed
var rng 
var angle : float

func _ready() -> void:
	rng = RandomNumberGenerator.new()
	angle = rng.randf()*2-1
	set_direction()
	speed = speed_normal
	
func set_direction():
	angle = rng.randf()*2-1
	
func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	var vy = velocity.y
	var turn_speed = 2
	velocity = Vector3.ZERO
	var move = 1
	velocity += -transform.basis.z * move * speed
	rotate_y(turn_speed * angle * delta)
	velocity.y = vy
	angle = angle*0.9
	move_and_slide()

func player_body_entered(body: Node3D) -> void:
	timer_direction.stop()
	timer_scared.start()
	speed = speed_scared
	var _direction = self.global_transform.origin - body.global_transform.origin
	_direction = _direction.normalized()
	rotation=Vector3.ZERO
	rotate_y(atan2(-_direction.x, -_direction.z))

func _on_timer_scared_timeout() -> void:
	speed = speed_normal
	timer_direction.start()
