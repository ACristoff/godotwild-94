class_name HealthBar extends Control

@onready var texture_progress_bar: TextureProgressBar = $NinePatchRect/TextureProgressBar
@onready var health_text: Label = $NinePatchRect/TextureProgressBar/HealthText
@onready var shield_text: Label = $NinePatchRect/Shield/ShieldText
@onready var shield: TextureRect = $NinePatchRect/Shield
@onready var damage_indicator_spawn: Marker2D = $DamageIndicatorSpawn

const DAMAGE_TOOLYIP = preload("uid://cxcii53yccour")
const DAMAGE_INDICATOR = preload("uid://b1wbuxori6udj")

@onready var status_ailments: HFlowContainer = $StatusAilments
@onready var yip_stats: HFlowContainer = $YipStats

@export var max_health : int

var HP_graphic_size : int = 52
var HP_graphic_step_size : float
var current_health : int
var current_shield : int = 0

var current_ailments = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	current_health = max_health
	#in ready youd instantiate all the yips stats on the YipStats flowbox

func health_change(change : int, type : String):
	var amount_of_change = current_health - change
	if amount_of_change == 0:
		return
	if amount_of_change < 0:
		amount_of_change *= -1
		spawn_damage_indicator(amount_of_change, type)
		current_health += amount_of_change
		return
	spawn_damage_indicator(amount_of_change, type)
	current_health -= change
	
	HP_graphic_step_size = float(HP_graphic_size) / float(max_health)
	texture_progress_bar.value = current_health * HP_graphic_step_size
	damage_indicator_spawn.position.x = current_health * HP_graphic_step_size
	health_text.text = str(current_health, "/", max_health)
	if current_shield <= 0:
		shield.hide()
	else:
		shield.show()
	shield_text.text = str(current_shield)

func update_UI():
	HP_graphic_step_size = float(HP_graphic_size) / float(max_health)
	texture_progress_bar.value = current_health * HP_graphic_step_size
	damage_indicator_spawn.position.x = current_health * HP_graphic_step_size
	health_text.text = str(current_health, "/", max_health)
	if current_shield <= 0:
		shield.hide()
	else:
		shield.show()
	shield_text.text = str(current_shield)

func spawn_damage_indicator(value, type):
	var dmg_indicator = DAMAGE_INDICATOR.instantiate()
	get_tree().get_root().add_child(dmg_indicator)
	dmg_indicator.global_position = damage_indicator_spawn.global_position
	dmg_indicator.popup(value, type)
	
	
func update_ailments(status_name: String, ailment_value: int):
	for ailment in current_ailments:
		if ailment["status_name"] == status_name:
			ailment["value"] = ailment_value
			ailment["node"].value = ailment_value
			return
	var dmg_note = DAMAGE_TOOLYIP.instantiate()
	status_ailments.add_child(dmg_note)
	dmg_note.status_name = status_name
	dmg_note.value = ailment_value
	current_ailments.append({
		"status_name": status_name,
		"value": ailment_value,
		"node": dmg_note
	})
