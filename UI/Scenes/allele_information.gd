extends NinePatchRect

var current_strand : Strand = null

@onready var left_allele_name: Label = $MarginContainer/HBoxContainer/LeftAlelle/MarginContainer2/Name/MarginContainer/HBoxContainer/LA_NameText
@onready var left_allele_description: RichTextLabel = $MarginContainer/HBoxContainer/LeftAlelle/MarginContainer/LA_DescriptionText
@onready var left_allele_level: Label = $MarginContainer/HBoxContainer/LeftAlelle/MarginContainer2/Name/MarginContainer/HBoxContainer/MarginContainer/LA_LevelText

@onready var right_allele_name: Label = $MarginContainer/HBoxContainer/RightAlelle/MarginContainer2/NameText/MarginContainer/HBoxContainer/RA_NameText
@onready var right_allele_description: RichTextLabel = $MarginContainer/HBoxContainer/RightAlelle/MarginContainer/RA_DescriptionText
@onready var right_allele_level: Label = $MarginContainer/HBoxContainer/RightAlelle/MarginContainer2/NameText/MarginContainer/HBoxContainer/MarginContainer/RA_LevelText


func _ready():
	pass

func update_labels() -> void:
	left_allele_name.text = "Empty"
	left_allele_description.text = ""
	left_allele_level.text = ""
	right_allele_name.text = "Empty"
	right_allele_description.text = ""
	right_allele_level.text = ""
	


func set_strand(new_strand: Strand):
	current_strand = new_strand
	update_labels()
