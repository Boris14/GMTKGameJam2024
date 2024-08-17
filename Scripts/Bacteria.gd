extends Node2D
class_name Bacteria

@export var backterium_scene : PackedScene
@export var spawn_check_increment := 20.0

var points_to_draw : Array

func _ready():
	global_position = Vector2.ZERO
	
func _physics_process(delta):
	$BacteriaCenter.position = get_bacteria_position()
	
func _input(event):
	if event.is_action_pressed("ui_accept"):
		spawn_bacterium()
		
func spawn_bacterium():
	var bacterium := backterium_scene.instantiate() as Bacterium
	add_child(bacterium)
	
	var spawn_points = generate_spiral_points(get_global_mouse_position(), 1000, spawn_check_increment)
	points_to_draw = spawn_points
	
	for point in spawn_points:
		if can_spawn(bacterium.collision, point):
			bacterium.global_position = point
			break

	
func get_bacteria_position() -> Vector2:
	print(get_child_count(true))
	if get_child_count(true) <= 0:
		return Vector2.ZERO
		
	var sum_positions := Vector2.ZERO
	
	for child in get_children(true):
		var bacterium = child as Node2D
		sum_positions += bacterium.global_position
	
	print(sum_positions / get_child_count(true))
	return sum_positions / get_child_count(true)
		
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
		
func random_point_on_circle(origin: Vector2, radius: float) -> Vector2:
	var angle = randf() * TAU 
	var x = cos(angle) * radius
	var y = sin(angle) * radius
	
	return Vector2(x, y)
