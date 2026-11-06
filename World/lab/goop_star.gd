extends CharacterBody2D

@export var speed: float = 300.0
var angles = [0.0, 90.0, -180, -90]
var color : Color = Color()
func _ready() -> void:
	$GoopStar.rotation_degrees = angles.pick_random()
	var angle_deg := randf_range(0.0, 360.0)
	velocity = Vector2.RIGHT.rotated(deg_to_rad(angle_deg)) * speed
	$AnimationPlayer.advance(randf_range(0.0, 1.5))

func _physics_process(delta: float) -> void:
	$Sprite2D.modulate = color
	var collision := move_and_collide(velocity * delta)
	if collision:
		velocity = velocity.bounce(collision.get_normal())
