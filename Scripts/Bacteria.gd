extends Node2D
class_name Bacteria

@export var bacterium_scene : PackedScene
@export var spawn_check_increment := 20.0
@export var min_bacteria_count := 3
@export var max_bacteria_count := 200
@export var start_bacteria_count := 10
@export var scroll_spawn_count := 2

@export var spawn_sounds : Array[AudioStream]
@export var remove_sounds : Array[AudioStream]
@export var death_sounds : Array[AudioStream]

@onready var audio_player := $AudioStreamPlayer

var initial_bacteria_position : Vector2
var win_method: Callable

signal died

func _ready():
	global_position = Vector2.ZERO
	
func start_bacteria(start_position):
	initial_bacteria_position = start_position
	for b in get_bacteria():
		b.queue_free()
		remove_child(b)
	for i in range(start_bacteria_count):
		spawn_bacterium()
	
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
		play_remove_sound()
		farthest_bacterium.die(false)
	
		
func spawn_bacterium():
	if get_bacteria_count() >= max_bacteria_count:
		return
		
	var bacterium := bacterium_scene.instantiate() as Bacterium
	
	var spawn_points = generate_spiral_points(get_bacteria_position(), 1000, spawn_check_increment)
	var is_spawned = false
	
	for point in spawn_points:
		if can_spawn(15, point):
			bacterium.global_position = point
			bacterium.died.connect(_on_bacterium_died)
			bacterium.win_method = win_method
			add_child(bacterium)
			is_spawned = true
			play_spawn_sound()
			break
			
	if not is_spawned:
		bacterium.queue_free()


func _on_bacterium_died(bacterium: Bacterium, is_killed: bool):
	play_death_sound()
	if get_bacteria_count() <= 0:
		died.emit()

func get_bacteria() -> Array[Bacterium]:
	var result : Array[Bacterium] = []
	
	for child in get_children(true):
		if child is Bacterium \
		and child.is_in_group("bacterium") \
		and not child.is_dead:
			result.append(child)
	
	return result

func get_bacteria_count() -> int:
	return get_bacteria().size()
	
func get_bacteria_position() -> Vector2:
	var bacteria_count = get_bacteria_count()
	
	if bacteria_count <= 0:
		return initial_bacteria_position
	
	var sum_positions := Vector2.ZERO
	
	for bacterium in get_bacteria():
		if not is_instance_valid(bacterium):
			remove_child(bacterium)
		sum_positions += bacterium.global_position
	
	return sum_positions / bacteria_count
		
func can_spawn(body_radius : float, position : Vector2) -> bool:
	var params := PhysicsShapeQueryParameters2D.new()
	var circle_shape := CircleShape2D.new()
	circle_shape.radius = body_radius
	params.shape = circle_shape
	params.transform = Transform2D(0, position)
	var hits : Array = get_world_2d().direct_space_state.intersect_shape(params)
	
	return hits.size() == 0
	
func play_spawn_sound():
	if spawn_sounds.is_empty() or audio_player.playing:
		return
		
	audio_player.stream = spawn_sounds.pick_random()
	audio_player.play()
	
func play_remove_sound():
	if remove_sounds.is_empty() or audio_player.playing:
		return
		
	audio_player.stream = remove_sounds.pick_random()
	audio_player.play()
	
func play_death_sound():
	if death_sounds.is_empty() or audio_player.playing:
		return
		
	audio_player.stream = death_sounds.pick_random()
	audio_player.play()
	
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
