extends CharacterBody2D
class_name Enemy

@export var health: int = 1
@export var max_health: int = 1
@export var size: float = 1.0
@export var movement_speed: float = 100.0
@export var radius: float = 10.0

func _ready():
	scale = Vector2(size, size)

func take_damage(amount: int = 1):
	health -= amount
	if health <= 0:
		queue_free()

func _physics_process(delta):
	step(delta)
	move_and_slide()

func step(delta):
	# This function is intended to be overwritten by child classes
	pass

func get_player_position() -> Vector2:
	return get_parent().get_parent().get_node("Bacterium").position
	# Assume this function exists and returns the player's position
	#return Vector2.ZERO
