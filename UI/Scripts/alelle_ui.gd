extends Control
const CRT_CLICK = preload("uid://dnysns1crxv8p")

@onready var name_of_gene: Label = $MainPanel/Gene2/MainPanel2/Name
@onready var type_of_gene: Label = $MainPanel/Gene2/MainPanel3/Type
@onready var level_of_gene: Label = $MainPanel/Gene2/Level
@onready var description: Label = $MainPanel/MarginContainer/Label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func update_color():
	pass

func update_info(allele_name: String, side: String, desc: String, slot, level: int = 1) -> void:
	name_of_gene.text = allele_name
	type_of_gene.text = side
	level_of_gene.text = str(level)
	description.text = desc
	if TypeColors.colors.has(slot):
		self.modulate = TypeColors.colors[slot]




func squish():
	AudMan.play_sfx_wav(CRT_CLICK, 0.0, false)
	$AnimationPlayer.play("Pop")
