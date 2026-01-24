extends PathFollow3D

@export var move_speed: float = 10.0
@onready var car_mesh =  get_node("Car/MeshInstance3D")
@onready var car_collision =  get_node("Car/CollisionShape3D")

func _ready() -> void:
	if move_speed < 0 :
		car_mesh.rotate_y(PI)
		car_collision.rotate_y(PI)
		car_mesh.transform.origin.x = 3
		car_collision.transform.origin.x = 3
	else:
		car_mesh.transform.origin.x = -3
		car_collision.transform.origin.x = -3
		

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	progress += delta * move_speed
	pass
