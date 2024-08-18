extends Enemy
class_name AbsorberEnemy

var max_radius: float = 1000.0

func _ready():
	super._ready()
	sprite.texture = preload("res://Assets/Enemies/enemy_absorber.png")
	health = 25
	max_health = health
	movement_speed = 40.0
	radius = 20.0
	#$Icon.scale = Vector2.ONE * radius/66 * 0.3

func step(delta):
	var target = get_closest_bacterium_position()
	if target != Vector2.ZERO:
		velocity = (target - global_position).normalized() * movement_speed
	else:
		velocity = Vector2.ZERO





func take_damage(amount: int = 1):
	radius = min(radius + 2, max_radius)
	#$Icon.scale = Vector2.ONE * radius / 66
	movement_speed = max(10, movement_speed - 2)
	super.take_damage(amount)
