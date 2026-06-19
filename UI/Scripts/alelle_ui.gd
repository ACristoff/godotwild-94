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
	
func update_info(name, side, description, level, slot):
	$MainPanel/Gene2/MainPanel2/Name.text = str(name)
	$MainPanel/Gene2/MainPanel3/Type.text = str(side)
	$MainPanel/Gene2/Level.text = str(level)
	$MainPanel/MarginContainer/Label.text = str(description)
	if TypeColors.colors.has(slot):
		self.modulate = TypeColors.colors[slot]
	
	
	
	
	
func squish():
	AudMan.play_sfx_wav(CRT_CLICK, 0.0, false)
	$AnimationPlayer.play("Pop")
