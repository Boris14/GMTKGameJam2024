extends CharacterBody2D
class_name Bacterium

@export var max_speed := 300.0

@export var detection_radius = 30.0
@export var separation_strength := 15.0
@export var stick_color : Color = Color.YELLOW
@export var stick_death_delay := 0.5

@onready var animation := $AnimationPlayer
@onready var collision := $CollisionShape2D

signal died(bacterium : Bacterium)

var is_dead := false
var curr_max_speed := max_speed

func _ready():
	pass
	
func _physics_process(delta):
	var mouse_offset = get_global_mouse_position() - global_position
	var max_speed_distance = get_viewport_rect().size.length() / 6
	var speed = min(remap(mouse_offset.length(), 0, max_speed_distance, 0, curr_max_speed), curr_max_speed)
	
	# For Performance:
	#velocity = mouse_offset.normalized() * speed
	velocity = (mouse_offset.normalized() + get_separation_velocity() * separation_strength) * speed
		
	move_and_slide()
	
	for i in get_slide_collision_count():
		var collider = get_slide_collision(i).get_collider()
		if collider is Node and collider.is_in_group("sticky"):
			stick_and_die()

func stick_and_die():
	curr_max_speed = 0
	modulate = stick_color
	await get_tree().create_timer(stick_death_delay).timeout 
	die(true)
	
func die(is_killed : bool):
	is_dead = true
	died.emit(self)
	animation.play("Shrink")
	var death_duration = animation.get_animation("Shrink").length
	await get_tree().create_timer(death_duration).timeout
	queue_free()

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
