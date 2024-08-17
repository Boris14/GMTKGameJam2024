extends Marker2D
class_name CameraMarker

enum CameraDirection
{
	FORWARD,
	UP,
	DOWN,
}

@export var camera_direction : CameraDirection

func get_camera_direction() -> Vector2:
	var result := Vector2.ZERO
	
	match(camera_direction):
		CameraDirection.UP:
			result = Vector2.UP
		CameraDirection.DOWN:
			result = Vector2.DOWN
		CameraDirection.FORWARD:
			result = Vector2.RIGHT

	return result
