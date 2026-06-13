extends Node2D
@onready var area_2d: Area2D = $DNA/Area2D
@onready var collision_shape_2d: CollisionShape2D = $DNA/Area2D/CollisionShape2D
var current_hover
var shells = []
var detect_hover = false
var height
var spacing
var sub_spacing
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	height = collision_shape_2d.shape.size.y
	spacing = height / 8
	sub_spacing = spacing / 3
	print(shells)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if detect_hover:
		var local_y = get_global_mouse_position().y - area_2d.global_position.y
		local_y += height / 2.0
		var quadrant = int(local_y / spacing)
		quadrant = clamp(quadrant, 0, 7)
		var within_quadrant = fmod(local_y, spacing)
		var subquadrant_size = spacing / 3.0
		var subquadrant = int(within_quadrant / subquadrant_size)
		subquadrant = clamp(subquadrant, 0, 2)
		print("Quadrant:", quadrant, " Sub:", subquadrant)
		var current_shell = shells[quadrant]
		for i in shells:
			i.subquadrant_king = subquadrant
			if i == shells[quadrant]:
				continue 
			i.current_king = current_shell
			i.submit_to_the_king()
		current_shell.face_forward()
	#print(get_global_mouse_position() - area_2d.position)


func _on_button_pressed() -> void:
	pass # Replace with function body.
	$DNA/DNAStackedShell.start = true
	$DNA/DNAStackedShell2.start = true
	$DNA/DNAStackedShell3.start = true
	$DNA/DNAStackedShell4.start = true
	$DNA/DNAStackedShell5.start = true
	$DNA/DNAStackedShell6.start = true
	$DNA/DNAStackedShell7.start = true
	$DNA/DNAStackedShell8.start = true
	$DNA/DNAStackedShell.setter = true
	$DNA/DNAStackedShell2.setter = true
	$DNA/DNAStackedShell3.setter = true
	$DNA/DNAStackedShell4.setter = true
	$DNA/DNAStackedShell5.setter = true
	$DNA/DNAStackedShell6.setter = true
	$DNA/DNAStackedShell7.setter = true
	$DNA/DNAStackedShell8.setter = true
	$DNA2/DNAStackedShell.start = true
	$DNA2/DNAStackedShell2.start = true
	$DNA2/DNAStackedShell3.start = true
	$DNA2/DNAStackedShell4.start = true
	$DNA2/DNAStackedShell5.start = true
	$DNA2/DNAStackedShell6.start = true
	$DNA2/DNAStackedShell7.start = true
	$DNA2/DNAStackedShell8.start = true
	$DNA2/DNAStackedShell.setter = true
	$DNA2/DNAStackedShell2.setter = true
	$DNA2/DNAStackedShell3.setter = true
	$DNA2/DNAStackedShell4.setter = true
	$DNA2/DNAStackedShell5.setter = true
	$DNA2/DNAStackedShell6.setter = true
	$DNA2/DNAStackedShell7.setter = true
	$DNA2/DNAStackedShell8.setter = true


func _on_area_2d_mouse_entered() -> void:
	#print("hi")
	for i in shells:
		i.stop()
	detect_hover = true


func _on_area_2d_mouse_exited() -> void:
	#print("hi")
	for i in shells:
		i.play()
	detect_hover = false
