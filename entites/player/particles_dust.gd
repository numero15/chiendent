extends GPUParticles3D

func _notification(what):
	match what:
		NOTIFICATION_PAUSED:
			interpolate = false
		NOTIFICATION_UNPAUSED:
			interpolate = true
