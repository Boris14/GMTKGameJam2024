extends Enemy
class_name ImmunityBoosterEnemy

@export var immnity_response_increase := 8.

var move_dir : Vector2

func _ready():
	super._ready()
	move_dir = -position.direction_to(get_closest_bacterium_position()).rotated(deg_to_rad(randf_range(-35,35)))
	velocity = move_dir * movement_speed

func step(delta):
	rotation

func die():
	Globals.increase_immunity_response(immnity_response_increase)
	super.die()
