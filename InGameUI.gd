extends Control

@export var player : Player
@export var boostGauge : TextureProgressBar
@export var level : Node3D
@export var graphittiLabel : Label
var allGraphitti : int
var countGraphitti : int

func _ready():
	player.boostChanged.connect(update)
	allGraphitti = level.get_child(0).get_node("Billboards").get_child_count()
	for _billboard in level.get_child(0).get_node("Billboards").get_children():
		_billboard.billboardActivated.connect(upadteBillboardCount)
	countGraphitti = 0
	graphittiLabel.text = str(countGraphitti)+"/"+str(allGraphitti)

func update(value, max):
	boostGauge.value = value / max * boostGauge.max_value
	
func upadteBillboardCount():
	countGraphitti+=1
	graphittiLabel.text = str(countGraphitti)+"/"+str(allGraphitti)
