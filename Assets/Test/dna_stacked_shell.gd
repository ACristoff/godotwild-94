extends Node2D
@onready var dna_allele_1: Sprite2D = $DnaAllele1
@onready var dna_allele_2: Sprite2D = $DnaAllele2
@onready var dna_shell_1: Sprite2D = $DnaShell1
@onready var dna_shell_2: Sprite2D = $DnaShell2
var current_frame = 0
var start = false
var setter = false

var test_slot_type

signal allele_hovered(allele: Allele, side: String)
signal allele_unhovered

var left_allele: Allele = null
var right_allele: Allele = null

@onready var rect_handle: Node2D = $RectHandle
@onready var color_rect: ColorRect = $RectHandle/ColorRect
@onready var slot_titles: Sprite2D = $RectHandle/SlotTitles

@export var title_offset = 0
@export var anim_start_frame = 0

var slot_color: Color = Color.WHITE

var possible = ["atk", "hp", "trait", "def", "spec", "cd", "breed", "null"]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_parent().get_parent().shells.append(self)
	rect_handle.position.x += title_offset * 5
	rect_handle.position.x += title_offset * 5
	test_slot_type = possible.pick_random()
	set_slot(test_slot_type)
	await get_tree().process_frame
	#get_parent().get_parent().shells.append(self)
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
	
func play_anim():
	$AnimationPlayer.play("start")
	
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

func set_slot(type):
	match type:
		"ATTACK":
			color_rect.modulate = Color.from_string("9e3434", Color.BLACK)
			slot_titles.frame = 0
			dna_shell_1.modulate = Color.from_string("9c2424", Color.BLACK)
			dna_shell_2.modulate = Color.from_string("9c2424", Color.BLACK)
		"HEALTH":
			color_rect.modulate = Color.from_string("98a83b", Color.BLACK)
			slot_titles.frame = 1
			dna_shell_1.modulate = Color.from_string("779422", Color.BLACK)
			dna_shell_2.modulate = Color.from_string("779422", Color.BLACK)
		"ATTACK_AUGMENT":
			color_rect.modulate = Color.from_string("cf6142", Color.BLACK)
			slot_titles.frame = 2
			dna_shell_1.modulate = Color.from_string("d14830", Color.BLACK)
			dna_shell_2.modulate = Color.from_string("d14830", Color.BLACK)
		"HEALTH_AUGMENT":
			color_rect.modulate = Color.from_string("5c7fe7", Color.BLACK)
			slot_titles.frame = 3
			dna_shell_1.modulate = Color.from_string("5f70e0", Color.BLACK)
			dna_shell_2.modulate = Color.from_string("5f70e0", Color.BLACK)
		"SPECIALIZATION":
			color_rect.modulate = Color.from_string("eb6ec5", Color.BLACK)
			slot_titles.frame = 5
			dna_shell_1.modulate = Color.from_string("cc4bae", Color.BLACK)
			dna_shell_2.modulate = Color.from_string("cc4bae", Color.BLACK)
		"BREED_AUGMENT":
			color_rect.modulate = Color.from_string("7c40ff", Color.BLACK)
			slot_titles.frame = 6
			dna_shell_1.modulate = Color.from_string("784bcc", Color.BLACK)
			dna_shell_2.modulate = Color.from_string("784bcc", Color.BLACK)
		"COOLDOWN":
			color_rect.modulate = Color.from_string("5dbcd4", Color.BLACK)
			slot_titles.frame = 4
			dna_shell_1.modulate = Color.from_string("56bccc", Color.BLACK)
			dna_shell_2.modulate = Color.from_string("56bccc", Color.BLACK)
		"NONE":
			color_rect.modulate = Color.from_string("828282", Color.BLACK)
			slot_titles.frame = 7
			dna_shell_1.modulate = Color.from_string("3d3d3d", Color.BLACK)
			dna_shell_2.modulate = Color.from_string("3d3d3d", Color.BLACK)
	slot_color = dna_shell_1.modulate

func set_alleles(left: Allele, right: Allele) -> void:
	left_allele = left
	right_allele = right
	var empty := Color.from_string("3d3d3d", Color.BLACK)
	dna_allele_2.modulate = slot_color if left != null else empty
	dna_allele_1.modulate = slot_color if right != null else empty

func tick_forward():
	current_frame += 1
	
	if current_frame >= 48:
		current_frame = 0
	
	dna_allele_1.frame = current_frame
	dna_allele_2.frame = current_frame
	dna_shell_1.frame = current_frame
	dna_shell_2.frame = current_frame
	
	update_depth()

func _report_hover(side: String, entered: bool) -> void:
	var screen = get_parent().get_parent()
	var rung: int = screen.shells.find(self)
	if entered:
		screen.set_drop_target(rung, side)
	else:
		screen.clear_drop_target(rung, side)

func _on_area_2d_mouse_entered() -> void:
	$AnimationPlayer.play("appear")
	
	#$AnimationPlayer.play("RESET")
	$DnaShell1.self_modulate = Color(1.526, 1.526, 1.526, 1.0)
	$DnaShell2.self_modulate = Color(1.526, 1.526, 1.526, 1.0)

func _on_area_2d_mouse_exited() -> void:
	
	$AnimationPlayer.play("RESET")
	$DnaShell1.self_modulate = Color("ffffffff")
	$DnaShell2.self_modulate = Color("ffffffff")


func _on_right_allele_hover_mouse_entered() -> void:
	$AnimationPlayer.play("appear")
	$DnaAllele1.self_modulate = Color(1.526, 1.526, 1.526, 1.0)
	_report_hover("RIGHT", true)
	if right_allele != null:
		allele_hovered.emit(right_allele, "RIGHT")

func _on_right_allele_hover_mouse_exited() -> void:
	$AnimationPlayer.play("RESET")
	$DnaAllele1.self_modulate = Color("ffffffff")
	_report_hover("RIGHT", false)
	if right_allele != null:
		allele_unhovered.emit()

func _on_left_allele_mouse_entered() -> void:
	$AnimationPlayer.play("appear")
	$DnaAllele2.self_modulate = Color(1.526, 1.526, 1.526, 1.0)
	_report_hover("LEFT", true)
	if left_allele != null:
		allele_hovered.emit(left_allele, "LEFT")

func _on_left_allele_mouse_exited() -> void:
	$AnimationPlayer.play("RESET")
	$DnaAllele2.self_modulate = Color("ffffffff")
	_report_hover("LEFT", false)
	if left_allele != null:
		allele_unhovered.emit()
