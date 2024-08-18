extends Enemy
class_name FreezerEnemy

var aura_radius: float
var slowed_bacteria : Array[Bacterium]

func _ready():
	super._ready()
	health = 3
	max_health = health
	movement_speed = 20.0
	radius = 30.0
	aura_radius = radius * 8
	$Icon.modulate = Color.LIGHT_BLUE
	create_aura_visual()

func create_aura_visual():
	var aura = ColorRect.new()
	aura.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	
	var shader = Shader.new()
	shader.code = """
	shader_type canvas_item;
	uniform vec4 aura_color : source_color = vec4(0.5, 0.5, 1.0, 0.2);
	uniform float aura_radius : hint_range(0.0, 1.0) = 0.5;
	void fragment() {
		float dist = distance(UV, vec2(0.5));
		COLOR = aura_color;
		COLOR.a *= smoothstep(aura_radius, aura_radius - 0.1, dist);
	}
	"""
	
	var material = ShaderMaterial.new()
	material.shader = shader
	material.set_shader_parameter("aura_color", Color(0.5, 0.5, 1.0, 0.2))
	material.set_shader_parameter("aura_radius", 0.5)
	
	aura.material = material
	aura.size = Vector2.ONE * aura_radius * 2
	aura.position = -aura.size / 2
	add_child(aura)

func step(delta):
	var target = get_closest_bacterium_position()
	if target != Vector2.ZERO:
		velocity = (target - global_position).normalized() * movement_speed
	else:
		velocity = Vector2.ZERO

	for b in get_tree().get_nodes_in_group("bacterium"):
		if position.distance_to(b.position) < aura_radius:
			slow_bacterium(b, delta)
		elif b in slowed_bacteria:
			b.curr_max_speed = b.max_speed
			slowed_bacteria.erase(b)

func slow_bacterium(bacterium : Bacterium, delta : float):
	if not bacterium in slowed_bacteria:
		slowed_bacteria.append(bacterium)
	bacterium.curr_max_speed = max(20, bacterium.max_speed * 0.9 *delta)
