extends Enemy
class_name FreezerEnemy

@export var speed_multiplier := 0.3

@onready var freeze_area := $FreezeArea
@onready var freeze_shape := $FreezeArea/CollisionShape2D

var aura_radius: float = 200.
var slowed_bacteria : Array[Bacterium]

func _ready():
	super._ready()
	freeze_area.body_entered.connect(on_body_entered)
	freeze_area.body_exited.connect(on_body_exited)
	aura_radius = (freeze_shape.shape as CircleShape2D).radius
	create_aura_visual()

func set_freeze_sound_playing(is_playing):
	if is_playing and spec_audio_player.playing or not is_playing and not spec_audio_player.playing:
		return
	if is_playing:
		spec_audio_player.stream = freezer_loop_sounds.pick_random()
		spec_audio_player.play()
	else:
		spec_audio_player.stop()

func on_body_entered(body: Node2D):
	if body in slowed_bacteria:
		return
	if body is Bacterium and body.is_in_group("bacterium"):
		body.curr_max_speed = body.max_speed * speed_multiplier
		slowed_bacteria.append(body)
	
func on_body_exited(body: Node2D):
	if body not in slowed_bacteria:
		return
	if body is Bacterium and body.is_in_group("bacterium"):
		body.curr_max_speed = body.max_speed
		slowed_bacteria.erase(body)

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
	set_freeze_sound_playing(not slowed_bacteria.is_empty())
	var target = get_closest_bacterium_position()
	if target != Vector2.ZERO:
		velocity = (target - global_position).normalized() * movement_speed
	else:
		velocity = Vector2.ZERO

			
func die():
	for b in slowed_bacteria:
		if is_instance_valid(b):
			b.curr_max_speed = b.max_speed
	super.die()
