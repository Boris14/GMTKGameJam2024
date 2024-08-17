extends Node2D
class_name Bacteria

@export var backterium_scene : PackedScene

func _ready():
	pass
	
func _physics_process(delta):
	pass
	
func _input(event):
	if event.is_action_pressed("ui_accept"):
		spawn_bacterium()
		
func spawn_bacterium():
	var params : PhysicsShapeQueryParameters2D
	params.shape = CircleShape2D.new()
	params.transform = Transform2D(global_transform)
	var hits : Array = get_world_2d().direct_space_state.intersect_shape(params)
	if hits.size() > 0:
		return
		
func random_point_on_circle(origin: Vector2, radius: float) -> Vector2:
	var angle = randf() * TAU 
	var x = cos(angle) * radius
	var y = sin(angle) * radius
	
	return Vector2(x, y)
