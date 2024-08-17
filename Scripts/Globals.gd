extends Node

var immunity_response: float = 0

func increase_immunity_response(amount: int = 1):
	immunity_response = max(0,min(immunity_response + amount, 100))
func _process(delta: float) -> void:
	#print(delta)
	immunity_response = max(0, immunity_response-delta*1)
	pass
