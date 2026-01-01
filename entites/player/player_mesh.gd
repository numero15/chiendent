@tool
extends MeshInstance3D

@export_range(0.0,16.0) var weight := 8.0

@onready var lag_transform := global_transform

func _process(delta):
	# lag_transform gradually approaches the current transform over time
	lag_transform = lag_transform.interpolate_with(global_transform, weight*delta)
	get_surface_override_material(0).set_shader_parameter("lag_transform", lag_transform)
