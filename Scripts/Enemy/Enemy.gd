extends CharacterBody2D
class_name Enemy

@export var health: int = 1
@export var max_health: int = 1
@export var movement_speed: float = 100.0
@export var radius: float = 30.0
@export var hit_sounds : Array[AudioStream]


@onready var sprite := $Icon
@onready var audio_player := $AudioStreamPlayer

func _ready() -> void:
	sprite.texture = preload("res://Assets/Enemies/enemy_basic.png")
	$Icon.scale = Vector2.ONE * radius/66 * 0.3

func take_damage(amount: int = 1):
	health -= amount
	if health <= 0:
		$AnimationPlayer.play("die")

func die():
	queue_free()
func _physics_process(delta):
	step(delta)
	#$Icon.scale = Vector2.ONE * radius/66 * 0.3
	move_and_slide()
	var tree = get_tree()
	if tree:
		for b in get_tree().get_nodes_in_group("bacterium"):
			if position.distance_to(b.position) < radius:
				$AnimationPlayer.play("hit")
				play_hit_sound()
				take_damage()
				
				b.die(true)

func step(delta):
	velocity = position.direction_to(get_closest_bacterium_position())
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


func _on_despawn_area_entered(area: Area2D) -> void:
	if area.is_in_group("despawner"):
		die()
