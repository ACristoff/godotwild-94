@tool
extends Node2D
@onready var dna_allele_1: Sprite2D = $DnaAllele1
@onready var dna_allele_2: Sprite2D = $DnaAllele2
@onready var dna_shell_1: Sprite2D = $DnaShell1
@onready var dna_shell_2: Sprite2D = $DnaShell2
var current_frame = 0
var start = false
var setter = false

@export var anim_start_frame = 0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	dna_allele_1.frame = anim_start_frame
	dna_allele_2.frame = anim_start_frame
	dna_shell_1.frame = anim_start_frame
	dna_shell_2.frame = anim_start_frame


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if start:
		if setter:
			$Timer.start()
			setter = false
	else:
		dna_allele_1.frame = anim_start_frame
		dna_allele_2.frame = anim_start_frame
		dna_shell_1.frame = anim_start_frame
		dna_shell_2.frame = anim_start_frame
		current_frame = anim_start_frame
		if current_frame >= 24:
			dna_allele_2.z_index = 1
			dna_shell_2.z_index = 1
		else:
			dna_allele_2.z_index = -1
			dna_shell_2.z_index = -1
	


func _on_timer_timeout() -> void:
	dna_allele_1.frame += 1
	dna_allele_2.frame += 1
	dna_shell_1.frame += 1
	dna_shell_2.frame += 1
	current_frame += 1
	if current_frame >= 24:
		dna_allele_2.z_index = 1
		dna_shell_2.z_index = 1
	else:
		dna_allele_2.z_index = -1
		dna_shell_2.z_index = -1
	if current_frame == 47:
		dna_allele_1.frame = 0
		dna_allele_2.frame = 0
		dna_shell_1.frame = 0
		dna_shell_2.frame = 0
		current_frame = 0
