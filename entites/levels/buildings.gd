@tool
extends Node3D

@export var bakeCollisions: bool:
	set = _on_bakeCollisions
	
@export var removeCollisions: bool:
	set = _on_removeCollisions

func _on_bakeCollisions(_new_value : bool) -> void:
	bakeCollisions = true;
	for _mesh in get_children():
		if _mesh is MeshInstance3D :
			for n in _mesh.get_children():
				_mesh.remove_child(n)
				n.queue_free() 
			_mesh.create_convex_collision()
	bakeCollisions = false;
	
func _on_removeCollisions(_new_value : bool) -> void:
	removeCollisions = true;
	for _mesh in get_children():
		if _mesh is MeshInstance3D :
			for n in _mesh.get_children():
				_mesh.remove_child(n)
				n.queue_free() 
	removeCollisions = false;
