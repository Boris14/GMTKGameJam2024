extends Enemy
class_name ShooterEnemy

enum State { MOVE, SHOOT }

var current_state = State.MOVE
var max_state_timer : float = 5.0
var state_timer: float = 0.0
var move_away_timer: float = 0.
var move_away_duration: float = 2.
var shots_fired: int = 0

var ShotEnemyScene = preload("res://Scenes/Enemy/ShotEnemy.tscn")

func step(delta):
	state_timer += delta
	var distance_to_closest_bacterium = position.distance_to(get_closest_bacterium_position())
	match current_state:
		State.MOVE:
			var direction_away = get_closest_bacterium_position().direction_to(position).normalized()
			if move_away_timer > 0:
				velocity = direction_away * movement_speed
			else:
				velocity = -direction_away * movement_speed
			
			if distance_to_closest_bacterium < 300:
				move_away_timer = move_away_duration
			else:
				move_away_timer -= delta
				
			#velocity = ((1 if distance_to_closest_bacterium < 200 else -1)*get_closest_bacterium_position().direction_to(position)).normalized().rotated((-1 if len(get_tree().get_nodes_in_group("bacterium")) % 5 == 0 else 1)*PI/3) * movement_speed
			if state_timer >= max_state_timer:
				current_state = State.SHOOT
				state_timer = 0.0
				velocity = Vector2.ZERO
				shots_fired = 0
		State.SHOOT:
			if state_timer >= max_state_timer:
				shoot()
				state_timer = 0.0
				shots_fired += 1
				if shots_fired >= 1:
					current_state = State.MOVE

func shoot():
	spec_audio_player.stream = shoot_sounds.pick_random()
	spec_audio_player.play()
	# Instance the scene
	var enemy_instance = ShotEnemyScene.instantiate()

	# Add the instance to the scene tree
	get_parent().add_child(enemy_instance)
	enemy_instance.position = position + position.direction_to(get_closest_bacterium_position()) * (radius + enemy_instance.radius) # Or wherever you want it
