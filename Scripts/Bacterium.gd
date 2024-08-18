extends CharacterBody2D
class_name Bacterium

@export var max_speed := 300.0

@export var detection_radius = 30.0
@export var separation_strength := 15.0
@export var stick_death_delay := 0.5
@export var win_delay := 1

@onready var animation := $AnimationPlayer
@onready var collision := $CollisionShape2D

var win_method : Callable

signal died(bacterium : Bacterium, is_killed : bool)

var is_dead := false
var is_stuck := false
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
		var body = get_slide_collision(i).get_collider() as Node
		if body.is_in_group("sticky") and not is_stuck:
			var stick_action: Callable
			var action_delay := 0.0
			if body.is_in_group("lethal"):
				stick_action = func(): die(true)
				action_delay = stick_death_delay
			elif body.is_in_group("win") and win_method.is_valid():
				stick_action = func(): win_method.call()
				action_delay = win_delay
			stick(stick_action, action_delay)

func stick(action_after: Callable, action_delay: float):
	is_stuck = true
	curr_max_speed = 0
	animation.play("Stick")
	await get_tree().create_timer(action_delay).timeout 
	action_after.call()
	
func die(is_killed : bool):
	is_dead = true
	remove_from_group("bacterium")
	died.emit(self, is_killed)
	var death_duration := 0.
	if is_killed:
		death_duration = animation.get_animation("Death").length
		animation.play("Death")
	else:
		death_duration = animation.get_animation("Shrink").length
		animation.play("Shrink")
	
	var scene_tree = get_tree()
	if scene_tree:
		# Use a Timer node instead of create_timer
		var timer = Timer.new()
		add_child(timer)
		timer.set_one_shot(true)
		timer.set_wait_time(death_duration)
		timer.timeout.connect(func(): queue_free())
		timer.start()
	else:
		# If there's no scene tree, queue_free immediately
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
