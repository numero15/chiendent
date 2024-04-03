# Generic state machine. Initializes states and delegates engine callbacks
# (_physics_process, _unhandled_input) to the active state.
class_name StateMachine
extends Node

@export var state: StateFSM

func _ready():
	change_state(state)
	#
#func _physics_process(delta):
	#state.physics_update(delta)
	
func change_state(new_state : StateFSM,  msg: Dictionary = {}):
	if state is StateFSM:
		state.exit_state()
	new_state.enter_state(msg)
	state = new_state

