extends Enemy
class_name TankEnemy

var direction: Vector2

func _ready():
	super._ready()
	health = randi_range(10, 20)
	max_health = health
	movement_speed = 50.0
	radius = 20.0
	direction = (get_player_position() - global_position).normalized()

func step(delta):
	velocity = direction * movement_speed
