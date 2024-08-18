extends CharacterBody2D
class_name Enemy

@export var health: int = 1
@export var max_health: int = 1
@export var movement_speed: float = 100.0
@export var radius: float = 70.0
@export var hit_sounds : Array[AudioStream]

@onready var audio_player := $AudioStreamPlayer

func _ready() -> void:
	pass
func take_damage(amount: int = 1):
	health -= amount
	if health <= 0:
		queue_free()

func _physics_process(delta):
	step(delta)
	$Icon.scale = Vector2.ONE * radius/66
	move_and_slide()
	for b in get_tree().get_nodes_in_group("bacterium"):
		if position.distance_to(b.position) < radius:
			play_hit_sound()
			take_damage()
			b.die(true)

func step(delta):
	# This function is intended to be overwritten by child classes
	pass


func get_closest_bacterium_position() -> Vector2:
	var bacteria = get_tree().get_nodes_in_group("bacterium")
	if bacteria.is_empty():
		return Vector2.ZERO
	
	var closest_bacterium = bacteria[0]
	var closest_distance = position.distance_squared_to(closest_bacterium.position)
	
	for bacterium in bacteria:
		var distance = position.distance_squared_to(bacterium.position)
		if distance < closest_distance:
			closest_distance = distance
			closest_bacterium = bacterium
	
	return closest_bacterium.position
	
func play_hit_sound():
	if hit_sounds.is_empty() or audio_player.playing:
		return
	
	audio_player.stream = hit_sounds.pick_random()
	audio_player.play()
