class_name AlleleInformation extends NinePatchRect

var current_strand : Strand = null

@onready var left_allele_name: Label = $MarginContainer/HBoxContainer/LeftAlelle/MarginContainer2/Name/MarginContainer/HBoxContainer/LA_NameText
@onready var left_allele_description: RichTextLabel = $MarginContainer/HBoxContainer/LeftAlelle/MarginContainer/LA_DescriptionText
@onready var left_allele_level: Label = $MarginContainer/HBoxContainer/LeftAlelle/MarginContainer2/Name/MarginContainer/HBoxContainer/MarginContainer/LA_LevelText

@onready var right_allele_name: Label = $MarginContainer/HBoxContainer/RightAlelle/MarginContainer2/NameText/MarginContainer/HBoxContainer/RA_NameText
@onready var right_allele_description: RichTextLabel = $MarginContainer/HBoxContainer/RightAlelle/MarginContainer/RA_DescriptionText
@onready var right_allele_level: Label = $MarginContainer/HBoxContainer/RightAlelle/MarginContainer2/NameText/MarginContainer/HBoxContainer/MarginContainer/RA_LevelText


func _ready():
	update_labels()
	pass

func update_labels() -> void:
	if current_strand == null:
		print('strand is null so we empty the info out')
		left_allele_name.text = "Empty"
		left_allele_description.text = ""
		left_allele_level.text = ""
		right_allele_name.text = "Empty"
		right_allele_description.text = ""
		right_allele_level.text = ""
		return
	if current_strand.left == null:
		print('left slot is empty')
		left_allele_name.text = "Empty"
		left_allele_description.text = ""
		left_allele_level.text = ""
	else:
		print('left allele found', current_strand.left)
		left_allele_name.text = current_strand.left.allele_name
		#left_allele_description.text = current_strand.left.tooltip
		left_allele_description.text = current_strand.left.get_tooltip()
		left_allele_level.text = str(current_strand.left.tier)
	if current_strand.right == null:
		print('right slot is empty')
		right_allele_name.text = "Empty"
		right_allele_description.text = ""
		right_allele_level.text = ""
	else:
		print('right allele found', current_strand.right)
		right_allele_name.text = current_strand.right.allele_name
		right_allele_description.text = current_strand.right.get_tooltip()
		right_allele_level.text = str(current_strand.right.tier)
	


func set_strand(new_strand: Strand):
	print('a strand was passed in', new_strand)
	current_strand = new_strand
	update_labels()
