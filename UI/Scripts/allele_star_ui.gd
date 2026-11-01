class_name AlllelePip extends TextureRect

var hovering = false
var current_strand: Strand
#var allele_data: Allele
#const ALELLE_UI = preload("uid://cckwntee1s0l4")
var spawn_pos
@onready var left_line := $"../../../Line2D"
@onready var right_line := $"../../../Line2D2"
@onready var allele_ui_visual := $"../.."

var skill : Sprite2D
var vanity : Sprite2D

signal strand_hovered

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	skill = find_child("SkillIn", true, false)
	vanity = find_child("VanityIn", true, false)


func _on_mouse_entered() -> void:
	allele_ui_visual._cooldown_show()
	left_line.set_point_position(0, skill.global_position)
	right_line.set_point_position(0, vanity.global_position)
	#TODO
	if current_strand == null:
		strand_hovered.emit(current_strand)
		return
	else:
		strand_hovered.emit(current_strand)


func _on_mouse_exited() -> void:
	allele_ui_visual._allele_show()


func set_strand(strand: Strand) -> void:
	current_strand = strand
