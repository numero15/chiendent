extends Sprite3D

@onready var specialGauge : TextureProgressBar = $SubViewportSpecial/Control/ProgressBar
@onready var specialLabel : Label =$SubViewportSpecial/Control/Label
@onready var t : Timer = $Timer
@onready var subViewPort : SubViewport = $SubViewportSpecial

func _ready() -> void:
	#had to set the texture here, this does not work when setup without gdscript
	texture = subViewPort.get_texture()

func _on_player_boost_changed(value, max) -> void:
	visible = true
	specialGauge.value = value/ max * specialGauge.max_value
	specialLabel.text = " SPECIAL [" + String.num(value/ max * specialGauge.max_value,0)  + " %]"
	if value == max:
		t.start()


func _on_timer_timeout() -> void:
	visible = false
