extends NinePatchRect

var current_strand : Strand = null

@onready var left_allele_name: Label = $MarginContainer/HBoxContainer/LeftAlelle/MarginContainer2/Name/MarginContainer/HBoxContainer/LA_NameText


func _ready():
	pass

func update_labels() -> void:
	left_allele_name.text = "ooga booga"
	
	
	
	
	
	pass


func set_strand(new_strand: Strand):
	current_strand = new_strand
	update_labels()
