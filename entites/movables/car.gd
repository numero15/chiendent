extends PathFollow3D

@export var move_speed: float = 10.0


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	progress += delta * move_speed
	pass
