extends Enemy
class_name SplitterEnemy

var split_count: int = 0
var max_splits: int = 2

func _ready():
	super._ready()
	health = 4
	max_health = health
	movement_speed = 80.0
	radius = 40.0
	$Icon.modulate = Color.ORANGE

func step(delta):
	var target = get_closest_bacterium_position()
	if target != Vector2.ZERO:
		velocity = (target - global_position).normalized() * movement_speed
	else:
		velocity = Vector2.ZERO

func take_damage(amount: int = 1):
	health -= amount
	if health <= 0:
		split()

func split():
	if split_count < max_splits:
		for i in range(2):
			var new_splitter = duplicate()
			new_splitter.position = position + Vector2(randf_range(-20, 20), randf_range(-20, 20))
			new_splitter.scale *= 0.7
			new_splitter.health = max(1, health)
			new_splitter.max_health = new_splitter.health
			new_splitter.split_count = split_count + 1
			new_splitter.movement_speed *= 1.2
			get_parent().add_child(new_splitter)
	queue_free()
