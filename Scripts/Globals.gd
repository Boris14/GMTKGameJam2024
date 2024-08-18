extends Node

var immunity_decrease_per_sec := 5
var immunity_decrease_delay := 1.5
var immunity_response := 0.0

var curr_delay := 0.0

# How far through the Level is the Player
var progress := 0.

func increase_immunity_response(amount: float):
	if amount <= 0:
		return
	immunity_response = max(0, min(immunity_response + amount, 100))
	curr_delay = immunity_decrease_delay
	
func _process(delta: float) -> void:
	if curr_delay > 0:
		curr_delay -= delta
	elif immunity_response > 0:
		immunity_response = max(0, immunity_response - immunity_decrease_per_sec * delta)
