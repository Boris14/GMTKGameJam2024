extends Enemy
class_name SplitterEnemy

@export var base_max_splits: int = 2
@export var max_max_splits: int = 4

var max_splits := base_max_splits
var split_count: int = 0

func set_strength(strength):
	super.set_strength(strength)
	max_splits = int(lerp(float(base_max_splits), float(max_max_splits), strength))

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
		new_splitter.health = max(1, ceil(max_health / 1.5))
		new_splitter.max_health = new_splitter.health
		new_splitter.split_count = split_count + 1
		new_splitter.movement_speed *= 1.2
		get_parent().add_child(new_splitter)
	queue_free()
