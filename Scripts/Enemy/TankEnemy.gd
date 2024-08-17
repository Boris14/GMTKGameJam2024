extends Enemy
class_name TankEnemy

var direction: Vector2

func _ready():
	super._ready()
	health = randi_range(10, 20)
	max_health = health
	movement_speed = 50.0
	direction = (position.direction_to(get_closest_bacterium_position())).normalized()
	$Icon.modulate = Color.DIM_GRAY
func step(delta):
	velocity = direction * movement_speed
