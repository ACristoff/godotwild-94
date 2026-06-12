extends Camera2D

var actual_cam_pos : Vector2

func _process(delta):
	#move smoothly
	actual_cam_pos = actual_cam_pos.lerp($"../Player".global_position, delta * 4)
	
	var cam_subpixel_offset = actual_cam_pos.round() - actual_cam_pos
	
	GameManager.subviewport_shader.material.set_shader_parameter("cam_offset", cam_subpixel_offset)
	
	global_position = actual_cam_pos.round()
