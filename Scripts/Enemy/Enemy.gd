extends CharacterBody2D
class_name Enemy

@export var max_health: int = 1
@export var movement_speed: float = 100.0

@export var hit_sounds : Array[AudioStream]
@export var death_sounds : Array[AudioStream]
@export var aoe_charge_sounds: Array[AudioStream]
@export var aoe_hit_sounds: Array[AudioStream]
@export var shoot_sounds : Array[AudioStream]
@export var freezer_loop_sounds : Array[AudioStream]

@onready var sprite := $Icon
@onready var general_audio_player := $GeneralAudioPlayer
@onready var spec_audio_player := $SpecializedAudioPlayer
@onready var radius := ($CollisionShape2D.shape as CircleShape2D).radius + 30

var health := 1
var is_dead := false

func _ready() -> void:
	health = max_health
	$AnimationPlayer.play("default")

func set_max_health(in_health):
	max_health = in_health
	health = in_health

func adjust_movement_dir():
	velocity = position.direction_to(get_closest_bacterium_position()) * movement_speed
	
func play_hit_animation():
	$AnimationPlayer.play("hit")
	await get_tree().create_timer(0.2).timeout
	if not is_dead:
		$AnimationPlayer.play("default")

func take_damage(amount: int = 1):
	play_hit_animation()
	play_hit_sound()
	health -= amount
	if health <= 0:
		die()

func die():
	if is_dead:
		return
	is_dead = true
	if not death_sounds.is_empty():
		general_audio_player.stream = death_sounds.pick_random()
		general_audio_player.play()
	$AnimationPlayer.play("die")
	await get_tree().create_timer($AnimationPlayer.current_animation_length).timeout
	queue_free()

func _physics_process(delta):
	if is_dead:
		return
		
	$Icon.scale.x = -abs($Icon.scale.x) if velocity.x >= 0 else abs($Icon.scale.x)
	
	step(delta)
	move_and_slide()
	
	for i in get_slide_collision_count():
		var body = get_slide_collision(i).get_collider() as Node
		if not body.is_in_group("bacterium"):
			velocity = get_slide_collision(i).get_normal().normalized() * movement_speed
	
	var tree = get_tree()
	if tree:
		for b in tree.get_nodes_in_group("bacterium"):
			if position.distance_to(b.position) < radius:
				take_damage()
				
				b.die(true)

func step(delta):
	adjust_movement_dir()

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
	if hit_sounds.is_empty() or general_audio_player.playing:
		return
	
	general_audio_player.stream = hit_sounds.pick_random()
	general_audio_player.play()


func _on_despawn_area_entered(area: Area2D) -> void:
	if area.is_in_group("despawner"):
		queue_free()
