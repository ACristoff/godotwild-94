extends Node2D
@onready var dna_allele_1: Sprite2D = $DnaAllele1
@onready var dna_allele_2: Sprite2D = $DnaAllele2
@onready var dna_shell_1: Sprite2D = $DnaShell1
@onready var dna_shell_2: Sprite2D = $DnaShell2
var current_frame = 0
var start = false
var setter = false

var test_slot_type

@onready var color_rect: ColorRect = $ColorRect
@onready var slot_titles: Sprite2D = $SlotTitles

@export var title_offset = 0
@export var anim_start_frame = 0

var possible = ["atk", "hp", "trait", "def", "spec", "cd", "breed", "null"]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	color_rect.position.x += title_offset * 5
	slot_titles.position.x += title_offset * 5
	test_slot_type = possible.pick_random()
	set_slot(test_slot_type)
	await get_tree().process_frame
	get_parent().get_parent().shells.append(self)
	dna_allele_1.frame = anim_start_frame
	dna_allele_2.frame = anim_start_frame
	dna_shell_1.frame = anim_start_frame
	dna_shell_2.frame = anim_start_frame
	current_frame = anim_start_frame
	
func set_frame(frame:int):
	current_frame = frame

	dna_allele_1.frame = frame
	dna_allele_2.frame = frame
	dna_shell_1.frame = frame
	dna_shell_2.frame = frame

	update_depth()
	
func update_depth():
	if current_frame >= 29:
		dna_allele_2.z_index = 1
		dna_allele_1.z_index = -1
	else:
		dna_allele_2.z_index = -1
		dna_allele_1.z_index = 1

	if current_frame >= 23:
		dna_shell_1.z_index = -2
		dna_shell_2.z_index = 2
	else:
		dna_shell_1.z_index = 2
		dna_shell_2.z_index = -2

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	#print(current_frame)
	#if start:
		#$Timer.start()
		#start = false
		#setter = true
	#if !setter:
		#dna_allele_1.frame = anim_start_frame
		#dna_allele_2.frame = anim_start_frame
		#dna_shell_1.frame = anim_start_frame
		#dna_shell_2.frame = anim_start_frame
		#current_frame = anim_start_frame
		
func set_slot(type):
	match type:
		"atk":
			color_rect.modulate = Color.from_string("9e3434", Color.BLACK)
			slot_titles.frame = 0
			dna_shell_1.modulate = Color.from_string("9c2424", Color.BLACK)
			dna_shell_2.modulate = Color.from_string("9c2424", Color.BLACK)
		"hp":
			color_rect.modulate = Color.from_string("98a83b", Color.BLACK)
			slot_titles.frame = 1
			dna_shell_1.modulate = Color.from_string("779422", Color.BLACK)
			dna_shell_2.modulate = Color.from_string("779422", Color.BLACK)
		"trait":
			color_rect.modulate = Color.from_string("cf6142", Color.BLACK)
			slot_titles.frame = 2
			dna_shell_1.modulate = Color.from_string("d14830", Color.BLACK)
			dna_shell_2.modulate = Color.from_string("d14830", Color.BLACK)
		"def":
			color_rect.modulate = Color.from_string("5c7fe7", Color.BLACK)
			slot_titles.frame = 3
			dna_shell_1.modulate = Color.from_string("5f70e0", Color.BLACK)
			dna_shell_2.modulate = Color.from_string("5f70e0", Color.BLACK)
		"spec":
			color_rect.modulate = Color.from_string("eb6ec5", Color.BLACK)
			slot_titles.frame = 5
			dna_shell_1.modulate = Color.from_string("cc4bae", Color.BLACK)
			dna_shell_2.modulate = Color.from_string("cc4bae", Color.BLACK)
		"breed":
			color_rect.modulate = Color.from_string("7c40ff", Color.BLACK)
			slot_titles.frame = 6
			dna_shell_1.modulate = Color.from_string("784bcc", Color.BLACK)
			dna_shell_2.modulate = Color.from_string("784bcc", Color.BLACK)
		"cd":
			color_rect.modulate = Color.from_string("5dbcd4", Color.BLACK)
			slot_titles.frame = 4
			dna_shell_1.modulate = Color.from_string("56bccc", Color.BLACK)
			dna_shell_2.modulate = Color.from_string("56bccc", Color.BLACK)
		"null":
			color_rect.modulate = Color.from_string("828282", Color.BLACK)
			slot_titles.frame = 7
			dna_shell_1.modulate = Color.from_string("3d3d3d", Color.BLACK)
			dna_shell_2.modulate = Color.from_string("3d3d3d", Color.BLACK)

func tick_forward():
	current_frame += 1

	if current_frame >= 48:
		current_frame = 0

	dna_allele_1.frame = current_frame
	dna_allele_2.frame = current_frame
	dna_shell_1.frame = current_frame
	dna_shell_2.frame = current_frame

	update_depth()


func _on_button_mouse_entered() -> void:
	pass # Replace with function body.


func _on_button_mouse_exited() -> void:
	pass # Replace with function body.


func _on_area_2d_mouse_entered() -> void:
	pass # Replace with function body.


func _on_area_2d_mouse_exited() -> void:
	pass # Replace with function body.
