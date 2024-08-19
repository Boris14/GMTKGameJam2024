extends Enemy
class_name AOEEnemy

enum State { MOVE, PREPARE_ATTACK, ATTACK }

var current_state = State.MOVE
var attack_timer: float = 0.0
var attack_timer_max: float = 3.0

@onready var aoe_visual = (func():
	# Create the ColorRect
	var rect = ColorRect.new()
	rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	# Create the shader
	var shader = Shader.new()
	shader.code = """
	shader_type canvas_item;

	uniform vec4 circle_color : source_color = vec4(1.0, 0.0, 0.0, 1.0);
	uniform float radius : hint_range(0.0, 1.0) = 0.5;
	uniform float border_width : hint_range(0.0, 1.0) = 0.0;

	void fragment() {
		vec2 center = vec2(0.5, 0.5);
		float dist = distance(UV, center);
		
		if (dist <= radius - border_width) {
			COLOR = circle_color;
		} else if (dist <= radius) {
			COLOR = mix(circle_color, vec4(0.0), (dist - (radius - border_width)) / border_width);
		} else {
			COLOR = vec4(0.0);
		}
	}
	"""
	
	# Create and setup the ShaderMaterial
	var material = ShaderMaterial.new()
	material.shader = shader
	var color = Color.YELLOW
	color.a=0.5
	# Set initial shader parameters
	material.set_shader_parameter("circle_color", color)
	material.set_shader_parameter("radius", 0.5)
	material.set_shader_parameter("border_width", 0.05)
	
	# Apply the material to the ColorRect
	rect.material = material
	add_child(rect)

	return rect
).call()

#$CollisionShape2D.shape.radius = radius
func aoe_radius():
	return radius*1.2+radius*2*attack_timer/attack_timer_max if current_state == State.PREPARE_ATTACK else radius*1.2+radius*2 if current_state==State.ATTACK else 0

func step(delta):
	aoe_visual.size = Vector2.ONE * aoe_radius()*2.0
	aoe_visual.position = -aoe_visual.size/2
	var color_progress = 0.0
	if current_state == State.PREPARE_ATTACK:
		color_progress = attack_timer / attack_timer_max
	elif current_state == State.ATTACK:
		color_progress = 1.0

	var lerped_color = Color.YELLOW.lerp(Color.RED, color_progress)
	lerped_color.a = 0.5  # Set alpha to 0.5 for semi-transparency

	aoe_visual.material.set_shader_parameter("circle_color", lerped_color)

	match current_state:
		State.MOVE:
			var player_pos = get_closest_bacterium_position()
			velocity = (player_pos - global_position).normalized() * movement_speed
			if global_position.distance_to(player_pos) < radius*2:  # Adjust this value as needed
				current_state = State.PREPARE_ATTACK
				attack_timer_max = play_aoe_charge_audio()
				velocity = Vector2.ZERO
		State.PREPARE_ATTACK:
			attack_timer += delta
			if attack_timer >= attack_timer_max:
				current_state = State.ATTACK
				attack_timer = 0.0
		State.ATTACK:
			play_aoe_hit_audio()
			for b in get_tree().get_nodes_in_group("bacterium"):
				if position.distance_to(b.position) < aoe_radius():
					b.die(true)
					
			current_state = State.MOVE

func play_aoe_charge_audio():
	spec_audio_player.stream = aoe_charge_sounds.pick_random()
	spec_audio_player.play()
	return spec_audio_player.stream.get_length()

func play_aoe_hit_audio():
	spec_audio_player.stream = aoe_hit_sounds.pick_random()
	spec_audio_player.play()
