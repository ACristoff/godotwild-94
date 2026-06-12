extends CharacterBody2D


const SPEED = 100

func _physics_process(delta):
	velocity = Input.get_vector("a","d","w","s") * SPEED
	move_and_slide()
	position = position.round()
