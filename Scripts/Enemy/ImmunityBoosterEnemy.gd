extends Enemy
class_name ImmunityBoosterEnemy

func _ready():
	super._ready()
	health = 1
	max_health = health
	movement_speed = randf_range(30,60)
	radius = 20.0
	$Icon.modulate = Color.RED
	$Icon.scale = Vector2.ONE * radius/66
	velocity = Vector2(randf_range(-1,1),randf_range(-1,1)).normalized() * movement_speed


func take_damage(amount: int = 1):
	health -= amount
	if health <= 0:
		Globals.increase_immunity_response(10)
		queue_free()
