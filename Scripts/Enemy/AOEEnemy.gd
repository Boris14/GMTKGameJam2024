extends Enemy
class_name AOEEnemy

enum State { MOVE, PREPARE_ATTACK, ATTACK }

var current_state = State.MOVE
var attack_timer: float = 0.0
var attack_timer_max: float = 2.0
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
	color.a=0.1
	# Set initial shader parameters
	material.set_shader_parameter("circle_color", color)
	material.set_shader_parameter("radius", 0.4)
	material.set_shader_parameter("border_width", 0.05)
	
	# Apply the material to the ColorRect
	rect.material = material
	add_child(rect)

	return rect
).call()


	
func _ready():
	super._ready()
	radius=randf_range(50, 100)
	health = 35
	max_health = 35
	$Icon.modulate=Color.YELLOW

	#$CollisionShape2D.shape.radius = radius
func aoe_radius():
	return radius*1.2+radius*2*attack_timer/attack_timer_max if current_state == State.PREPARE_ATTACK else radius*2*2 if current_state==State.ATTACK else 0
func step(delta):
	aoe_visual.size = Vector2.ONE * aoe_radius()*2
	aoe_visual.position = -aoe_visual.size/2
	match current_state:
		State.MOVE:
			var player_pos = get_closest_bacterium_position()
			velocity = (player_pos - global_position).normalized() * movement_speed
			if global_position.distance_to(player_pos) < radius*2:  # Adjust this value as needed
				current_state = State.PREPARE_ATTACK
				velocity = Vector2.ZERO
		State.PREPARE_ATTACK:
			attack_timer += delta
			
			if attack_timer >= attack_timer_max:
				current_state = State.ATTACK
				attack_timer = 0.0
		State.ATTACK:
			for b in get_tree().get_nodes_in_group("bacterium"):
				if position.distance_to(b.position) < aoe_radius():
					b.die(true)
					
			current_state = State.MOVE
