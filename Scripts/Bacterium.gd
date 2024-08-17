extends CharacterBody2D
class_name Bacterium

@export var max_speed := 200.0

@export var detection_radius = 30.0
@export var separation_strength := 15.0

@onready var collision := $CollisionShape2D

func _ready():
	pass
	
func _physics_process(delta):
	var mouse_offset = get_global_mouse_position() - global_position
	var max_speed_distance = get_viewport_rect().size.length() / 4
	var speed = min(remap(mouse_offset.length(), 0, max_speed_distance, 0, max_speed), max_speed)
	
	# For Performance:
	#velocity = mouse_offset.normalized() * speed
	velocity = (mouse_offset.normalized() + get_separation_velocity() * separation_strength) * speed
		
	move_and_slide()

func get_separation_velocity() -> Vector2:
	var neighbours = get_neighbours()
	if neighbours.size() <= 0:
		return Vector2.ZERO
		
	var result := Vector2.ZERO
	for neighbour in neighbours:
		var offset = global_position - neighbour.global_position
		result += offset.normalized() / offset.length()

	return result

func get_neighbours() -> Array[Bacterium]:
	var params := PhysicsShapeQueryParameters2D.new()
	var circle_shape = CircleShape2D.new()
	circle_shape.radius = detection_radius
	params.shape = circle_shape
	params.transform = Transform2D(0, global_position)
	params.exclude = [self]
	var hits : Array = get_world_2d().direct_space_state.intersect_shape(params)
	var result : Array[Bacterium]
	for hit in hits:
		if hit.collider is Bacterium:
			result.append(hit.collider)
	return result
	
	
#func get_cohesion_velocity() -> Vector2:
#	var neighbours = get_neighbours()
#	if neighbours.size() <= 0:
#		return Vector2.ZERO
#		
#	var sum_positions := Vector2.ZERO
#	for neighbour in neighbours:
#		sum_positions += neighbour.global_position
#		
#	return sum_positions / neighbours.size() - global_position
