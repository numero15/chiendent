extends Control

@export var player : Player
@export var boostGauge : TextureProgressBar

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _ready():
	player.boostChanged.connect(update)

func update():
	boostGauge.value = player.curBoost / player.maxBoost * boostGauge.max_value
