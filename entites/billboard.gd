extends Area3D
@onready var billboard = get_node("Billboard")
@onready var graph = get_node("Graphitti")
@onready var particles = get_node("GPUParticles3D")
@onready var SFXSuccess = get_node("AudioSuccess")
signal billboardActivated

func _on_area_entered(_area):
	graph.visible = true
	particles.emitting = true
	set_deferred("monitorable", false) 
	set_deferred("monitoring", false) 
	billboardActivated.emit()
	await get_tree().create_timer(.10).timeout
	SFXSuccess.play()
