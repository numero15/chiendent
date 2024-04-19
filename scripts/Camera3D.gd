extends Camera3D
@export var position_node: Node

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# lerp position to smooth camera movement 
func _process(delta):
	if position_node!=null:
		global_transform = global_transform.interpolate_with(position_node.global_transform, .45)
		#global_transform = global_transform.interpolate_with(position_node.global_transform, .7)
		#global_transform = position_node.global_transform

