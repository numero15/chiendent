extends Area3D
@onready var timer = get_node("Timer")


# Called when the node enters the scene tree for the first time.
func _ready():
	monitorable = false
	monitoring = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Input.is_action_just_pressed("ui_action") :
		monitorable = true
		monitoring = true
		timer.start()


func _on_timer_timeout():
	monitorable = false
	monitoring = false
