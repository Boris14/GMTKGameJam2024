extends Enemy
class_name ImmunityBoosterEnemy

func _ready():
	super._ready()
	var direction =  position.direction_to(get_closest_bacterium_position()).rotated(deg_to_rad(randf_range(-35,35)))
	velocity = direction * movement_speed

func step(delta):
	pass

func die():
	Globals.increase_immunity_response(20)
	super.die()
