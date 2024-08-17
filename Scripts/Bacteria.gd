extends Node2D
class_name Bacteria

@export var backterium_scene : PackedScene
@export var spawn_check_increment := 20.0
@export var min_bacteria_count := 3
@export var max_bacteria_count := 200
@export var scroll_spawn_count := 1

func _ready():
	global_position = Vector2.ZERO
	
func _physics_process(delta):
	$BacteriaCenter.position = get_bacteria_position()
	
func _input(event):
	if event is InputEventMouseButton:
		if event.is_pressed():
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				for i in range(scroll_spawn_count): 
					spawn_bacterium()
			elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				for i in range(scroll_spawn_count): 
					remove_bacterium()
		
func remove_bacterium():
	if get_bacteria_count() <= min_bacteria_count:
		return
	
	var farthest_bacterium : Bacterium
	var farthest_dist := 0.0
	for bacterium in get_bacteria():
		var distance = (get_bacteria_position() - bacterium.position).length()
		if distance > farthest_dist:
			farthest_bacterium = bacterium
			farthest_dist = distance
	
	if is_instance_valid(farthest_bacterium):
		farthest_bacterium.queue_free()
	
		
func spawn_bacterium():
	if get_bacteria_count() >= max_bacteria_count:
		return
		
	var bacterium := backterium_scene.instantiate() as Bacterium
	add_child(bacterium)
	
	var spawn_points = generate_spiral_points(get_bacteria_position(), 1000, spawn_check_increment)
	
	var can_spawn = false
	
	for point in spawn_points:
		if can_spawn(bacterium.collision, point):
			bacterium.global_position = point
			can_spawn = true
			break

	if not can_spawn:
		bacterium.queue_free()

func get_bacteria() -> Array[Bacterium]:
	var result : Array[Bacterium]
	
	for child in get_children(true):
		if child is Bacterium:
			result.append(child)
			
	return result

func get_bacteria_count() -> int:
	return get_bacteria().size()
	
func get_bacteria_position() -> Vector2:
	var bacteria_count := get_bacteria_count()
	
	if bacteria_count <= 0:
		return Vector2.ZERO
	
	var sum_positions := Vector2.ZERO
	
	for bacterium in get_bacteria():
		sum_positions += bacterium.global_position
	
	return sum_positions / bacteria_count
		
func can_spawn(collision : CollisionShape2D, position : Vector2) -> bool:
	var params := PhysicsShapeQueryParameters2D.new()
	params.shape = collision.shape
	params.transform = Transform2D(0, position)
	var hits : Array = get_world_2d().direct_space_state.intersect_shape(params)
	
	return hits.size() == 0
	
func generate_spiral_points(origin: Vector2, points_count: int, increment: int) -> Array:
	var result = []
	var x := origin.x
	var y := origin.y
	var dx := 0
	var dy := -1
	
	var step_count = 0
	var turn_count = 0
	
	for i in range(points_count):
		result.append(Vector2(x, y))
		
		if step_count == turn_count / 2 + 1:
			step_count = 0
			turn_count += 1
			
			var temp = dx
			dx = -dy
			dy = temp
		
		x += dx * increment
		y += dy * increment
		step_count += 1
		
	return result
