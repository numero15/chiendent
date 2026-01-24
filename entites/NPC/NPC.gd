extends CharacterBody3D

#in case of preformance issue try to replace move_and_slide by move_and_collide

@export var speed_normal = 1.0
@export var speed_scared = 10.0
@onready var timer_scared : Timer = get_node("TimerScared")
@onready var timer_direction : Timer = get_node("TimerDirection")
@onready var raycasts : Node3D = get_node("RayCasts")
@onready var body : Node3D = get_node("Body")
#raycast performance https://www.youtube.com/watch?v=s2C2RO_WMh0

var speed  : float
var rng : RandomNumberGenerator

func _ready() -> void:
	rng = RandomNumberGenerator.new()
	speed = speed_normal
	set_direction()
	
	
func set_direction():
	#do not change when scared
	if speed == speed_scared :
		return
		
	if is_on_floor():
		#align raycasts with floor normal
		raycasts.quaternion = Quaternion(Vector3.UP, get_floor_normal())
	
	var possible_dirs : Array[Vector3] = []
	var new_dir : Vector3
	for _r in raycasts.get_children():
		possible_dirs.push_back(_r.global_transform.basis.z)
	#sort angles from closest to farest
	possible_dirs.sort_custom(sort_angles)
	#weighed random
	var random_float = rng.randf()
	if random_float < 0.8:
		new_dir = possible_dirs[rng.randi_range(0,int(possible_dirs.size()/4.0))]
	elif random_float < 0.95:
		new_dir = possible_dirs[rng.randi_range(int(possible_dirs.size()/4.0),int(possible_dirs.size()/4.0*2))]
	else:
		new_dir = possible_dirs[rng.randi_range(int(possible_dirs.size()/4.0*2.0),int(possible_dirs.size()/4.0*3))]
	velocity = new_dir * speed
	
	
func sort_angles(a, b):
	return a.angle_to(velocity.normalized()) < b.angle_to(velocity.normalized())
		
func set_dir_on_wall():
	var possible_dirs : Array[Vector3] = []
	#get possible directions
	for _r in raycasts.get_children():
		_r.enabled = true
		if not _r.is_colliding():
			possible_dirs.push_back(_r.global_transform.basis.z)
		_r.enabled = false
		
	possible_dirs.shuffle()
	velocity = possible_dirs[0] * speed
	
	
func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta	
		
	move_and_slide()
	if is_on_wall():
		set_dir_on_wall()
	
	#align body with velocity
	var direction = velocity.normalized()
	body.rotation.y = lerp(body.rotation.y, atan2(-direction.x, -direction.z),0.1)

func player_body_entered(_body: Node3D) -> void:
	timer_direction.stop()
	timer_scared.start()
	speed = speed_scared
	var _direction : Vector3 = self.global_transform.origin - _body.global_transform.origin
	_direction = _direction.normalized()
	velocity = _direction * speed

func _on_timer_scared_timeout() -> void:
	speed = speed_normal
	timer_direction.start()
