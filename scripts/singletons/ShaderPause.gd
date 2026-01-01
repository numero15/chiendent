extends Node

var shader_time : float = 0.0

func _process(delta: float) -> void:
	if get_tree().paused == false:  
		shader_time += delta
	set_shader_time(shader_time)

func set_shader_time(value : float):
	var group_nodes = get_tree().get_nodes_in_group("shader_nodes")
	for node in group_nodes:
		if node is MeshInstance3D:
			
			var shader_material : ShaderMaterial = node.get_active_material( 0 )
			shader_material.set_shader_parameter("shader_time", value)
			#var material = node.material_overlay
			#if material is ShaderMaterial:
				#material.set_shader_parameter("shader_time", value)
				#
			#material = node.material_override
			#print(material)
			#if material is ShaderMaterial:
				#
				#material.set_shader_parameter("shader_time", value)
				
				
