extends Node2D
@onready var area_2d: Area2D = $DNA/Area2D
@onready var collision_shape_2d: CollisionShape2D = $DNA/Area2D/CollisionShape2D
var current_hover
var shells = []
var detect_hover = false
var height
var spacing
var sub_spacing

var current_slot = 0

var king_index : int
var king_offset : int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	height = collision_shape_2d.shape.size.y
	height *= scale.y
	spacing = height / 8
	sub_spacing = spacing / 3
	#print(shells)
	update_visuals()

func update_visuals():
	current_slot = 0
	for i in shells:
		#print("play")
		i.play_anim()
		await get_tree().create_timer(0.15).timeout
		
		
enum Slot {
	HEALTH,
	HEALTH_AUGMENT,
	ATTACK,
	ATTACK_AUGMENT,
	COOLDOWN,
	SPECIALIZATION,
	BREED_AUGMENT,
	NONE
}


func set_slot(slot: BodyMap.Slot):
	#set the color of the strand to the type
	var node = get_node("DNA/DNAStackedShell" + str(current_slot))
	node.set_slot(slot)
	current_slot += 1
	

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
		#print("Quadrant:", quadrant, " Sub:", subquadrant)
		king_index = quadrant
		#for i in shells:
			#i.subquadrant_king = subquadrant
			#if i == shells[quadrant]:
				#continue 
			#i.current_king = current_shell
			#i.submit_to_the_king()
		#current_shell.face_forward()
	
		match subquadrant:
			0:
				king_offset = -1
			1:
				king_offset = 0
			2:
				king_offset = 1
				
		var center_frame = 29 + king_offset
		for i in range(shells.size()):
			var distance = i - king_index
			var frame = center_frame - distance * 3
			frame = wrapi(frame, 0, 48)
			shells[i].set_frame(frame)


func _on_area_2d_mouse_entered() -> void:
	#print("hi")
	$Timer.stop()
	detect_hover = true


func _on_area_2d_mouse_exited() -> void:
	$Timer.start()
	detect_hover = false


func _on_timer_timeout() -> void:
	for i in shells:
		i.tick_forward()


func _on_start_button_pressed() -> void:
	$Timer.start()
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
