extends Enemy
class_name ImmunityBoosterEnemy

func _ready():
	super._ready()
	sprite.texture = preload("res://Assets/Enemies/blood_cell.png")
	health = 1
	max_health = health
	movement_speed = randf_range(30,60)
	radius = 20.0
	var direction =  position.direction_to(get_closest_bacterium_position()).rotated(deg_to_rad(randf_range(-35,35)))
	velocity = direction * movement_speed

func step(delta):
	pass

func take_damage(amount: int = 1):
	health -= amount
	if health <= 0:
		Globals.increase_immunity_response(20)
		queue_free()
