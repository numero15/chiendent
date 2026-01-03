extends Area3D
@onready var timer = get_node("Timer")
@onready var AudioFXSpray = get_node("../AudioFXSpray")
@onready var particlesSpray : GPUParticles3D = get_node("../ParticlesSpray")


func _ready():
	monitorable = false
	monitoring = false
	timer.stop()

func _process(_delta):
	if Input.is_action_just_pressed("ui_action") and timer.is_stopped() :
		AudioFXSpray.play()
		particlesSpray.emitting = true
		monitorable = true
		monitoring = true
		timer.start()


func _on_timer_timeout():
	monitorable = false
	monitoring = false
