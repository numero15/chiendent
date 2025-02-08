class_name StateFSM
extends Node

# Reference to the state machine, to call its `transition_to()` method directly.
# That's one unorthodox detail of our state implementation, as it adds a dependency between the
# state and the state machine objects, but we found it to be most efficient for our needs.
# The state machine node will set it.
var state_machine = null

signal change_state(new_state)


func _ready():
	set_physics_process(false)
	set_process_input(false)

# Virtual function. Called by the state machine upon changing the active state. The `msg` parameter
# is a dictionary with arbitrary data the state can use to initialize itself.
func enter_state(_msg := {}) -> void:
	set_physics_process(true)
	set_process_input(true)


# Virtual function. Called by the state machine before changing the active state. Use this function
# to clean up the state.
func exit_state() -> void:
	set_physics_process(false)
	set_process_input(false)
