extends Area3D
@onready var billboard = get_node("Billboard")
@onready var graph = get_node("Graphitti")
@onready var particles = get_node("GPUParticles3D")
signal billboardActivated

func _on_area_entered(_area):
	graph.visible = true
	particles.emitting = true
	set_deferred("monitorable", false) 
	set_deferred("monitoring", false) 
	billboardActivated.emit()
