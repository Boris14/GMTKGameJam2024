extends Enemy
class_name SplitterEnemy

@export var max_splits: int = 2

var split_count: int = 0

func step(delta):
	var target = get_closest_bacterium_position()
	if target != Vector2.ZERO:
		velocity = (target - global_position).normalized() * movement_speed
	else:
		velocity = Vector2.ZERO

func die():
	if split_count >= max_splits:
		super.die()
		return
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
