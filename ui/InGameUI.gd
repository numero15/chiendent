extends Control

@export var player : Player
@export var level : Node3D
@export var graphittiLabel : Label
var allGraphitti : int
var countGraphitti : int

func _ready():
	allGraphitti = level.get_child(0).get_node("Billboards").get_child_count()
	for _billboard in level.get_child(0).get_node("Billboards").get_children():
		_billboard.billboardActivated.connect(upadteBillboardCount)
	countGraphitti = 0
	graphittiLabel.text = str(countGraphitti)+"/"+str(allGraphitti)


	
func upadteBillboardCount():
	countGraphitti+=1
	graphittiLabel.text = str(countGraphitti)+"/"+str(allGraphitti)
