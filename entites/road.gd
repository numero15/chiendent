extends Path3D

@export_range(5.0, 20.0, 1.0) var distance_between_cars : float = 5.0
@export_range(0.0, 20.0, 1.0) var distance_variance : float = 0.0
@export_range(5.0, 20.0, 1.0) var speed : float = 5.0
var car_scene = preload("res://entites/movables/car.tscn")

func _ready() -> void:
	var curve_length = curve.get_baked_length()
	var curve_pos = 0
	while (curve_pos + distance_between_cars) < curve_length :
		curve_pos += distance_between_cars + randf_range(0.0, distance_variance)
		var car_instance = car_scene.instantiate()
		car_instance.move_speed = speed
		car_instance.progress = curve_pos
		add_child(car_instance)
		
	curve_pos = 0
	while (curve_pos + distance_between_cars) < curve_length :
		curve_pos += distance_between_cars + randf_range(0.0, distance_variance)
		var car_instance = car_scene.instantiate()
		car_instance.move_speed = -speed
		car_instance.progress = curve_pos
		add_child(car_instance)
	

func _process(delta: float) -> void:
	pass
